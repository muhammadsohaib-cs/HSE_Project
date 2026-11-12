const express = require('express');
const router = express.Router();
const { readDb } = require('../config/db');

// GET /api/v1/analytics/summary (NEPRA / ISO 45001 Compliance Dashboard)
router.get('/summary', (req, res) => {
  const db = readDb();
  const openHazards = db.hazards.filter(h => h.status !== 'Resolved').length;
  const criticalHazards = db.hazards.filter(h => h.severity === 'Critical' && h.status !== 'Resolved').length;
  const activePtws = db.permits.filter(p => p.status === 'Active').length;

  return res.json({
    success: true,
    data: {
      safeWorkDays: 218,
      ltiCount: 0,
      totalManHours: 3840000,
      capaClosureRate: '96.2%',
      complianceRate: '97.2%',
      onSiteHeadcount: '148 / 148 Safe',
      openHazardsCount: openHazards,
      criticalHazardsCount: criticalHazards,
      activePtwCount: activePtws,
      departmentBreakdown: [
        { name: 'Boiler House Unit-1', hazards: 4, compliance: '94%' },
        { name: 'Steam Turbine Hall', hazards: 1, compliance: '98%' },
        { name: 'Bagasse Yard', hazards: 5, compliance: '91%' },
        { name: '132kV Switchyard', hazards: 2, compliance: '96%' }
      ]
    }
  });
});

module.exports = router;

