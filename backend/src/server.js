const express = require('express');
const cors = require('cors');
const path = require('path');
const morgan = require('morgan');

const authRoutes = require('./routes/auth');
const hazardsRoutes = require('./routes/hazards');
const checklistsRoutes = require('./routes/checklists');
const ptwRoutes = require('./routes/ptw');
const alarmsRoutes = require('./routes/alarms');
const rosterRoutes = require('./routes/roster');
const analyticsRoutes = require('./routes/analytics');
const auditRoutes = require('./routes/audit');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors({ origin: '*' }));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));
app.use(morgan('dev'));

// Static files for photo and voice note uploads
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ONLINE',
    system: 'Chiniot Power Limited (CPL) HSE Management System Backend Gateway',
    timestamp: new Date().toISOString(),
    unit: 'UNIT-1 62.4 MW Co-Gen Power Plant'
  });
});

// API Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/hazards', hazardsRoutes);
app.use('/api/v1/checklists', checklistsRoutes);
app.use('/api/v1/ptw', ptwRoutes);
app.use('/api/v1/alarms', alarmsRoutes);
app.use('/api/v1/roster', rosterRoutes);
app.use('/api/v1/analytics', analyticsRoutes);
app.use('/api/v1/audit', auditRoutes);

// Error Handler
app.use((err, req, res, next) => {
  console.error('Unhandled Server Error:', err);
  res.status(500).json({
    success: false,
    message: err.message || 'Internal Server Error'
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`================================================================`);
  console.log(` CPL HSE Backend API Gateway running on port ${PORT}`);
  console.log(` Health Check: http://localhost:${PORT}/health`);
  console.log(` Static Uploads: http://localhost:${PORT}/uploads`);
  console.log(` Target Plant: UNIT-1 62.4 MW (Chiniot, Punjab • 31.7204° N, 72.9791° E)`);
  console.log(`================================================================`);
});

module.exports = app;

