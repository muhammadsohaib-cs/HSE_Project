const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const jwt = require('jsonwebtoken');
const { readDb, writeDb, addAuditLog } = require('../config/db');
const { generateTokens, authenticateToken, JWT_REFRESH_SECRET } = require('../middleware/auth');
const upload = require('../middleware/upload');
const mailer = require('../services/mailer');

const AVATARS_DIR = path.join(__dirname, '../../uploads/avatars');
if (!fs.existsSync(AVATARS_DIR)) {
  fs.mkdirSync(AVATARS_DIR, { recursive: true });
}

function formatUserResponse(user) {
  let displayRole = user.role || 'Plant Worker';
  if (user.role === 'admin' || user.role === 'manager' || user.role === 'HSE Manager') {
    displayRole = 'HSE Manager';
  } else if (user.role === 'inspector' || user.role === 'safety' || user.role === 'Safety Officer') {
    displayRole = 'Safety Officer';
  } else if (user.role === 'worker' || user.role === 'operator' || user.role === 'Plant Worker') {
    displayRole = 'Plant Worker';
  }

  const assignedZone = user.assignedZone || user.plantZone || user.zone || 'Boiler Area (Unit 1 & 2)';
  const fullName = user.fullName || user.name || 'CPL Staff';

  return {
    id: user.id,
    empId: user.employeeId || user.empId,
    employeeId: user.employeeId || user.empId,
    fullName,
    name: fullName,
    urduName: user.urduName || fullName,
    email: user.email || '',
    role: displayRole,
    department: user.department || 'Operations & Maintenance',
    shift: user.shift || 'General Shift (08:00 - 17:00)',
    cnic: user.cnic || '33202-0000000-1',
    assignedZone,
    zone: assignedZone,
    profileImageUrl: user.profileImageUrl || null,
    status: user.status || (user.isActive === false ? 'Pending' : 'Approved'),
  };
}

function isManagerRole(role) {
  const r = (role || '').toString().toLowerCase();
  return (
    r === 'manager' ||
    r === 'admin' ||
    r === 'hse manager' ||
    r.includes('dy. manager') ||
    r.includes('plant manager') ||
    r.includes('general manager') ||
    r.includes('dgm') ||
    r.includes('shift manager')
  );
}

function requireHseManager(req, res, next) {
  if (!req.user) {
    return res.status(401).json({ success: false, message: 'Authentication required.' });
  }
  if (!isManagerRole(req.user.role)) {
    return res.status(403).json({
      success: false,
      message: 'Access denied. Only the authorized HSE Manager can perform this action.',
    });
  }
  return next();
}

function normalizeEmpId(raw) {
  const s = (raw || '').toString().trim().toUpperCase();
  if (/^\d+$/.test(s)) {
    return `CPL-EMP-${s.padStart(4, '0')}`;
  }
  return s;
}

function findUserById(users, rawInput) {
  const rawTrimmed = (rawInput || '').toString().trim().toUpperCase();
  const cleanId = normalizeEmpId(rawTrimmed);
  let user = (users || []).find(
    (u) =>
      (u.employeeId && u.employeeId.toUpperCase() === cleanId) ||
      (u.empId && u.empId.toUpperCase() === cleanId) ||
      (u.empCode && u.empCode.toString().toUpperCase() === rawTrimmed)
  );
  if (!user) {
    user = (users || []).find((u) => {
      const uId = (u.employeeId || u.empId || '').toUpperCase();
      if (!uId) return false;
      return (
        uId.replace('CP-', 'CPL-') === cleanId ||
        uId.replace('CPL-', 'CP-') === cleanId
      );
    });
  }
  return user || null;
}

function verifyUserPassword(user, secret) {
  if (!user || !secret) return false;
  // Prefer bcrypt hash first
  if (user.passwordHash) {
    try {
      if (bcrypt.compareSync(secret, user.passwordHash)) return true;
    } catch (_) {}
  }
  // Legacy initial PIN fallback only if user has not replaced PIN with custom password
  if (
    user.pin &&
    (user.pin.toString().trim() === secret ||
      (/^\d+$/.test(secret) && user.pin.toString().trim() === secret.padStart(4, '0')))
  ) {
    return true;
  }
  return false;
}

