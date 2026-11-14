const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { readDb, writeDb, addAuditLog } = require('../config/db');
const { generateTokens, authenticateToken, JWT_REFRESH_SECRET } = require('../middleware/auth');

function formatUserResponse(user) {
  let displayRole = user.role || 'Plant Worker';
  if (user.role === 'admin' || user.role === 'manager' || user.role === 'HSE Manager') {
    displayRole = 'HSE Manager';
  } else if (user.role === 'inspector' || user.role === 'safety' || user.role === 'Safety Officer') {
    displayRole = 'Safety Officer';
  } else if (user.role === 'worker' || user.role === 'operator' || user.role === 'Plant Worker') {
    displayRole = 'Plant Worker';
  }

  const assignedZone = user.assignedZone || user.plantZone || user.zone || 'Boiler House Unit-1';
  const fullName = user.fullName || user.name || 'CPL Staff';

  return {
    id: user.id,
    empId: user.employeeId,
    employeeId: user.employeeId,
    fullName,
    name: fullName,
    urduName: user.urduName || fullName,
    role: displayRole,
    department: user.department || 'Operations & Maintenance',
    shift: user.shift || 'Shift A: Morning',
    cnic: user.cnic || '33202-0000000-1',
    assignedZone,
    zone: assignedZone,
    status: user.status || (user.isActive ? 'Approved' : 'Pending')
  };
}

function normalizeEmpId(raw) {
  const s = (raw || '').toString().trim().toUpperCase();
  if (/^\d+$/.test(s)) {
    return `CPL-EMP-${s.padStart(4, '0')}`;
  }
  return s;
}

// POST /api/auth/login & /api/v1/auth/login
router.post('/login', (req, res) => {
  const rawEmpId = req.body.empId || req.body.employeeId;
  const rawSecret = req.body.password !== undefined ? req.body.password : req.body.pin;

  if (!rawEmpId || !rawEmpId.toString().trim()) {
    return res.status(400).json({ success: false, message: 'Employee ID is required.' });
  }

  if (rawSecret === undefined || rawSecret === null || !rawSecret.toString().trim()) {
    return res.status(400).json({ success: false, message: 'Password or Security PIN is required.' });
  }

  const rawTrimmed = rawEmpId.toString().trim().toUpperCase();
  const cleanInputId = normalizeEmpId(rawTrimmed);
  const secret = rawSecret.toString().trim();
  const db = readDb();
  if (!db.users) db.users = [];

  // Exact case-insensitive match first, then raw numeric empCode, then CP- <-> CPL- prefix fallback
  let user = db.users.find(
    u =>
      (u.employeeId && u.employeeId.toUpperCase() === cleanInputId) ||
      (u.empCode && u.empCode.toString().toUpperCase() === rawTrimmed)
  );
  if (!user) {
    user = db.users.find(u => {
      if (!u.employeeId) return false;
      const uId = u.employeeId.toUpperCase();
      return (
        uId.replace('CP-', 'CPL-') === cleanInputId ||
        uId.replace('CPL-', 'CP-') === cleanInputId
      );
    });
  }

  if (!user) {
    return res.status(401).json({ success: false, message: `Employee ID ${cleanInputId} is not registered.` });
  }

  if (user.status === 'Blocked') {
    return res.status(403).json({
      success: false,
      message: 'This Employee ID has been blocked by HSE Administration.'
    });
  }

  // Strictly verify Password / PIN
  let isVerified = false;
  if (
    user.pin &&
    (user.pin.toString().trim() === secret ||
      (/^\d+$/.test(secret) && user.pin.toString().trim() === secret.padStart(4, '0')))
  ) {
    isVerified = true;
  } else if (user.passwordHash) {
    try {
      isVerified = bcrypt.compareSync(secret, user.passwordHash);
    } catch (_) {
      isVerified = false;
    }
  }

  if (!isVerified) {
    return res.status(401).json({ success: false, message: 'Incorrect Password or Security PIN.' });
  }

  const tokens = generateTokens(user);
  const formattedUser = formatUserResponse(user);

  addAuditLog({
    actorId: formattedUser.empId,
    actorRole: formattedUser.role,
    action: 'USER_LOGIN',
    targetResource: formattedUser.assignedZone,
    details: `Employee ${formattedUser.empId} (${formattedUser.fullName} - ${formattedUser.role}) authenticated successfully.`
  });

  return res.json({
    success: true,
    message: 'Authentication successful',
    token: tokens.accessToken,
    refreshToken: tokens.refreshToken,
    user: formattedUser
  });
});

