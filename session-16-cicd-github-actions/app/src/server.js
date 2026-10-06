const express = require('express');
const { calculateThroughput, calculateAvailability } = require('./math');

const app = express();
const PORT = process.env.PORT || 3000;
const START_TIME = Date.now();

app.use(express.json());

// 1. Root Information Banner
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'taskpulse-api',
    environment: process.env.NODE_ENV || 'production',
    version: '1.0.0',
    build: process.env.BUILD_NUMBER || 'ci-local-101',
    author: 'Pranav Gupta (24BCS10237)',
    timestamp: new Date().toISOString()
  });
});

// 2. Kubernetes Health & Readiness Probe
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'UP',
    uptimeSeconds: Math.floor((Date.now() - START_TIME) / 1000),
    checks: [
      { name: 'database', status: 'connected' },
      { name: 'memory', status: 'healthy' }
    ]
  });
});

// 3. Business Logic API: Metrics Calculation
app.get('/api/v1/metrics', (req, res) => {
  const completed = parseInt(req.query.completed || '120', 10);
  const hours = parseFloat(req.query.hours || '8');

  try {
    const throughput = calculateThroughput(completed, hours);
    const availability = calculateAvailability(7190, 7200);

    res.status(200).json({
      success: true,
      data: {
        completedTasks: completed,
        durationHours: hours,
        throughputTasksPerHour: throughput,
        serviceAvailabilityPercent: availability
      }
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      error: err.message
    });
  }
});

// 4. Tasks list endpoint
app.get('/api/v1/tasks', (req, res) => {
  res.status(200).json({
    success: true,
    total: 3,
    tasks: [
      { id: 1, title: 'Build CI Pipeline', status: 'COMPLETED' },
      { id: 2, title: 'Execute Docker Image Build', status: 'COMPLETED' },
      { id: 3, title: 'Deploy to Kubernetes Cluster', status: 'IN_PROGRESS' }
    ]
  });
});

let server = null;
if (process.env.NODE_ENV !== 'test') {
  server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`[TaskPulse API] Server running on http://0.0.0.0:${PORT}`);
  });
}

module.exports = { app, server };
