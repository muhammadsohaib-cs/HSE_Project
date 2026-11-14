const express = require('express');
const router = express.Router();
const { readDb } = require('../config/db');

// GET /api/v1/analytics/summary (Real CPL Oct/Nov 2026 Operational & Near-Miss Metrics)
router.get('/summary', (req, res) => {
  const db = readDb();
  const openHazards = (db.hazards || []).filter(h => h.status !== 'Resolved' && h.status !== 'Closed').length;
  const criticalHazards = (db.hazards || []).filter(h => h.severity === 'Critical' && h.status !== 'Resolved' && h.status !== 'Closed').length;
  const activePtws = (db.permits || []).filter(p => p.status === 'Active').length;

  return res.json({
    success: true,
    data: {
      cplSiteStaff: 388,
      cplSiteManHours: 75082,
      cplSiteBreakdown: {
        permanent: 121,
        temporary: 253,
        dailyWages: 9,
        contract: 5
      },
      eklContractorStaff: 46,
      eklContractorManHours: 9648,
      combinedActivePersonnel: 434,
      totalManHours: 84730,
      nearMissTotal: 389,
      nearMissClosed: 321,
      nearMissOpen: 68,
      capaClosureRate: '82.5%',
      onSiteHeadcount: '434 Active Personnel (388 CPL + 46 EKL)',
      openHazardsCount: openHazards,
      criticalHazardsCount: criticalHazards,
      activePtwCount: activePtws,
      departmentManHours: [
        { department: 'Admin & HR', staff: 108, manHours: 24204 },
        { department: 'Operations Deptt.', staff: 106, manHours: 18326 },
        { department: 'Fuel Dept', staff: 92, manHours: 17010 },
        { department: 'Mechanical (MMD)', staff: 27, manHours: 5252 },
        { department: 'Safety & Health (HSE)', staff: 12, manHours: 3310 },
        { department: 'Electrical (EMD)', staff: 10, manHours: 1644 },
        { department: 'I&C', staff: 9, manHours: 1644 },
        { department: 'Civil', staff: 6, manHours: 1056 },
        { department: 'Stores', staff: 8, manHours: 948 }
      ],
      monthlyNearMiss2026: [
        { month: 'Jan', hazards: 41, closed: 40 },
        { month: 'Feb', hazards: 13, closed: 12 },
        { month: 'Mar', hazards: 23, closed: 23 },
        { month: 'Apr', hazards: 48, closed: 41 },
        { month: 'May', hazards: 56, closed: 49 },
        { month: 'Jun', hazards: 45, closed: 39 },
        { month: 'Jul', hazards: 79, closed: 61 },
        { month: 'Aug', hazards: 38, closed: 30 },
        { month: 'Sep', hazards: 23, closed: 20 },
        { month: 'Oct', hazards: 23, closed: 6 }
      ],
      departmentNearMissBreakdown: [
        { department: 'MMD', cases: 155 },
        { department: 'EMD', cases: 64 },
        { department: 'Admin', cases: 64 },
        { department: 'Civil', cases: 26 },
        { department: 'Ops', cases: 20 },
        { department: 'Safety / HSE', cases: 12 },
        { department: 'Fuel', cases: 5 },
        { department: 'I&C', cases: 3 }
      ]
    }
  });
});

module.exports = router;