// POST /api/auth/register & /api/v1/auth/register
// Immediately saves with status: "Approved" (no lockout) and returns 201 with { success: true, token, user }
router.post('/register', (req, res) => {
  const rawEmpId = req.body.empId || req.body.employeeId;
  const rawFullName = req.body.fullName || req.body.name;
  const rawSecret = req.body.password !== undefined ? req.body.password : req.body.pin;
  const { urduName, email, cnic, shift, role, assignedZone, plantZone, zone } = req.body;

  if (!rawEmpId || !rawEmpId.toString().trim() || !rawFullName || !rawFullName.toString().trim()) {
    return res.status(400).json({ success: false, message: 'Employee ID and Full Name are required.' });
  }

  if (!rawSecret || !rawSecret.toString().trim()) {
    return res.status(400).json({ success: false, message: 'Password or Security PIN is required for registration.' });
  }

  const cleanId = normalizeEmpId(rawEmpId);
  const cleanName = rawFullName.toString().trim();
  const assignedSecret = rawSecret.toString().trim();
  const assignedRole = (role && role.toString().trim().length > 0) ? role.toString().trim() : 'Plant Worker';
  const assignedShift = shift || 'Shift A (07:00 - 19:00 / 19:00 - 07:00)';
  const resolvedZone = assignedZone || plantZone || zone || 'Boiler Area (Unit 1 & 2)';
  const cleanCnic = cnic ? cnic.toString().trim() : '33202-0000000-1';

  const db = readDb();
  if (!db.users) db.users = [];
  if (!db.pendingUsers) db.pendingUsers = [];
  if (!db.roster) db.roster = [];

  const existing = db.users.find(u => u.employeeId && u.employeeId.toUpperCase() === cleanId);
  if (existing) {
    return res.status(409).json({
      success: false,
      message: `Employee ID ${cleanId} is already registered. Please sign in.`
    });
  }

  const newUser = {
    id: `u-${Date.now()}`,
    employeeId: cleanId,
    empId: cleanId,
    fullName: cleanName,
    name: cleanName,
    urduName: urduName || cleanName,
    email: email || `${cleanId.toLowerCase()}@chiniotpower.com.pk`,
    passwordHash: bcrypt.hashSync(assignedSecret, 10),
    pin: assignedSecret,
    role: assignedRole,
    department: 'Operations & Maintenance',
    shift: assignedShift,
    cnic: cleanCnic,
    plantZone: resolvedZone,
    assignedZone: resolvedZone,
    isActive: true,
    status: 'Approved',
    createdAt: new Date().toISOString()
  };

  db.users.push(newUser);

  const pendingEntry = {
    empId: cleanId,
    name: cleanName,
    fullName: cleanName,
    urduName: newUser.urduName,
    cnic: cleanCnic,
    role: assignedRole,
    shift: assignedShift,
    pin: assignedSecret,
    zone: resolvedZone,
    assignedZone: resolvedZone,
    status: 'Approved',
    createdAt: newUser.createdAt
  };
  db.pendingUsers.unshift(pendingEntry);

  // Sync to active roster if not already present
  if (!db.roster.some(w => w.empId && w.empId.toUpperCase() === cleanId)) {
    db.roster.push({
      empId: cleanId,
      name: cleanName,
      ur: newUser.urduName,
      role: assignedRole,
      zone: resolvedZone,
      helmet: true,
      shoes: true,
      gloves: true,
      ear: true
    });
  }

  writeDb(db);

  addAuditLog({
    actorId: cleanId,
    actorRole: assignedRole,
    action: 'STAFF_REGISTRATION',
    targetResource: resolvedZone,
    details: `Employee ${cleanName} (${cleanId}) registered as ${assignedRole} (${resolvedZone}) with immediate Approved status.`
  });

  const tokens = generateTokens(newUser);
  const formattedUser = formatUserResponse(newUser);

  return res.status(201).json({
    success: true,
    message: `Account Registered for ${cleanId}!`,
    token: tokens.accessToken,
    refreshToken: tokens.refreshToken,
    user: formattedUser,
    pendingUser: pendingEntry
  });
});