function activatePendingRegistration(db, pending, approverName, approverId) {
  if (!db.users) db.users = [];
  if (!db.roster) db.roster = [];
  const cleanId = normalizeEmpId(pending.empId);
  const nowIso = new Date().toISOString();

  pending.status = 'Approved';
  pending.approvedBy = approverName;
  pending.approvedAt = nowIso;

  let user = findUserById(db.users, cleanId);
  if (!user) {
    user = {
      id: `u-${Date.now()}`,
      employeeId: cleanId,
      empId: cleanId,
      fullName: pending.fullName || pending.name,
      name: pending.fullName || pending.name,
      urduName: pending.urduName || pending.fullName || pending.name,
      email: pending.email || `${cleanId.toLowerCase()}@chiniotpower.com.pk`,
      passwordHash: pending.passwordHash || bcrypt.hashSync(String(pending.pin || '1234'), 10),
      role: pending.role || 'Plant Worker',
      department: pending.department || 'Operations & Maintenance',
      shift: pending.shift || 'General Shift (08:00 - 17:00)',
      cnic: pending.cnic || '33202-0000000-1',
      plantZone: pending.assignedZone || pending.zone || 'Boiler Area (Unit 1 & 2)',
      assignedZone: pending.assignedZone || pending.zone || 'Boiler Area (Unit 1 & 2)',
      profileImageUrl: pending.profileImageUrl || null,
      isActive: true,
      status: 'Approved',
      approvedBy: approverName,
      approvedAt: nowIso,
      createdAt: pending.createdAt || nowIso,
    };
    db.users.push(user);
  } else {
    user.isActive = true;
    user.status = 'Approved';
    user.approvedBy = approverName;
    user.approvedAt = nowIso;
    if (pending.passwordHash) {
      user.passwordHash = pending.passwordHash;
    }
  }

  // Ensure active roster contains approved employee
  if (!db.roster.some((w) => w.empId && normalizeEmpId(w.empId) === cleanId)) {
    db.roster.push({
      empId: cleanId,
      name: user.name,
      ur: user.urduName || user.name,
      role: user.role,
      designation: user.role,
      shift: user.shift.includes('Shift A')
        ? 'Shift A'
        : user.shift.includes('Shift B')
        ? 'Shift B'
        : user.shift.includes('Shift C')
        ? 'Shift C'
        : user.shift.includes('Shift D')
        ? 'Shift D'
        : 'General',
      zone: user.assignedZone || user.plantZone || 'Boiler Area (Unit 1 & 2)',
      attendanceStatus: 'D',
      nightsPerformed: 0,
      helmet: true,
      shoes: true,
      gloves: true,
      ear: true,
    });
  }

  addAuditLog({
    actorId: approverId || 'CPL-EMP-3648',
    actorRole: 'HSE Manager',
    action: 'STAFF_ID_APPROVAL',
    targetResource: cleanId,
    details: `Employee ${user.name} (${cleanId}) approved & activated by ${approverName}.`,
  });

  return user;
}

// =========================================================================
// 1. LOGIN (Strict Approval Gate — Only Approved Active Accounts Allowed)
// =========================================================================
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
  if (!db.pendingUsers) db.pendingUsers = [];

  const user = findUserById(db.users, rawTrimmed);

  // If not yet in approved users, check pendingUsers so user receives exact approval status!
  if (!user) {
    const pending = db.pendingUsers.find(
      (p) => p.empId && (normalizeEmpId(p.empId) === cleanInputId || p.empId.toUpperCase() === rawTrimmed)
    );
    if (pending) {
      if (pending.status === 'Pending') {
        const approver = pending.approverEmail || mailer.getApproverEmail();
        return res.status(403).json({
          success: false,
          status: 'Pending',
          message: `Account ${cleanInputId} is awaiting HSE Manager approval (Sumaira Rafique). Please confirm via the approval email sent to ${approver}.`,
        });
      }
      if (pending.status === 'Rejected' || pending.status === 'Blocked') {
        return res.status(403).json({
          success: false,
          status: pending.status,
          message: `Registration for ${cleanInputId} was ${pending.status.toLowerCase()} by HSE Administration.`,
        });
      }
    }
    return res.status(401).json({
      success: false,
      message: `Employee ID ${cleanInputId} is not registered. Please submit a registration request first.`,
    });
  }

  if (user.status === 'Pending' || user.isActive === false) {
    return res.status(403).json({
      success: false,
      status: 'Pending',
      message: `Account ${cleanInputId} is pending HSE Manager approval. You can sign in once approved.`,
    });
  }

  if (user.status === 'Blocked' || user.status === 'Rejected') {
    return res.status(403).json({
      success: false,
      status: user.status,
      message: `This Employee ID has been ${user.status.toLowerCase()} by HSE Administration.`,
    });
  }

  if (!verifyUserPassword(user, secret)) {
    return res.status(401).json({ success: false, message: 'Incorrect Password or Security PIN.' });
  }

  const tokens = generateTokens(user);
  const formattedUser = formatUserResponse(user);

  addAuditLog({
    actorId: formattedUser.empId,
    actorRole: formattedUser.role,
    action: 'USER_LOGIN',
    targetResource: formattedUser.assignedZone,
    details: `Employee ${formattedUser.empId} (${formattedUser.fullName} - ${formattedUser.role}) signed in.`,
  });

  return res.json({
    success: true,
    message: 'Authentication successful',
    token: tokens.accessToken,
    refreshToken: tokens.refreshToken,
    user: formattedUser,
  });
});

