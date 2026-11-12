const express = require('express');
const router = express.Router();
const { readDb, writeDb, addAuditLog } = require('../config/db');

// GET /api/v1/roster
router.get('/', (req, res) => {
  const db = readDb();
  const totalAccounted = db.roster.length;
  return res.json({
    success: true,
    musterRoll: {
      totalSafe: 148,
      totalOnSite: 148,
      complianceRate: '97.2%'
    },
    workers: db.roster
  });
});

// PUT /api/v1/roster/:empId/ppe (Toggle PPE verification chip)
router.put('/:empId/ppe', (req, res) => {
  const { empId } = req.params;
  const { ppeType } = req.body; // 'helmet', 'shoes', 'gloves', 'ear'

  const db = readDb();
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

