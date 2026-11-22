const nodemailer = require('nodemailer');
const fs = require('fs');
const path = require('path');

const ENV_FILE = path.join(__dirname, '../../.env');
const DEFAULT_HSE_APPROVER_EMAIL = 'muhammadsohaib.19477@gmail.com';
const DEFAULT_HSE_APPROVER_NAME = 'Sumaira Rafique (HSE Manager)';

// Ensure .env values are loaded even if mailer.js is required standalone
function loadEnvFileIntoProcess() {
  if (!fs.existsSync(ENV_FILE)) return;
  try {
    const raw = fs.readFileSync(ENV_FILE, 'utf8');
    for (const line of raw.split(/\r?\n/)) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith('#')) continue;
      const eq = trimmed.indexOf('=');
      if (eq === -1) continue;
      const key = trimmed.slice(0, eq).trim();
      let val = trimmed.slice(eq + 1).trim();
      if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
        val = val.slice(1, -1);
      }
      if (key && (process.env[key] === undefined || process.env[key] === '')) {
        process.env[key] = val;
      }
    }
  } catch (_) {}
}

loadEnvFileIntoProcess();

function getApproverEmail() {
  return (process.env.HSE_APPROVER_EMAIL || DEFAULT_HSE_APPROVER_EMAIL).trim();
}

function getSmtpConfig() {
  loadEnvFileIntoProcess();
  const host = (process.env.SMTP_HOST || 'smtp.gmail.com').trim();
  const port = parseInt(process.env.SMTP_PORT || '587', 10);
  const user = (process.env.SMTP_USER || '').trim();
  // Google displays 16-char App Passwords with spaces ("xxxx xxxx xxxx xxxx"); strip whitespace safely
  const pass = (process.env.SMTP_PASS || '').replace(/\s+/g, '').trim();
  const from = (process.env.SMTP_FROM || (user ? `Chiniot Power HSE <${user}>` : 'Chiniot Power HSE <noreply@chiniotpower.com.pk>')).trim();
  const approverEmail = getApproverEmail();
  const isConfigured = Boolean(user && pass && !pass.includes('replace-with'));
  return {
    host: host || 'smtp.gmail.com',
    port: Number.isNaN(port) ? 587 : port,
    secure: port === 465,
    user,
    pass,
    from,
    approverEmail,
    isConfigured,
  };
}

function persistSmtpConfig({ host, port, user, pass, approverEmail, from }) {
  const updates = {};
  if (host !== undefined) updates.SMTP_HOST = String(host).trim() || 'smtp.gmail.com';
  if (port !== undefined) updates.SMTP_PORT = String(port).trim() || '587';
  if (user !== undefined) updates.SMTP_USER = String(user).trim();
  if (pass !== undefined) {
    const cleanPass = String(pass).replace(/\s+/g, '').trim();
    if (cleanPass) updates.SMTP_PASS = cleanPass;
  }
  if (approverEmail !== undefined && String(approverEmail).trim()) {
    updates.HSE_APPROVER_EMAIL = String(approverEmail).trim();
  }
  if (from !== undefined && String(from).trim()) {
    updates.SMTP_FROM = String(from).trim();
  }

  let content = fs.existsSync(ENV_FILE) ? fs.readFileSync(ENV_FILE, 'utf8') : '';
  for (const [k, v] of Object.entries(updates)) {
    process.env[k] = v;
    const line = `${k}=${v}`;
    const regex = new RegExp(`^${k}=.*$`, 'm');
    if (regex.test(content)) {
      content = content.replace(regex, line);
    } else {
      content = content.trim() ? `${content.trim()}\n${line}\n` : `${line}\n`;
    }
  }
  fs.writeFileSync(ENV_FILE, content, 'utf8');
  return getSmtpConfig();
}

function buildTransporter(overrideCfg) {
  const cfg = overrideCfg || getSmtpConfig();

  if (!cfg.isConfigured) {
    const err = new Error(
      'Gmail SMTP is not configured. Set SMTP_USER and a 16-character Google App Password (SMTP_PASS) in backend/.env or Admin Control Panel -> Email Rules.'
    );
    err.code = 'SMTP_NOT_CONFIGURED';
    throw err;
  }

  const isGmail = cfg.host.toLowerCase().includes('gmail');
  const transportOptions = isGmail
    ? {
        service: 'gmail',
        host: 'smtp.gmail.com',
        port: cfg.port,
        secure: cfg.port === 465,
        requireTLS: cfg.port === 587,
        auth: {
          user: cfg.user,
          pass: cfg.pass,
        },
      }
    : {
        host: cfg.host,
        port: cfg.port,
        secure: cfg.secure,
        auth: {
          user: cfg.user,
          pass: cfg.pass,
        },
      };

  return {
    transporter: nodemailer.createTransport(transportOptions),
    from: cfg.from,
    mode: isGmail ? 'gmail-smtp' : 'custom-smtp',
  };
}