// =========================================================================
// 2. LOGOUT (Server-side Audit & Clean Session Termination)
// =========================================================================
router.post('/logout', (req, res) => {
  const empId = req.body.empId || 'UNKNOWN';
  const zone = req.body.zone || 'AUTH_GATEWAY';
  addAuditLog({
    actorId: empId,
    actorRole: req.body.role || 'staff',
    action: 'USER_LOGOUT',
    targetResource: zone,
    details: `Employee ${empId} signed out cleanly.`,
  });
  return res.json({ success: true, message: 'Signed out successfully.' });
});

// =========================================================================
// 3. REGISTRATION -> PENDING APPROVAL + REAL NODEMAILER EMAIL TO HSE MANAGER
// =========================================================================
router.post('/register', async (req, res) => {
  const rawEmpId = req.body.empId || req.body.employeeId;
  const rawFullName = req.body.fullName || req.body.name;
  const rawSecret = req.body.password !== undefined ? req.body.password : req.body.pin;
  const { urduName, email, cnic, shift, role, assignedZone, plantZone, zone } = req.body;

  if (!rawEmpId || !rawEmpId.toString().trim() || !rawFullName || !rawFullName.toString().trim()) {
    return res.status(400).json({ success: false, message: 'Employee ID and Full Name are required.' });
  }

  if (!rawSecret || rawSecret.toString().trim().length < 4) {
    return res.status(400).json({
      success: false,
      message: 'Password must be at least 4 characters long.',
    });
  }

  const cleanId = normalizeEmpId(rawEmpId);
  const cleanName = rawFullName.toString().trim();
  const cleanEmail = (email || '').toString().trim();
  const assignedSecret = rawSecret.toString().trim();
  const assignedRole = role && role.toString().trim().length > 0 ? role.toString().trim() : 'Plant Worker';
  const assignedShift = shift || 'General Shift (08:00 - 17:00)';
  const resolvedZone = assignedZone || plantZone || zone || 'Boiler Area (Unit 1 & 2)';
  const cleanCnic = cnic ? cnic.toString().trim() : '33202-0000000-1';

  const db = readDb();
  if (!db.users) db.users = [];
  if (!db.pendingUsers) db.pendingUsers = [];
  if (!db.emailLogs) db.emailLogs = [];

  if (findUserById(db.users, cleanId)) {
    return res.status(409).json({
      success: false,
      message: `Employee ID ${cleanId} is already registered and active. Please sign in.`,
    });
  }

  const existingPending = db.pendingUsers.find(
    (p) => p.empId && normalizeEmpId(p.empId) === cleanId && p.status === 'Pending'
  );
  if (existingPending) {
    return res.status(409).json({
      success: false,
      status: 'Pending',
      message: `A registration request for ${cleanId} is already pending HSE Manager approval (${existingPending.approverEmail || mailer.getApproverEmail()}).`,
    });
  }

  const approvalToken = crypto.randomBytes(32).toString('hex');
  const nowIso = new Date().toISOString();
  const approverEmail = mailer.getApproverEmail();

  const pendingEntry = {
    empId: cleanId,
    name: cleanName,
    fullName: cleanName,
    urduName: urduName || cleanName,
    email: cleanEmail,
    cnic: cleanCnic,
    role: assignedRole,
    shift: assignedShift,
    passwordHash: bcrypt.hashSync(assignedSecret, 10),
    zone: resolvedZone,
    assignedZone: resolvedZone,
    status: 'Pending',
    approvalToken,
    approverEmail,
    createdAt: nowIso,
  };

  // Replace any older rejected entry for the same empId, otherwise prepend
  db.pendingUsers = [
    pendingEntry,
    ...db.pendingUsers.filter((p) => !p.empId || normalizeEmpId(p.empId) !== cleanId),
  ];

  // Build private single-use approval links sent ONLY inside the real Gmail message to HSE Manager
  const baseUrl = process.env.PUBLIC_BASE_URL || `${req.protocol}://${req.get('host')}`;
  const approveUrl = `${baseUrl}/api/v1/auth/email-action?token=${approvalToken}&action=approve`;
  const rejectUrl = `${baseUrl}/api/v1/auth/email-action?token=${approvalToken}&action=reject`;

  let emailDelivery = {
    sent: false,
    to: approverEmail,
    mode: 'gmail-smtp',
    error: null,
  };

  try {
    emailDelivery = await mailer.sendApprovalRequestEmail({
      applicantName: cleanName,
      empId: cleanId,
      applicantEmail: cleanEmail,
      role: assignedRole,
      shift: assignedShift,
      zone: resolvedZone,
      cnic: cleanCnic,
      requestedAt: nowIso,
      approveUrl,
      rejectUrl,
    });
  } catch (err) {
    console.error('[Nodemailer] Real Gmail SMTP dispatch failed:', err.message);
    emailDelivery = {
      sent: false,
      to: approverEmail,
      mode: 'error',
      error: err.message,
    };
  }

  // SECURITY: Never store approveUrl, rejectUrl, or previewUrl in emailLogs!
  db.emailLogs.unshift({
    id: `EML-${Date.now().toString().slice(-5)}`,
    to: approverEmail,
    subject: `[CPL HSE Approval Required] New Account Request: ${cleanName} (${cleanId})`,
    status: emailDelivery.sent ? `Delivered (${emailDelivery.mode})` : `Failed (${emailDelivery.error || 'SMTP error'})`,
    timestamp: nowIso,
  });

  writeDb(db);

  addAuditLog({
    actorId: cleanId,
    actorRole: assignedRole,
    action: 'STAFF_REGISTRATION_REQUESTED',
    targetResource: resolvedZone,
    details: emailDelivery.sent
      ? `Registration request submitted for ${cleanName} (${cleanId}). Real approval email delivered to HSE Manager (${approverEmail}).`
      : `Registration request saved as Pending for ${cleanName} (${cleanId}), but Gmail SMTP delivery failed: ${emailDelivery.error}`,
  });

  const safePending = { ...pendingEntry };
  delete safePending.passwordHash;
  delete safePending.approvalToken;

  if (!emailDelivery.sent) {
    return res.status(503).json({
      success: false,
      status: 'Pending',
      emailSent: false,
      message: `Registration for ${cleanId} was saved as Pending, but the approval email could not be sent to ${approverEmail} (${emailDelivery.error}). HSE Manager must configure Gmail App Password in Admin Panel -> Email Rules or backend/.env.`,
      pendingUser: safePending,
    });
  }

  // SECURITY: Zero approval links, zero tokens, zero preview URLs in response!
  return res.status(202).json({
    success: true,
    status: 'Pending',
    emailSent: true,
    message: `Registration request submitted for ${cleanId}! An official approval email has been sent directly to HSE Manager (Sumaira Rafique • ${approverEmail}). You can sign in once she confirms your request.`,
    pendingUser: safePending,
    emailDelivery: {
      sent: true,
      to: approverEmail,
      mode: emailDelivery.mode,
    },
  });
});

