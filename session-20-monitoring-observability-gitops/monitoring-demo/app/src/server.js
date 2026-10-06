const express = require('express');
const crypto = require('crypto');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Application Metrics Registry
const metrics = {
  requestsTotal: {
    'GET /': 0,
    'GET /healthz': 0,
    'GET /metrics': 0,
    'POST /simulate/load': 0,
    'POST /simulate/error': 0
  },
  errorsTotal: 0,
  alertsTriggered: 0,
  lastCpuUsage: 0,
  syntheticMemoryPool: []
};

// Structured JSON Logging Middleware
app.use((req, res, next) => {
  const start = process.hrtime();
  const traceId = req.headers['x-trace-id'] || crypto.randomUUID();
  req.traceId = traceId;
  res.setHeader('X-Trace-ID', traceId);

  res.on('finish', () => {
    const diff = process.hrtime(start);
    const durationMs = (diff[0] * 1e3 + diff[1] * 1e-6).toFixed(2);
    const routeKey = `${req.method} ${req.route ? req.route.path : req.path}`;
    
    if (metrics.requestsTotal[routeKey] !== undefined) {
      metrics.requestsTotal[routeKey]++;
    }

    const logEntry = {
      timestamp: new Date().toISOString(),
      level: res.statusCode >= 500 ? 'ERROR' : res.statusCode >= 400 ? 'WARN' : 'INFO',
      trace_id: traceId,
      method: req.method,
      path: req.path,
      status: res.statusCode,
      duration_ms: parseFloat(durationMs),
      client_ip: req.ip || req.connection.remoteAddress
    };

    console.log(JSON.stringify(logEntry));
  });

  next();
});

// Root Information Endpoint
app.get('/', (req, res) => {
  res.json({
    service: 'PulseWatch Observability API',
    version: '1.0.0',
    hostname: os.hostname(),
    uptime_seconds: Math.floor(process.uptime()),
    status: 'OPERATIONAL'
  });
});

// Application Health Endpoint (Liveness & Readiness)
app.get('/healthz', (req, res) => {
  const memUsage = process.memoryUsage();
  const memoryRssMb = (memUsage.rss / 1024 / 1024).toFixed(2);
  const memoryHeapUsedMb = (memUsage.heapUsed / 1024 / 1024).toFixed(2);
  const loadAvg = os.loadavg();

  // Synthetic health determination
  const isHealthy = memUsage.heapUsed < 400 * 1024 * 1024; // Healthy if heap < 400MB

  const healthData = {
    status: isHealthy ? 'UP' : 'DEGRADED',
    timestamp: new Date().toISOString(),
    uptime_seconds: Math.floor(process.uptime()),
    system: {
      hostname: os.hostname(),
      load_avg_1m: loadAvg[0].toFixed(2),
      cpu_count: os.cpus().length,
      free_mem_mb: (os.freemem() / 1024 / 1024).toFixed(2)
    },
    process_memory: {
      rss_mb: parseFloat(memoryRssMb),
      heap_used_mb: parseFloat(memoryHeapUsedMb)
    }
  };

  res.status(isHealthy ? 200 : 503).json(healthData);
});

// Prometheus Metrics Exporter Endpoint
app.get('/metrics', (req, res) => {
  const memUsage = process.memoryUsage();
  const cpus = os.cpus();
  const uptime = Math.floor(process.uptime());

  let output = '';
  output += '# HELP pulsewatch_uptime_seconds Total application uptime in seconds\n';
  output += '# TYPE pulsewatch_uptime_seconds gauge\n';
  output += `pulsewatch_uptime_seconds ${uptime}\n\n`;

  output += '# HELP pulsewatch_memory_rss_bytes Resident Set Size memory usage in bytes\n';
  output += '# TYPE pulsewatch_memory_rss_bytes gauge\n';
  output += `pulsewatch_memory_rss_bytes ${memUsage.rss}\n\n`;

  output += '# HELP pulsewatch_memory_heap_bytes Memory heap used in bytes\n';
  output += '# TYPE pulsewatch_memory_heap_bytes gauge\n';
  output += `pulsewatch_memory_heap_bytes ${memUsage.heapUsed}\n\n`;

  output += '# HELP pulsewatch_http_requests_total Cumulative count of HTTP requests handled\n';
  output += '# TYPE pulsewatch_http_requests_total counter\n';
  for (const [route, count] of Object.entries(metrics.requestsTotal)) {
    const [method, path] = route.split(' ');
    output += `pulsewatch_http_requests_total{method="${method}",path="${path}"} ${count}\n`;
  }
  output += '\n';

  output += '# HELP pulsewatch_http_errors_total Cumulative HTTP 5xx errors encountered\n';
  output += '# TYPE pulsewatch_http_errors_total counter\n';
  output += `pulsewatch_http_errors_total ${metrics.errorsTotal}\n\n`;

  output += '# HELP pulsewatch_alerts_triggered_total Count of high threshold alerts fired\n';
  output += '# TYPE pulsewatch_alerts_triggered_total counter\n';
  output += `pulsewatch_alerts_triggered_total ${metrics.alertsTriggered}\n`;

  res.set('Content-Type', 'text/plain; version=0.0.4; charset=utf-8');
  res.send(output);
});

// CPU & Memory Load Simulator
app.post('/simulate/load', (req, res) => {
  const intensity = parseInt(req.query.intensity) || 200000;
  
  // 1. CPU intensive calculations
  let sum = 0;
  for (let i = 0; i < intensity; i++) {
    sum += Math.sqrt(i) * Math.sin(i);
  }

  // 2. Memory intensive buffer allocation
  const chunk = crypto.randomBytes(512 * 1024); // 512KB buffer
  metrics.syntheticMemoryPool.push(chunk);
  if (metrics.syntheticMemoryPool.length > 50) {
    metrics.syntheticMemoryPool.shift(); // Bound memory pool to avoid hard crash
  }

  // Check alert condition (e.g. if memory heap > 100MB)
  const heapMb = process.memoryUsage().heapUsed / 1024 / 1024;
  let alertTriggered = false;
  if (heapMb > 100) {
    metrics.alertsTriggered++;
    alertTriggered = true;
  }

  res.json({
    status: 'LOAD_APPLIED',
    iterations: intensity,
    heap_used_mb: heapMb.toFixed(2),
    alert_triggered: alertTriggered,
    active_memory_buffers: metrics.syntheticMemoryPool.length
  });
});

// Error Simulator for Error Rate & Alert Testing
app.post('/simulate/error', (req, res) => {
  metrics.errorsTotal++;
  metrics.alertsTriggered++;
  
  console.error(JSON.stringify({
    timestamp: new Date().toISOString(),
    level: 'CRITICAL',
    trace_id: req.traceId,
    error: 'DatabaseConnectionTimeout',
    message: 'Simulated downstream connection timeout triggering HighErrorRate alert'
  }));

  res.status(500).json({
    error: 'InternalServerError',
    message: 'Synthetic failure induced for alert simulation',
    trace_id: req.traceId
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(JSON.stringify({
    timestamp: new Date().toISOString(),
    level: 'INFO',
    message: `PulseWatch Observability Server running on port ${PORT}`,
    environment: process.env.NODE_ENV || 'production'
  }));
});