async function verifySmtpConnection(overrideCfg) {
  const { transporter, mode } = buildTransporter(overrideCfg);
  await transporter.verify();
  return { ok: true, mode };
}

function buildApprovalEmailHtml({
  applicantName,
  empId,
  applicantEmail,
  role,
  shift,
  zone,
  cnic,
  requestedAt,
  approveUrl,
  rejectUrl,
}) {
  return `
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8" /></head>
<body style="margin:0;padding:0;background:#f1f5f9;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;color:#0f172a;">
  <table width="100%" cellpadding="0" cellspacing="0" style="padding:28px 16px;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;overflow:hidden;border:1px solid #e2e8f0;box-shadow:0 6px 24px rgba(15,23,42,0.08);">
          <tr>
            <td style="background:#0b1628;padding:24px 28px;">
              <div style="font-size:11px;font-weight:800;letter-spacing:1.4px;color:#f59e0b;text-transform:uppercase;">CHINIOT POWER LIMITED • 62.4 MW CO-GEN PLANT</div>
              <h1 style="margin:6px 0 0;font-size:20px;color:#ffffff;font-weight:800;">New Staff Account Approval Request</h1>
              <p style="margin:6px 0 0;font-size:12.5px;color:#94a3b8;">Attention: ${DEFAULT_HSE_APPROVER_NAME}</p>
            </td>
          </tr>
          <tr>
            <td style="padding:26px 28px;">
              <p style="margin:0 0 16px;font-size:14px;line-height:1.6;color:#334155;">
                A new employee has requested access to the <strong>Chiniot Power HSE Management System</strong>. The account is strictly locked as <strong>Pending</strong> and cannot sign in until you approve this request.
              </p>
              <table width="100%" cellpadding="0" cellspacing="0" style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;padding:16px;margin-bottom:22px;font-size:13px;">
                <tr><td style="padding:6px 8px;color:#64748b;width:38%;"><strong>Employee Name</strong></td><td style="padding:6px 8px;color:#0f172a;font-weight:700;">${applicantName}</td></tr>
                <tr><td style="padding:6px 8px;color:#64748b;"><strong>Employee ID</strong></td><td style="padding:6px 8px;font-family:monospace;font-weight:700;color:#b45309;">${empId}</td></tr>
                <tr><td style="padding:6px 8px;color:#64748b;"><strong>Email Address</strong></td><td style="padding:6px 8px;color:#0f172a;">${applicantEmail || 'Not provided'}</td></tr>
                <tr><td style="padding:6px 8px;color:#64748b;"><strong>Requested Designation</strong></td><td style="padding:6px 8px;color:#0f172a;font-weight:600;">${role}</td></tr>
                <tr><td style="padding:6px 8px;color:#64748b;"><strong>Assigned Plant Zone</strong></td><td style="padding:6px 8px;color:#0f172a;">${zone}</td></tr>
                <tr><td style="padding:6px 8px;color:#64748b;"><strong>Duty Shift</strong></td><td style="padding:6px 8px;color:#0f172a;">${shift}</td></tr>
                <tr><td style="padding:6px 8px;color:#64748b;"><strong>CNIC / ID</strong></td><td style="padding:6px 8px;font-family:monospace;color:#0f172a;">${cnic}</td></tr>
                <tr><td style="padding:6px 8px;color:#64748b;"><strong>Requested At</strong></td><td style="padding:6px 8px;color:#475569;">${requestedAt}</td></tr>
              </table>

              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td align="center" style="padding:6px;">
                    <a href="${approveUrl}" style="display:inline-block;background:#059669;color:#ffffff;text-decoration:none;font-weight:800;font-size:14px;padding:13px 28px;border-radius:10px;">
                      ✓ Approve &amp; Activate Account
                    </a>
                  </td>
                  <td align="center" style="padding:6px;">
                    <a href="${rejectUrl}" style="display:inline-block;background:#dc2626;color:#ffffff;text-decoration:none;font-weight:700;font-size:14px;padding:13px 24px;border-radius:10px;">
                      ✕ Reject Request
                    </a>
                  </td>
                </tr>
              </table>

              <p style="margin:20px 0 0;font-size:11.5px;color:#64748b;line-height:1.5;">
                This email was sent exclusively to the authorized HSE Manager inbox. Do not forward these single-use action links.
              </p>
            </td>
          </tr>
          <tr>
            <td style="background:#f8fafc;border-top:1px solid #e2e8f0;padding:14px 28px;font-size:11px;color:#64748b;text-align:center;">
              Chiniot Power Limited • ISO 45001:2018 &amp; NEPRA HSE Compliance Gateway
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
}

async function sendApprovalRequestEmail({
  applicantName,
  empId,
  applicantEmail,
  role,
  shift,
  zone,
  cnic,
  requestedAt,
  approveUrl,
  rejectUrl,
}) {
  const toEmail = getApproverEmail();
  const subject = `[CPL HSE Approval Required] New Account Request: ${applicantName} (${empId})`;
  const html = buildApprovalEmailHtml({
    applicantName,
    empId,
    applicantEmail,
    role,
    shift,
    zone,
    cnic,
    requestedAt,
    approveUrl,
    rejectUrl,
  });

  const text = [
    `Chiniot Power Limited - HSE Account Approval Request`,
    `Attention: ${DEFAULT_HSE_APPROVER_NAME}`,
    ``,
    `Applicant: ${applicantName} (${empId})`,
    `Email: ${applicantEmail || 'Not provided'}`,
    `Designation: ${role}`,
    `Plant Zone: ${zone}`,
    `Shift: ${shift}`,
    `CNIC: ${cnic}`,
    ``,
    `APPROVE ACCOUNT: ${approveUrl}`,
    `REJECT REQUEST:  ${rejectUrl}`,
  ].join('\n');

  const { transporter, from, mode } = buildTransporter();
  const info = await transporter.sendMail({
    from,
    to: toEmail,
    subject,
    text,
    html,
  });

  console.log(`[Nodemailer] Real approval email delivered via ${mode} to ${toEmail} (MessageId: ${info.messageId})`);

  // SECURITY: Never return approveUrl, rejectUrl, or any preview link to API callers!
  return {
    sent: true,
    to: toEmail,
    subject,
    mode,
    messageId: info.messageId || null,
  };
}

async function sendAccountStatusEmail({ to, fullName, empId, status, approverName }) {
  if (!to || !to.includes('@')) return { sent: false, reason: 'No applicant email provided.' };
  const isApproved = status === 'Approved';
  const subject = isApproved
    ? `[CPL HSE] Account Approved & Activated — ${empId}`
    : `[CPL HSE] Registration Request Update — ${empId}`;

  const html = `
    <div style="font-family:sans-serif;max-width:560px;margin:0 auto;padding:24px;border:1px solid #e2e8f0;border-radius:14px;">
      <div style="background:#0b1628;color:#fff;padding:18px 20px;border-radius:10px;">
        <strong style="color:#f59e0b;font-size:11px;letter-spacing:1px;">CHINIOT POWER LIMITED • HSE SYSTEM</strong>
        <h2 style="margin:6px 0 0;font-size:18px;">${isApproved ? 'Your HSE Account Is Approved!' : 'Registration Request Rejected'}</h2>
      </div>
      <p style="margin:18px 0;font-size:14px;color:#334155;line-height:1.6;">
        Hello <strong>${fullName}</strong>,<br/><br/>
        ${
          isApproved
            ? `Your Employee ID <strong>${empId}</strong> has been approved by <strong>${approverName}</strong>. You may now sign in to the Chiniot Power HSE Management System with your registered password.`
            : `Your registration request for Employee ID <strong>${empId}</strong> was rejected by <strong>${approverName}</strong>. Please contact the HSE Department for assistance.`
        }
      </p>
    </div>
  `;

  try {
    const { transporter, from, mode } = buildTransporter();
    const info = await transporter.sendMail({ from, to, subject, html });
    return { sent: true, to, subject, mode, messageId: info.messageId };
  } catch (err) {
    return { sent: false, to, error: err.message };
  }
}

async function sendTestEmail(targetEmail) {
  const to = (targetEmail || getApproverEmail()).trim();
  const { transporter, from, mode } = buildTransporter();
  await transporter.verify();
  const info = await transporter.sendMail({
    from,
    to,
    subject: '[CPL HSE] Nodemailer Real Gmail SMTP Verified',
    html: `<div style="font-family:sans-serif;padding:20px;border:1px solid #e2e8f0;border-radius:12px;max-width:520px;">
      <h2 style="margin-top:0;color:#0b1628;">Chiniot Power HSE — Gmail SMTP Active</h2>
      <p style="color:#334155;font-size:14px;">Your Nodemailer gateway is now delivering real approval emails directly to <strong>${to}</strong> via <code>${mode}</code>.</p>
    </div>`,
  });
  return {
    sent: true,
    to,
    mode,
    messageId: info.messageId,
  };
}

module.exports = {
  DEFAULT_HSE_APPROVER_EMAIL,
  DEFAULT_HSE_APPROVER_NAME,
  getApproverEmail,
  getSmtpConfig,
  persistSmtpConfig,
  verifySmtpConnection,
  sendApprovalRequestEmail,
  sendAccountStatusEmail,
  sendTestEmail,
};
