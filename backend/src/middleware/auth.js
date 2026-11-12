const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'ChiniotPowerHseSecretKey2026!SecuredIntranet';
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'ChiniotPowerHseRefreshSecretKey2026!';

function generateTokens(user) {
  const payload = {
    id: user.id,
    employeeId: user.employeeId,
    role: user.role,
    name: user.name,
    department: user.department
  };

  const accessToken = jwt.sign(payload, JWT_SECRET, { expiresIn: '8h' });
  const refreshToken = jwt.sign({ id: user.id, employeeId: user.employeeId }, JWT_REFRESH_SECRET, { expiresIn: '7d' });

  return { accessToken, refreshToken };
}

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ success: false, message: 'Authentication required. Missing Bearer token.' });
  }

  jwt.verify(token, JWT_SECRET, (err, decodedUser) => {
    if (err) {
      return res.status(403).json({ success: false, message: 'Invalid or expired token.' });
    }
    req.user = decodedUser;
    next();
  });
}

// Role-Based Access Control (RBAC) guard
function requireRoles(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ success: false, message: 'Authentication required.' });
    }
    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Access denied. Role '${req.user.role}' lacks permission. Required: [${allowedRoles.join(', ')}]`
      });
    }
    next();
  };
}

module.exports = {
  JWT_SECRET,
  JWT_REFRESH_SECRET,
  generateTokens,
  authenticateToken,
  requireRoles
};

