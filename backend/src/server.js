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

const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*' }
});

const PORT = process.env.PORT || 5000;

// Attach Socket.io to Express App
app.set('io', io);

io.on('connection', (socket) => {
  console.log(`[Socket.io] Real-time Plant telemetry client connected: ${socket.id}`);
  socket.on('disconnect', () => {
    console.log(`[Socket.io] Client disconnected: ${socket.id}`);
  });
});

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
    unit: 'UNIT-1 62.4 MW Co-Gen Power Plant',
    socketClients: io.engine.clientsCount
  });
});

// Dual API Route Mount: /api/v1 and /api
const registerRoutes = (prefix) => {
  app.use(`${prefix}/auth`, authRoutes);
  app.use(`${prefix}/hazards`, hazardsRoutes);
  app.use(`${prefix}/checklists`, checklistsRoutes);
  app.use(`${prefix}/ptw`, ptwRoutes);
  app.use(`${prefix}/alarms`, alarmsRoutes);
  app.use(`${prefix}/roster`, rosterRoutes);
  app.use(`${prefix}/analytics`, analyticsRoutes);
  app.use(`${prefix}/audit`, auditRoutes);
};

registerRoutes('/api/v1');
registerRoutes('/api');

// Error Handler
app.use((err, req, res, next) => {
  console.error('Unhandled Server Error:', err);
  res.status(500).json({
    success: false,
    message: err.message || 'Internal Server Error'
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`================================================================`);
  console.log(` CPL HSE Backend API Gateway running on port ${PORT}`);
  console.log(` Health Check: http://localhost:${PORT}/health`);
  console.log(` Static Uploads: http://localhost:${PORT}/uploads`);
  console.log(` Target Plant: UNIT-1 62.4 MW (Chiniot, Punjab • 31.7204° N, 72.9791° E)`);
  console.log(` Socket.io Gateway Active on port ${PORT}`);
  console.log(`================================================================`);
});

module.exports = { app, server };