// =========================================================================
// 4. ONE-CLICK EMAIL APPROVAL / REJECTION ENDPOINT (Clicked inside Email)
// =========================================================================
router.get('/email-action', async (req, res) => {
  const { token, action } = req.query;
  const cleanAction = (action || '').toString().toLowerCase();

  if (!token || !['approve', 'reject'].includes(cleanAction)) {
    return res.status(400).send(renderActionHtml({
      ok: false,
      title: 'Invalid Approval Link',
      message: 'This approval link is malformed or missing required parameters.',
    }));
  }

  const db = readDb();
  if (!db.pendingUsers) db.pendingUsers = [];
  const pending = db.pendingUsers.find((p) => p.approvalToken && p.approvalToken === token);

  if (!pending) {
    return res.status(404).send(renderActionHtml({
      ok: false,
      title: 'Approval Link Expired or Already Used',
      message: 'This registration request could not be found or its link has expired.',
    }));
  }

  if (pending.status !== 'Pending') {
    return res.status(200).send(renderActionHtml({
      ok: pending.status === 'Approved',
      title: `Request Already ${pending.status}`,
      message: `Employee ${pending.fullName || pending.name} (${pending.empId}) was already marked as ${pending.status}.`,
    }));
  }

  const approverLabel = `${mailer.DEFAULT_HSE_APPROVER_NAME} (${mailer.getApproverEmail()})`;

  if (cleanAction === 'approve') {
    const activatedUser = activatePendingRegistration(db, pending, approverLabel, 'CPL-EMP-3648');
    delete pending.approvalToken; // Strictly single-use cryptographic token
    writeDb(db);

    if (activatedUser.email) {
      mailer.sendAccountStatusEmail({
        to: activatedUser.email,
        fullName: activatedUser.fullName || activatedUser.name,
        empId: activatedUser.employeeId,
        status: 'Approved',
        approverName: approverLabel,
      }).catch(() => {});
    }

    return res.status(200).send(renderActionHtml({
      ok: true,
      title: 'Account Approved & Created!',
      message: `Employee <strong>${activatedUser.name}</strong> (<code>${activatedUser.employeeId}</code> — ${activatedUser.role}) has been officially activated in the Chiniot Power HSE database. They can now sign in immediately with their registered password.`,
    }));
  }

  // Reject action
  pending.status = 'Rejected';
  pending.approvedBy = approverLabel;
  pending.approvedAt = new Date().toISOString();
  delete pending.approvalToken; // Strictly single-use cryptographic token
  writeDb(db);

  addAuditLog({
    actorId: 'CPL-EMP-3648',
    actorRole: 'HSE Manager',
    action: 'STAFF_ID_REJECTED',
    targetResource: pending.empId,
    details: `Registration for ${pending.name} (${pending.empId}) rejected via email by ${approverLabel}.`,
  });

  if (pending.email) {
    mailer.sendAccountStatusEmail({
      to: pending.email,
      fullName: pending.fullName || pending.name,
      empId: pending.empId,
      status: 'Rejected',
      approverName: approverLabel,
    }).catch(() => {});
  }

  return res.status(200).send(renderActionHtml({
    ok: false,
    title: 'Registration Request Rejected',
    message: `The access request for <strong>${pending.name}</strong> (<code>${pending.empId}</code>) has been rejected and no account was created.`,
  }));
});

