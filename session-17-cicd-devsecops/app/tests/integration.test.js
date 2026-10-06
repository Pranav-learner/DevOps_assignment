const request = require('supertest');
const { app } = require('../src/server');

describe('VaultShield Integration Tests — Secure Endpoints & Headers', () => {
  test('GET / enforces Helmet security headers and returns 200', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('SECURE');
    expect(res.body.service).toBe('vaultshield-api');
    // Security headers validation
    expect(res.headers['x-frame-options']).toBe('SAMEORIGIN');
    expect(res.headers['strict-transport-security']).toBeDefined();
    expect(res.headers['x-content-type-options']).toBe('nosniff');
  });

  test('GET /health returns 200 with UP status', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('UP');
    expect(res.body.securityGateStatus).toBe('ENFORCED');
  });

  test('POST /api/v1/sanitize sanitizes payload', async () => {
    const res = await request(app)
      .post('/api/v1/sanitize')
      .send({ input: '<script>alert(1)</script>Safe Content' });
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.sanitized).toBe('Safe Content');
  });

  test('POST /api/v1/hash computes HMAC-SHA256 digest', async () => {
    const res = await request(app)
      .post('/api/v1/hash')
      .send({ secret: 'TopSecretToken' });
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.algorithm).toBe('HMAC-SHA256');
    expect(res.body.digest).toHaveLength(64);
  });
});
