const express = require('express');
const router = express.Router();
const { readDb, writeDb, addAuditLog } = require('../config/db');

// GET /api/v1/alarms
router.get('/', (req, res) => {
  const db = readDb();
  return res.json({
    success: true,
    activeAlarm: db.activeAlarm || null,
    history: db.alarms || [],
    emailLogs: db.emailLogs || []
  });
});

// POST /api/v1/alarms/trigger (Plant Siren Activation + Email Broadcast)
router.post('/trigger', (req, res) => {
  const { title, zone = 'Plant-Wide (Boiler & Grid)', severity = 'critical', triggeredBy = 'CP-EMP-1042', coords } = req.body;

  const db = readDb();
  const alarmId = `ALM-${Date.now().toString().slice(-4)}`;
  const alarmRecord = {
    id: alarmId,
    title: title || 'CRITICAL PLANT EMERGENCY SIREN',
    zone,
    severity,
    triggeredBy,
    timestamp: new Date().toISOString(),
    coords: coords || '31.7204° N, 72.9791° E',
    isAcknowledged: false
  };

  db.activeAlarm = alarmRecord.title;
  if (!db.alarms) db.alarms = [];
  db.alarms.unshift(alarmRecord);

  // Auto-generate transactional email gateway logs
  const recipients = [
    'plant.manager@chiniotpower.com',
    'hse.head@chiniotpower.com',
    'rescue1122.chiniot@punjab.gov.pk'
  ];

  if (!db.emailLogs) db.emailLogs = [];
  recipients.forEach(email => {
    db.emailLogs.unshift({
      id: `EML-${Date.now().toString().slice(-3)}-${Math.floor(Math.random() * 100)}`,
      to: email,
      subject: `[CRITICAL SIREN ALERT] ${alarmRecord.title} at ${zone}`,
      status: 'Sent (SMTP Intranet Gateway)',
      timestamp: new Date().toISOString()
    });
  });

  writeDb(db);

  addAuditLog({
    actorId: triggeredBy,
    actorRole: 'inspector',
    action: 'EMERGENCY_ALARM_ACTIVATED',
    targetResource: alarmId,
    coords: alarmRecord.coords,
    details: `Plant emergency siren triggered: "${alarmRecord.title}". Automatic email dispatches sent to Rescue 1122 and plant executives.`
  });

  return res.status(201).json({
    success: true,
    message: 'EMERGENCY SIREN ACTIVATED. Transactional emails dispatched to plant command.',
    alarm: alarmRecord,
    dispatchesSent: recipients.length
  });
});

// POST /api/v1/alarms/clear (All-Clear Drill Reset)
router.post('/clear', (req, res) => {
  const { clearedBy = 'CP-EMP-1001', notes } = req.body;

  const db = readDb();
  const previousAlarm = db.activeAlarm;
  db.activeAlarm = null;
  writeDb(db);

  addAuditLog({
    actorId: clearedBy,
    actorRole: 'admin',
    action: 'EMERGENCY_ALARM_ALL_CLEAR',
    targetResource: 'PLANT_WIDE',
    details: `All-Clear Drill issued. Active siren "${previousAlarm}" silenced. ${notes || 'Site inspected and declared safe.'}`
  });

  return res.json({
    success: true,
    message: 'ALL-CLEAR verified. Emergency alarms reset.',
    activeAlarm: null
  });
});

module.exports = router;