// GET /api/auth/pending-users & /api/v1/auth/pending-users
router.get('/pending-users', (req, res) => {
  const db = readDb();
  if (!db.pendingUsers) {
    db.pendingUsers = [];
  }
  return res.json({
    success: true,
    pendingUsers: db.pendingUsers
  });
});

// PUT /api/auth/users/:empId/approve & /api/v1/auth/users/:empId/approve
router.put('/users/:empId/approve', (req, res) => {
  const { empId } = req.params;
  const { status, approverId, approverName } = req.body;
  const newStatus = status || 'Approved';
  const cleanId = empId.trim().toUpperCase();
  const db = readDb();

  if (!db.pendingUsers) db.pendingUsers = [];
  if (!db.users) db.users = [];
  if (!db.roster) db.roster = [];

  const pending = db.pendingUsers.find(p => p.empId && p.empId.toUpperCase() === cleanId);
  if (pending) {
    pending.status = newStatus;
    pending.approvedBy = approverName || approverId || 'HSE Manager';
    pending.approvedAt = new Date().toISOString();
  }

  const user = db.users.find(u => u.employeeId && u.employeeId.toUpperCase() === cleanId);
  if (user) {
    user.isActive = (newStatus === 'Approved');
    user.status = newStatus;
    user.approvedBy = approverName || approverId || 'HSE Manager';
    user.approvedAt = new Date().toISOString();
  }

  if (newStatus === 'Approved' && user) {
    if (!db.roster.some(w => w.empId && w.empId.toUpperCase() === cleanId)) {
      db.roster.push({
        empId: cleanId,
        name: user.name,
        ur: user.urduName || user.name,
        role: user.role,
        zone: user.assignedZone || user.plantZone || 'Boiler House Unit-1',
        helmet: true,
        shoes: true,
        gloves: true,
        ear: true
      });
    }
  }

  addAuditLog({
    actorId: approverId || 'CPL-EMP-1001',
    actorRole: 'admin',
    action: newStatus === 'Approved' ? 'STAFF_ID_APPROVAL' : 'STAFF_ID_BLOCKED',
    targetResource: cleanId,
    details: `Staff member ${cleanId} marked as ${newStatus} by ${approverName || approverId || 'HSE Manager'}.`
  });

  writeDb(db);

  return res.json({
    success: true,
    message: `Staff member ${cleanId} marked as ${newStatus}.`,
    user: user ? formatUserResponse(user) : null,
    pending
  });
});

// POST /api/auth/refresh
router.post('/refresh', (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return res.status(401).json({ success: false, message: 'Missing refresh token.' });
  }

  jwt.verify(refreshToken, JWT_REFRESH_SECRET, (err, decoded) => {
    if (err) {
      return res.status(403).json({ success: false, message: 'Invalid or expired refresh token.' });
    }

    const db = readDb();
    const user = db.users.find(u => u.id === decoded.id && u.isActive);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found or deactivated.' });
    }

    const tokens = generateTokens(user);
    return res.json({ success: true, ...tokens });
  });
});

// GET /api/auth/me
router.get('/me', authenticateToken, (req, res) => {
  const db = readDb();
  const user = db.users.find(u => u.id === req.user.id);
  if (!user) return res.status(404).json({ success: false, message: 'User not found.' });

  return res.json({
    success: true,
    user: formatUserResponse(user)
  });
});

module.exports = router;