function renderActionHtml({ ok, title, message }) {
  const accent = ok ? '#10b981' : '#ef4444';
  const badge = ok ? '✓ APPROVED & ACTIVATED' : '✕ REJECTED / NOTICE';
  return `<!DOCTYPE html>
<html>
<head><meta charset="UTF-8" /><title>${title} — Chiniot Power HSE</title></head>
<body style="margin:0;min-height:100vh;display:flex;align-items:center;justify-content:center;background:#0b1120;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;color:#f8fafc;padding:20px;">
  <div style="max-width:520px;width:100%;background:#111827;border:1px solid #1f2937;border-radius:18px;overflow:hidden;box-shadow:0 24px 60px rgba(0,0,0,0.45);">
    <div style="background:#0f172a;padding:22px 26px;border-bottom:1px solid #1f2937;">
      <div style="font-size:11px;font-weight:800;letter-spacing:1.2px;color:#f59e0b;">CHINIOT POWER LIMITED • 62.4 MW HSE SYSTEM</div>
      <div style="margin-top:8px;display:inline-block;padding:4px 10px;border-radius:20px;font-size:11px;font-weight:800;background:${accent}22;color:${accent};border:1px solid ${accent}66;">${badge}</div>
    </div>
    <div style="padding:26px;">
      <h1 style="margin:0 0 12px;font-size:22px;font-weight:800;">${title}</h1>
      <p style="margin:0 0 22px;font-size:14px;line-height:1.65;color:#cbd5e1;">${message}</p>
      <a href="http://127.0.0.1:8080" style="display:inline-block;background:${accent};color:#022c22;font-weight:800;font-size:13px;padding:11px 22px;border-radius:10px;text-decoration:none;">Open Chiniot Power HSE App →</a>
    </div>
  </div>
</body>
</html>`;
}

// =========================================================================
// 5. PENDING USERS & IN-APP MANAGER APPROVAL (Admin Panel)
// =========================================================================
router.get('/pending-users', (req, res) => {
  const db = readDb();
  const list = (db.pendingUsers || []).map((p) => {
    const copy = { ...p };
    delete copy.passwordHash;
    delete copy.approvalToken;
    return copy;
  });
  return res.json({
    success: true,
    approverEmail: mailer.getApproverEmail(),
    pendingUsers: list,
  });
});

router.put('/users/:empId/approve', authenticateToken, requireHseManager, async (req, res) => {
  const { empId } = req.params;
  const { status, approverId, approverName } = req.body || {};
  const newStatus = status || 'Approved';
  const cleanId = normalizeEmpId(empId);
  const approverLabel = approverName || approverId || mailer.DEFAULT_HSE_APPROVER_NAME;

  const db = readDb();
  if (!db.pendingUsers) db.pendingUsers = [];
  if (!db.users) db.users = [];

  const pending = db.pendingUsers.find(
    (p) => p.empId && normalizeEmpId(p.empId) === cleanId
  );

  let user = findUserById(db.users, cleanId);

  if (newStatus === 'Approved') {
    if (pending) {
      user = activatePendingRegistration(db, pending, approverLabel, approverId);
    } else if (user) {
      user.isActive = true;
      user.status = 'Approved';
      user.approvedBy = approverLabel;
      user.approvedAt = new Date().toISOString();
    }
  } else {
    if (pending) {
      pending.status = newStatus;
      pending.approvedBy = approverLabel;
      pending.approvedAt = new Date().toISOString();
    }
    if (user) {
      user.isActive = false;
      user.status = newStatus;
      user.approvedBy = approverLabel;
      user.approvedAt = new Date().toISOString();
    }
    addAuditLog({
      actorId: approverId || 'CPL-EMP-3648',
      actorRole: 'HSE Manager',
      action: 'STAFF_ID_BLOCKED',
      targetResource: cleanId,
      details: `Staff member ${cleanId} marked as ${newStatus} by ${approverLabel}.`,
    });
  }

  writeDb(db);

  const applicantEmail = (user && user.email) || (pending && pending.email);
  if (applicantEmail) {
    mailer.sendAccountStatusEmail({
      to: applicantEmail,
      fullName: (user && user.name) || (pending && pending.name) || cleanId,
      empId: cleanId,
      status: newStatus,
      approverName: approverLabel,
    }).catch(() => {});
  }

  return res.json({
    success: true,
    message: `Staff member ${cleanId} marked as ${newStatus}.`,
    user: user ? formatUserResponse(user) : null,
  });
});

