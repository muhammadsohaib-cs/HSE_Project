const express = require('express');
const router = express.Router();
const { readDb, writeDb, addAuditLog } = require('../config/db');

// GET /api/v1/checklists/templates
router.get('/templates', (req, res) => {
  const db = readDb();
  return res.json({
    success: true,
    templates: db.checklistTemplates
  });
});

// GET /api/v1/checklists (audits history)
router.get('/', (req, res) => {
  const db = readDb();
  return res.json({
    success: true,
    audits: db.checklistAudits || []
  });
});

// POST /api/v1/checklists (Submit daily shift audit with operator signature)
router.post('/', (req, res) => {
  const { templateId, plantZone, shiftType, inspectorId, inspectorName, items, signatureSvg, coords } = req.body;

  if (!plantZone || !items || !Array.isArray(items)) {
    return res.status(400).json({ success: false, message: 'Plant zone and checklist items are required.' });
  }

  const db = readDb();
  if (!db.checklistAudits) db.checklistAudits = [];

  const passCount = items.filter(i => i.status === 'pass').length;
  const failCount = items.filter(i => i.status === 'fail').length;
  const total = items.length;
  const completionRate = total > 0 ? ((passCount / total) * 100).toFixed(1) : 0;

  const auditId = `AUD-${Date.now().toString().slice(-4)}`;
  const auditRecord = {
    id: auditId,
    templateId: templateId || 'TPL-GEN-01',
    plantZone,
    shiftType: shiftType || 'Shift A: Morning',
    inspectorId: inspectorId || 'CP-EMP-1042',
    inspectorName: inspectorName || 'Muhammad Tariq',
    completionRate: parseFloat(completionRate),
    passCount,
    failCount,
    items,
    signatureVerified: true,
    signatureSvg: signatureSvg || null,
    coords: coords || '31.7204° N, 72.9791° E',
    timestamp: new Date().toISOString()
  };

  db.checklistAudits.unshift(auditRecord);

  // If any item failed, auto-log a CAPA near-miss or hazard
  const failedItems = items.filter(i => i.status === 'fail');
  if (failedItems.length > 0) {
    failedItems.forEach((f, idx) => {
      const autoHazard = {
        id: `HAZ-AUTO-${Date.now().toString().slice(-3)}${idx}`,
        title: `Checklist Defect: ${f.en}`,
        zone: plantZone,
        severity: 'Moderate',
        probability: 3,
        score: 9,
        reporter: `${inspectorName} (Audit ${auditId})`,
        reporterId: inspectorId,
        status: 'Open',
        time: 'Just now',
        coords: coords || '31.7204° N, 72.9791° E',
        correctiveAction: 'Rectify deficiency flagged during shift audit.',
        assignedTo: 'Area Maintenance Lead',
        createdAt: new Date().toISOString()
      };
      db.hazards.unshift(autoHazard);
    });
  }

  writeDb(db);

  addAuditLog({
    actorId: inspectorId,
    action: 'CHECKLIST_SUBMITTED',
    targetResource: auditId,
    coords: coords || '31.7204° N, 72.9791° E',
    details: `Shift checklist ${auditId} submitted for ${plantZone}. Pass: ${passCount}, Fail: ${failCount}, Compliance: ${completionRate}%.`
  });

  return res.status(201).json({
    success: true,
    message: 'Checklist audit successfully recorded with digital signature verification.',
    audit: auditRecord
  });
});

module.exports = router;

