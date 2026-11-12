const express = require('express');
const router = express.Router();
const { readDb, writeDb, addAuditLog } = require('../config/db');

// GET /api/v1/ptw
router.get('/', (req, res) => {
  const db = readDb();
  return res.json({
    success: true,
    total: db.permits.length,
    permits: db.permits
  });
});

// POST /api/v1/ptw (Issue new PTW)
router.post('/', (req, res) => {
  const { type, zone, receiver, lotoCount, gasTelemetry, coords } = req.body;
  if (!type || !zone || !receiver) {
    return res.status(400).json({ success: false, message: 'Type, zone, and receiver are required.' });
  }

  const db = readDb();
  const ptwId = `PTW-${Math.floor(800 + Math.random() * 200)}`;
  const newPtw = {
    id: ptwId,
    type,
    zone,
    receiver,
    expiry: '08h 00m left',
    status: 'Pending',
    lotoCount: parseInt(lotoCount) || 1,
    gasTelemetry: gasTelemetry || 'O2: 20.9% • LEL: 0.0%',
    approvedBy: null,
    coords: coords || '31.7204° N, 72.9791° E',
    issuedAt: new Date().toISOString()
  };

  db.permits.unshift(newPtw);
  writeDb(db);

  addAuditLog({
    actorId: receiver,
    action: 'PTW_REQUESTED',
    targetResource: ptwId,
    coords: newPtw.coords,
    details: `Permit ${ptwId} (${type}) requested for ${zone}. LOTO Padlocks: ${newPtw.lotoCount}.`
  });

  return res.status(201).json({ success: true, message: 'PTW submitted for safety supervisor authorization.', permit: newPtw });
});

// PUT /api/v1/ptw/:id/approve (Supervisory Approval / Release)
router.put('/:id/approve', (req, res) => {
  const { id } = req.params;
  const { supervisorId = 'CP-EMP-1002', supervisorName = 'Asim Raza', action = 'Approve', coords } = req.body;

  const db = readDb();
  const index = db.permits.findIndex(p => p.id === id);
  if (index === -1) {
    return res.status(404).json({ success: false, message: 'Permit not found.' });
  }

  const newStatus = action.toLowerCase() === 'approve' ? 'Active' : 'Hold';
  db.permits[index].status = newStatus;
  db.permits[index].approvedBy = `${supervisorName} (${supervisorId})`;
  writeDb(db);

  addAuditLog({
    actorId: supervisorId,
    actorRole: 'manager',
    action: `PTW_${newStatus.toUpperCase()}`,
    targetResource: id,
    coords: coords || db.permits[index].coords,
    details: `Permit ${id} (${db.permits[index].type} at ${db.permits[index].zone}) marked ${newStatus} by ${supervisorName}.`
  });

  return res.json({
    success: true,
    message: `Permit ${id} successfully transitioned to ${newStatus}.`,
    permit: db.permits[index]
  });
});

module.exports = router;