// =========================================================================
// 6. PROFILE MANAGEMENT (Get Profile, Edit Details, Upload Avatar, Change Password)
// =========================================================================
router.get('/me', authenticateToken, (req, res) => {
  const db = readDb();
  const user = (db.users || []).find(
    (u) => u.id === req.user.id || normalizeEmpId(u.employeeId) === normalizeEmpId(req.user.employeeId)
  );
  if (!user) return res.status(404).json({ success: false, message: 'User not found.' });
  return res.json({ success: true, user: formatUserResponse(user) });
});

router.get('/profile', authenticateToken, (req, res) => {
  const db = readDb();
  const user = (db.users || []).find(
    (u) => u.id === req.user.id || normalizeEmpId(u.employeeId) === normalizeEmpId(req.user.employeeId)
  );
  if (!user) return res.status(404).json({ success: false, message: 'User not found.' });
  return res.json({ success: true, user: formatUserResponse(user) });
});

router.put('/profile', authenticateToken, (req, res) => {
  const { fullName, name, urduName, email, shift, assignedZone, zone, cnic, removeAvatar } = req.body || {};
  const db = readDb();
  const user = (db.users || []).find(
    (u) => u.id === req.user.id || normalizeEmpId(u.employeeId) === normalizeEmpId(req.user.employeeId)
  );
  if (!user) return res.status(404).json({ success: false, message: 'User account not found.' });

  const nextName = (fullName || name || '').toString().trim();
  if (nextName) {
    user.fullName = nextName;
    user.name = nextName;
    user.urduName = (urduName && urduName.toString().trim()) || user.urduName || nextName;
  }
  if (email !== undefined) user.email = email.toString().trim();
  if (shift !== undefined && shift.toString().trim()) user.shift = shift.toString().trim();
  if (cnic !== undefined && cnic.toString().trim()) user.cnic = cnic.toString().trim();

  const nextZone = (assignedZone || zone || '').toString().trim();
  if (nextZone) {
    user.assignedZone = nextZone;
    user.plantZone = nextZone;
    user.zone = nextZone;
  }
  if (removeAvatar === true) {
    user.profileImageUrl = null;
  }
  user.updatedAt = new Date().toISOString();

  // Mirror updated name & zone into active roster
  const rosterItem = (db.roster || []).find(
    (w) => w.empId && normalizeEmpId(w.empId) === normalizeEmpId(user.employeeId)
  );
  if (rosterItem) {
    rosterItem.name = user.name;
    rosterItem.ur = user.urduName || user.name;
    rosterItem.zone = user.assignedZone || rosterItem.zone;
  }

  writeDb(db);

  addAuditLog({
    actorId: user.employeeId,
    actorRole: user.role,
    action: 'USER_PROFILE_UPDATED',
    targetResource: user.employeeId,
    details: `Employee ${user.employeeId} updated profile details (${user.name}, ${user.assignedZone}).`,
  });

  return res.json({
    success: true,
    message: 'Profile updated successfully.',
    user: formatUserResponse(user),
  });
});

