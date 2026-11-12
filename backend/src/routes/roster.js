const express = require('express');
const router = express.Router();
const { readDb, writeDb, addAuditLog } = require('../config/db');

// GET /api/v1/roster (Dynamic Muster Roll & Live PPE Compliance)
router.get('/', (req, res) => {
  const db = readDb();
  if (!db.roster) db.roster = [];
  
  const totalOnSite = db.roster.length;
  const compliantCount = db.roster.filter(w => w.helmet && w.shoes && w.gloves && w.ear).length;
  const complianceRate = totalOnSite > 0 ? ((compliantCount / totalOnSite) * 100).toFixed(1) + '%' : '100.0%';

  return res.json({
    success: true,
    musterRoll: {
      totalSafe: compliantCount,
      totalOnSite: totalOnSite,
      complianceRate: complianceRate
    },
    roster: db.roster,
    workers: db.roster
  });
});

// PUT /api/v1/roster/:empId/ppe (Toggle PPE verification chip)
router.put('/:empId/ppe', (req, res) => {
  const { empId } = req.params;
  const { ppeType } = req.body; // 'helmet', 'shoes', 'gloves', 'ear'

  const db = readDb();
  if (!db.roster) db.roster = [];
  const index = db.roster.findIndex(w => w.empId.toUpperCase() === empId.toUpperCase());
  if (index === -1) {
    return res.status(404).json({ success: false, message: 'Worker not found on roster.' });
  }

  if (['helmet', 'shoes', 'gloves', 'ear'].includes(ppeType)) {
    db.roster[index][ppeType] = !db.roster[index][ppeType];
    writeDb(db);

    addAuditLog({
      actorId: 'CP-EMP-1042',
      actorRole: 'inspector',
      action: 'PPE_STATUS_CHANGE',
      targetResource: empId,
      details: `Worker ${empId} PPE '${ppeType}' toggled to ${db.roster[index][ppeType]}.`
    });

    return res.json({
      success: true,
      message: `PPE ${ppeType} updated for worker ${empId}`,
      worker: db.roster[index]
    });
  }

  return res.status(400).json({ success: false, message: 'Invalid PPE type. Must be helmet, shoes, gloves, or ear.' });
});

module.exports = router;
