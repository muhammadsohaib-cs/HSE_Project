const express = require('express');
const router = express.Router();
const { readDb, addAuditLog } = require('../config/db');

// GET /api/v1/audit/logs (Immutable Audit Trail for NEPRA / ISO 45001)
router.get('/logs', (req, res) => {
  const db = readDb();
  const limit = parseInt(req.query.limit) || 100;
  const logs = (db.auditLogs || []).slice(0, limit);

  return res.json({
    success: true,
    totalLogs: logs.length,
    logs
  });
});

// POST /api/v1/audit/logs (Append new immutable audit log)
router.post('/logs', (req, res) => {
  const { actorId, actorRole, action, targetResource, coords, details } = req.body;
  const entry = addAuditLog({
    actorId,
    actorRole,
    action,
    targetResource,
    coords,
    details
  });
  return res.status(201).json({
    success: true,
    message: 'Audit log appended',
    entry
  });
});

module.exports = router;

