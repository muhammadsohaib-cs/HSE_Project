const express = require('express');
const router = express.Router();
const { readDb } = require('../config/db');

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

module.exports = router;