// POST /api/v1/auth/profile/avatar (Supports BOTH Multipart upload and Base64 JSON for Web/Mobile)
router.post('/profile/avatar', authenticateToken, upload.single('avatar'), (req, res) => {
  const db = readDb();
  const user = (db.users || []).find(
    (u) => u.id === req.user.id || normalizeEmpId(u.employeeId) === normalizeEmpId(req.user.employeeId)
  );
  if (!user) return res.status(404).json({ success: false, message: 'User account not found.' });

  let savedPublicUrl = null;

  if (req.file) {
    // Move uploaded multer file into uploads/avatars
    const safeId = normalizeEmpId(user.employeeId).replace(/[^A-Z0-9-]/g, '');
    const ext = path.extname(req.file.originalname || req.file.filename) || '.jpg';
    const destName = `avatar-${safeId}-${Date.now()}${ext}`;
    const destPath = path.join(AVATARS_DIR, destName);
    fs.renameSync(req.file.path, destPath);
    savedPublicUrl = `/uploads/avatars/${destName}`;
  } else if (req.body && req.body.imageBase64) {
    const raw = req.body.imageBase64.toString();
    const match = raw.match(/^data:image\/(png|jpeg|jpg|webp|gif);base64,(.+)$/i);
    const ext = match ? (match[1].toLowerCase() === 'jpeg' ? '.jpg' : `.${match[1].toLowerCase()}`) : '.png';
    const base64Data = match ? match[2] : raw;
    const buffer = Buffer.from(base64Data, 'base64');
    if (buffer.length > 5 * 1024 * 1024) {
      return res.status(400).json({ success: false, message: 'Profile image must be smaller than 5 MB.' });
    }
    const safeId = normalizeEmpId(user.employeeId).replace(/[^A-Z0-9-]/g, '');
    const destName = `avatar-${safeId}-${Date.now()}${ext}`;
    const destPath = path.join(AVATARS_DIR, destName);
    fs.writeFileSync(destPath, buffer);
    savedPublicUrl = `/uploads/avatars/${destName}`;
  } else {
    return res.status(400).json({ success: false, message: 'No image file or base64 image payload provided.' });
  }

  user.profileImageUrl = savedPublicUrl;
  user.updatedAt = new Date().toISOString();
  writeDb(db);

  addAuditLog({
    actorId: user.employeeId,
    actorRole: user.role,
    action: 'USER_AVATAR_UPDATED',
    targetResource: user.employeeId,
    details: `Employee ${user.employeeId} updated profile photo (${savedPublicUrl}).`,
  });

  return res.json({
    success: true,
    message: 'Profile photo updated successfully.',
    profileImageUrl: savedPublicUrl,
    user: formatUserResponse(user),
  });
});

// PUT /api/v1/auth/profile/password (Authenticated Secure Password Change)
router.put('/profile/password', authenticateToken, (req, res) => {
  const { currentPassword, newPassword } = req.body || {};
  if (!currentPassword || !newPassword) {
    return res.status(400).json({
      success: false,
      message: 'Both current password and new password are required.',
    });
  }
  if (newPassword.toString().trim().length < 4) {
    return res.status(400).json({
      success: false,
      message: 'New password must be at least 4 characters long.',
    });
  }

  const db = readDb();
  const user = (db.users || []).find(
    (u) => u.id === req.user.id || normalizeEmpId(u.employeeId) === normalizeEmpId(req.user.employeeId)
  );
  if (!user) return res.status(404).json({ success: false, message: 'User account not found.' });

  if (!verifyUserPassword(user, currentPassword.toString().trim())) {
    return res.status(401).json({
      success: false,
      message: 'Current password is incorrect.',
    });
  }

  user.passwordHash = bcrypt.hashSync(newPassword.toString().trim(), 10);
  // Remove legacy plaintext PIN once a secure password is set
  delete user.pin;
  user.passwordUpdatedAt = new Date().toISOString();
  writeDb(db);

  addAuditLog({
    actorId: user.employeeId,
    actorRole: user.role,
    action: 'USER_PASSWORD_CHANGED',
    targetResource: user.employeeId,
    details: `Employee ${user.employeeId} changed account password securely.`,
  });

  return res.json({
    success: true,
    message: 'Password updated successfully! Use your new password on your next sign-in.',
  });
});

