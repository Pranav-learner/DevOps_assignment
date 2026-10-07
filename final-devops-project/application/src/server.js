const express = require('express');
const helmet = require('helmet');
const crypto = require('crypto');
const os = require('os');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const DATA_DIR = process.env.DATA_DIR || path.join(os.tmpdir(), 'cloudnexus-data');

// Security middleware
app.use(helmet());
app.use(express.json());

// In-memory / persistence registry
let isReady = true;
const metrics = {
  requestsTotal: {},
  errorsTotal: 0
};

// Structured Logging & Tracing Middleware
app.use((req, res, next) => {
  const start = process.hrtime();
  const traceId = req.headers['x-trace-id'] || crypto.randomUUID();
  req.traceId = traceId;
  res.setHeader('X-Trace-ID', traceId);

  res.on('finish', () => {
    const diff = process.hrtime(start);
    const durationMs = (diff[0] * 1e3 + diff[1] * 1e-6).toFixed(2);
    const route = `${req.method} ${req.route ? req.route.path : req.path}`;
    
    metrics.requestsTotal[route] = (metrics.requestsTotal[route] || 0) + 1;
    if (res.statusCode >= 500) {
      metrics.errorsTotal++;
    }

    const log = {
      timestamp: new Date().toISOString(),
      level: res.statusCode >= 500 ? 'ERROR' : res.statusCode >= 400 ? 'WARN' : 'INFO',
      trace_id: traceId,
      method: req.method,
      path: req.path,
      status: res.statusCode,
      duration_ms: parseFloat(durationMs),
      client_ip: req.ip || req.connection.remoteAddress
    };
    console.log(JSON.stringify(log));
  });

  next();
});

// Root Information
app.get('/', (req, res) => {
  res.json({
    service: 'CloudNexus Platform API',
    version: '1.0.0',
    environment: process.env.APP_ENV || 'production',
    hostname: os.hostname(),
    uptime_seconds: Math.floor(process.uptime()),
    status: 'OPERATIONAL'
  });
});

// Liveness Probe Endpoint
app.get('/healthz', (req, res) => {
  res.status(200).json({
    status: 'UP',
    timestamp: new Date().toISOString(),
    uptime_seconds: Math.floor(process.uptime()),
    process_memory_mb: (process.memoryUsage().rss / 1024 / 1024).toFixed(2)
  });
});

// Readiness Probe Endpoint
app.get('/ready', (req, res) => {
  if (isReady) {
    res.status(200).json({ status: 'READY', service: 'CloudNexus Platform' });
  } else {
    res.status(503).json({ status: 'NOT_READY', reason: 'Service warmup in progress' });
  }
});

// Prometheus Metrics Exporter
app.get('/metrics', (req, res) => {
  const mem = process.memoryUsage();
  let text = '';
  text += '# HELP cloudnexus_uptime_seconds Total application uptime in seconds\n';
  text += '# TYPE cloudnexus_uptime_seconds gauge\n';
  text += `cloudnexus_uptime_seconds ${Math.floor(process.uptime())}\n\n`;

  text += '# HELP cloudnexus_memory_rss_bytes Resident Set Size in bytes\n';
  text += '# TYPE cloudnexus_memory_rss_bytes gauge\n';
  text += `cloudnexus_memory_rss_bytes ${mem.rss}\n\n`;

  text += '# HELP cloudnexus_http_requests_total Total HTTP requests handled\n';
  text += '# TYPE cloudnexus_http_requests_total counter\n';
  for (const [route, count] of Object.entries(metrics.requestsTotal)) {
    const [method, routePath] = route.split(' ');
    text += `cloudnexus_http_requests_total{method="${method}",path="${routePath}"} ${count}\n`;
  }
  text += '\n';

  text += '# HELP cloudnexus_http_errors_total Total 5xx server errors\n';
  text += '# TYPE cloudnexus_http_errors_total counter\n';
  text += `cloudnexus_http_errors_total ${metrics.errorsTotal}\n`;

  res.set('Content-Type', 'text/plain; version=0.0.4; charset=utf-8');
  res.send(text);
});

// Storage Persistence Endpoint (PVC testing)
app.post('/api/v1/data', (req, res) => {
  const { key, value } = req.body || {};
  if (!key || !value) {
    return res.status(400).json({ error: 'Key and value required' });
  }

  try {
    if (!fs.existsSync(DATA_DIR)) {
      fs.mkdirSync(DATA_DIR, { recursive: true });
    }
    const filePath = path.join(DATA_DIR, `${key}.json`);
    fs.writeFileSync(filePath, JSON.stringify({ key, value, updated: new Date().toISOString() }));
    res.status(201).json({ status: 'STORED', key, value });
  } catch (err) {
    res.status(500).json({ error: 'Storage write failure', details: err.message });
  }
});

app.get('/api/v1/data/:key', (req, res) => {
  try {
    const filePath = path.join(DATA_DIR, `${req.params.key}.json`);
    if (fs.existsSync(filePath)) {
      const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
      return res.json(data);
    }
    res.status(404).json({ error: 'Item not found' });
  } catch (err) {
    res.status(500).json({ error: 'Storage read failure', details: err.message });
  }
});

// CPU / Memory Stress Generator for HPA
app.post('/api/v1/stress', (req, res) => {
  const iterations = parseInt(req.query.iterations) || 200000;
  let result = 0;
  for (let i = 0; i < iterations; i++) {
    result += Math.sqrt(i) * Math.sin(i);
  }
  res.json({ status: 'STRESS_APPLIED', iterations, result });
});

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(JSON.stringify({
      timestamp: new Date().toISOString(),
      level: 'INFO',
      message: `CloudNexus Platform Server running on port ${PORT}`,
      env: process.env.APP_ENV || 'production'
    }));
  });
}

module.exports = app;
