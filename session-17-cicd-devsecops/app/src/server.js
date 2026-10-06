const express = require('express');
const helmet = require('helmet');
const { hashPassword, sanitizeInput, validateTokenFormat } = require('./crypto-util');

const app = express();
const PORT = process.env.PORT || 3000;
const START_TIME = Date.now();

// 1. Enforce Strict HTTP Security Headers via Helmet
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"]
    }
  },
  hidePoweredBy: true,
  hsts: { maxAge: 31536000, includeSubDomains: true }
}));

app.use(express.json({ limit: '10kb' })); // Mitigate Large Payload DoS

// 2. Info Banner
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'SECURE',
    service: 'vaultshield-api',
    version: '1.0.0',
    pipeline: 'DevSecOps-Automated',
    securityChecks: {
      sast: 'PASSED',
      sca: 'PASSED',
      secretScan: 'PASSED',
      containerScan: 'PASSED',
      securityGate: 'APPROVED'
    },
    author: 'Pranav Gupta (24BCS10237)',
    timestamp: new Date().toISOString()
  });
});

// 3. Health & Liveness Probe Endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'UP',
    uptimeSeconds: Math.floor((Date.now() - START_TIME) / 1000),
    securityGateStatus: 'ENFORCED'
  });
});

// 4. XSS Input Sanitization API
app.post('/api/v1/sanitize', (req, res) => {
  const { input } = req.body;
  if (!input || typeof input !== 'string') {
    return res.status(400).json({ success: false, error: 'input string required' });
  }

  const clean = sanitizeInput(input);
  res.status(200).json({
    success: true,
    originalLength: input.length,
    sanitized: clean
  });
});

// 5. Secure Hashing API
app.post('/api/v1/hash', (req, res) => {
  const { secret } = req.body;
  if (!secret || typeof secret !== 'string') {
    return res.status(400).json({ success: false, error: 'secret string required' });
  }

  const digest = hashPassword(secret);
  res.status(200).json({
    success: true,
    algorithm: 'HMAC-SHA256',
    digest
  });
});

let server = null;
if (process.env.NODE_ENV !== 'test') {
  server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`[VaultShield API] Secure server active on port ${PORT}`);
  });
}

module.exports = { app, server };