// POST /api/v1/auth/pending-users/:empId/resend-approval (HSE Manager Only)
router.post('/pending-users/:empId/resend-approval', authenticateToken, requireHseManager, async (req, res) => {
  const cleanId = normalizeEmpId(req.params.empId);
  const db = readDb();
  const pending = (db.pendingUsers || []).find(
    (p) => p.empId && normalizeEmpId(p.empId) === cleanId && p.status === 'Pending'
  );
  if (!pending) {
    return res.status(404).json({ success: false, message: `No pending registration found for ${cleanId}.` });
  }

  const approvalToken = crypto.randomBytes(32).toString('hex');
  pending.approvalToken = approvalToken;
  const approverEmail = mailer.getApproverEmail();
  pending.approverEmail = approverEmail;
  const baseUrl = process.env.PUBLIC_BASE_URL || `${req.protocol}://${req.get('host')}`;
  const approveUrl = `${baseUrl}/api/v1/auth/email-action?token=${approvalToken}&action=approve`;
  const rejectUrl = `${baseUrl}/api/v1/auth/email-action?token=${approvalToken}&action=reject`;

  try {
    const result = await mailer.sendApprovalRequestEmail({
      applicantName: pending.fullName || pending.name,
      empId: cleanId,
      applicantEmail: pending.email || '',
      role: pending.role || 'Plant Worker',
      shift: pending.shift || 'General Shift (08:00 - 17:00)',
      zone: pending.assignedZone || pending.zone || 'Boiler Area (Unit 1 & 2)',
      cnic: pending.cnic || '33202-0000000-1',
      requestedAt: pending.createdAt || new Date().toISOString(),
      approveUrl,
      rejectUrl,
    });

    if (!db.emailLogs) db.emailLogs = [];
    db.emailLogs.unshift({
      id: `EML-${Date.now().toString().slice(-5)}`,
      to: approverEmail,
      subject: `[CPL HSE Approval Required] New Account Request: ${pending.fullName || pending.name} (${cleanId})`,
      status: `Delivered (${result.mode})`,
      timestamp: new Date().toISOString(),
    });
    writeDb(db);

    return res.json({
      success: true,
      message: `Approval email sent directly to ${approverEmail} for ${cleanId}.`,
    });
  } catch (err) {
    return res.status(503).json({
      success: false,
      message: `Could not deliver approval email via Gmail SMTP: ${err.message}`,
    });
  }
});

// =========================================================================
// 7. NODEMAILER SMTP CONFIGURATION & LIVE TEST ENDPOINTS (HSE Manager Only)
// =========================================================================
router.get('/smtp-config', authenticateToken, requireHseManager, (req, res) => {
  const cfg = mailer.getSmtpConfig();
  return res.json({
    success: true,
    smtp: {
      host: cfg.host,
      port: cfg.port,
      user: cfg.user,
      approverEmail: cfg.approverEmail,
      isConfigured: cfg.isConfigured,
      mode: cfg.isConfigured ? (cfg.host.includes('gmail') ? 'gmail-smtp' : 'custom-smtp') : 'not-configured',
    },
  });
});

router.post('/smtp-config', authenticateToken, requireHseManager, async (req, res) => {
  const { host, port, user, pass, approverEmail, sendTest } = req.body || {};
  const cleanUser = (user || '').toString().trim();
  const cleanPass = (pass || '').toString().replace(/\s+/g, '').trim();
  const current = mailer.getSmtpConfig();
  const effectivePass = cleanPass || current.pass;

  if (!cleanUser || !effectivePass) {
    return res.status(400).json({
      success: false,
      message: 'Gmail sender address (SMTP_USER) and 16-character Google App Password (SMTP_PASS) are required.',
    });
  }

  const candidateCfg = {
    host: (host || 'smtp.gmail.com').toString().trim(),
    port: parseInt(port || '587', 10) || 587,
    secure: (parseInt(port || '587', 10) || 587) === 465,
    user: cleanUser,
    pass: effectivePass,
    from: `Chiniot Power HSE <${cleanUser}>`,
    approverEmail: (approverEmail || current.approverEmail).toString().trim(),
    isConfigured: true,
  };

  try {
    // Verify real Gmail SMTP authentication BEFORE persisting!
    await mailer.verifySmtpConnection(candidateCfg);
    const saved = mailer.persistSmtpConfig({
      host: candidateCfg.host,
      port: String(candidateCfg.port),
      user: candidateCfg.user,
      pass: candidateCfg.pass,
      approverEmail: candidateCfg.approverEmail,
      from: candidateCfg.from,
    });
    let testResult = null;
    if (sendTest !== false) {
      testResult = await mailer.sendTestEmail(saved.approverEmail);
    }
    return res.json({
      success: true,
      message: `Gmail SMTP verified & saved! Real test email delivered to ${saved.approverEmail}.`,
      smtp: {
        host: saved.host,
        port: saved.port,
        user: saved.user,
        approverEmail: saved.approverEmail,
        isConfigured: saved.isConfigured,
        mode: saved.host.includes('gmail') ? 'gmail-smtp' : 'custom-smtp',
      },
      testResult,
    });
  } catch (err) {
    return res.status(400).json({
      success: false,
      message: `Gmail SMTP authentication failed: ${err.message}. Make sure 2-Step Verification is enabled and you entered a 16-character Google App Password.`,
    });
  }
});

router.post('/smtp-test', authenticateToken, requireHseManager, async (req, res) => {
  try {
    const result = await mailer.sendTestEmail(req.body?.to);
    return res.json({
      success: true,
      message: `Real test email delivered to ${result.to}!`,
      result,
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
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
    const user = db.users.find((u) => u.id === decoded.id && u.isActive !== false);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found or deactivated.' });
    }

    const tokens = generateTokens(user);
    return res.json({ success: true, ...tokens });
  });
});

module.exports = router;
