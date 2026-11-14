const express = require('express');
const router = express.Router();
const upload = require('../middleware/upload');
const { readDb, writeDb, addAuditLog } = require('../config/db');

// GET /api/v1/hazards
router.get('/', (req, res) => {
  const db = readDb();
  return res.json({
    success: true,
    total: db.hazards.length,
    hazards: db.hazards
  });
});

// POST /api/v1/hazards (with optional photo & voice note file uploads)
router.post(
  '/',
  upload.fields([
    { name: 'photo', maxCount: 1 },
    { name: 'voiceNote', maxCount: 1 }
  ]),
  (req, res) => {
    const {
      id,
      nmNumber,
      title,
      zone,
      severity = 'Moderate',
      probability = 3,
      reporter,
      reporterId,
      coords = '31.7204° N, 72.9791° E',
      observationType = 'Unsafe Condition',
      categoryType = 'Safety',
      responsibleTeam = 'MMD',
      suggestion,
      correctiveAction,
      assignedTo
    } = req.body;

    if (!title || !zone) {
      return res.status(400).json({ success: false, message: 'Hazard title and plant zone are required.' });
    }

    const db = readDb();

    // Calculate 5x5 score
    const probNum = parseInt(probability) || 3;
    const sevMap = { Low: 1, Moderate: 2, High: 4, Critical: 5 };
    const sevNum = sevMap[severity] || 3;
    const computedScore = probNum * sevNum;

    // File attachments
    let photoUrl = null;
    let voiceNoteUrl = null;
    if (req.files) {
      if (req.files.photo && req.files.photo[0]) {
        photoUrl = `/uploads/${req.files.photo[0].filename}`;
      }
      if (req.files.voiceNote && req.files.voiceNote[0]) {
        voiceNoteUrl = `/uploads/${req.files.voiceNote[0].filename}`;
      }
    }

    const resolvedNm = nmNumber || id || `26-CPL-${475 + (db.hazards ? db.hazards.length : 0)}`;
    const resolvedSuggestion = suggestion || correctiveAction || 'Site inspection and hazard isolation underway';
    const newHazard = {
      id: resolvedNm,
      nmNumber: resolvedNm,
      title: title.trim(),
      zone: zone.trim(),
      severity,
      probability: probNum,
      score: computedScore,
      reporter: reporter || 'CPL Staff',
      reporterId: reporterId || 'CPL-EMP-3845',
      status: 'Open',
      time: 'Just now',
      coords,
      observationType,
      categoryType,
      responsibleTeam,
      suggestion: resolvedSuggestion,
      photoUrl,
      voiceNoteUrl,
      correctiveAction: resolvedSuggestion,
      assignedTo: assignedTo || responsibleTeam,
      createdAt: new Date().toISOString()
    };

    db.hazards.unshift(newHazard);
    writeDb(db);

    // Audit log
    addAuditLog({
      actorId: newHazard.reporterId,
      action: 'HAZARD_REPORTED',
      targetResource: newHazard.id,
      coords: newHazard.coords,
      details: `New ${severity} severity hazard logged: "${title}" at ${zone}. Score: ${computedScore}/25.`
    });

    return res.status(201).json({
      success: true,
      message: 'Hazard report registered successfully',
      hazard: newHazard
    });
  }
);

// PUT /api/v1/hazards/:id/capa (Supervisory CAPA sign-off and status transition)
router.put('/:id/capa', (req, res) => {
  const { id } = req.params;
  const { status, supervisorNotes, supervisorId, supervisorSignature, coords } = req.body;

  const db = readDb();
  const index = db.hazards.findIndex(h => h.id === id);
  if (index === -1) {
    return res.status(404).json({ success: false, message: 'Hazard not found.' });
  }

  const prevStatus = db.hazards[index].status;
  const nextStatus = status || (prevStatus === 'Open' ? 'In Progress' : 'Resolved');

  db.hazards[index].status = nextStatus;
  if (supervisorNotes) {
    db.hazards[index].correctiveAction = supervisorNotes;
  }
  db.hazards[index].supervisorSignOff = {
    supervisorId: supervisorId || 'CP-EMP-1002',
    timestamp: new Date().toISOString(),
    signature: supervisorSignature || 'DIGITAL_SIG_VERIFIED',
    coords: coords || '31.7204° N, 72.9791° E'
  };

  writeDb(db);

  addAuditLog({
    actorId: supervisorId || 'CP-EMP-1002',
    actorRole: 'manager',
    action: 'CAPA_STATUS_UPDATE',
    targetResource: id,
    coords: coords || '31.7204° N, 72.9791° E',
    details: `Hazard ${id} status advanced from '${prevStatus}' to '${nextStatus}'. Digital sign-off recorded.`
  });

  return res.json({
    success: true,
    message: `CAPA status updated to ${nextStatus}`,
    hazard: db.hazards[index]
  });
});

module.exports = router;

