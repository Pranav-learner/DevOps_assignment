const request = require('supertest');
const app = require('../src/server');

describe('CloudNexus Platform API Test Suite', () => {
  it('GET / should return operational status', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.body.service).toBe('CloudNexus Platform API');
    expect(res.body.status).toBe('OPERATIONAL');
  });

  it('GET /healthz should return UP status for liveness probe', async () => {
    const res = await request(app).get('/healthz');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('UP');
    expect(res.body).toHaveProperty('uptime_seconds');
  });

  it('GET /ready should return READY status for readiness probe', async () => {
    const res = await request(app).get('/ready');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('READY');
  });

  it('GET /metrics should return Prometheus metrics exposition', async () => {
    const res = await request(app).get('/metrics');
    expect(res.statusCode).toBe(200);
    expect(res.text).toContain('cloudnexus_uptime_seconds');
    expect(res.text).toContain('cloudnexus_http_requests_total');
  });

  it('POST /api/v1/data should store and retrieve data', async () => {
    const storeRes = await request(app)
      .post('/api/v1/data')
      .send({ key: 'config-test', value: 'verified' });
    expect(storeRes.statusCode).toBe(201);
    expect(storeRes.body.status).toBe('STORED');

    const getRes = await request(app).get('/api/v1/data/config-test');
    expect(getRes.statusCode).toBe(200);
    expect(getRes.body.value).toBe('verified');
  });

  it('POST /api/v1/stress should compute workload for HPA', async () => {
    const res = await request(app).post('/api/v1/stress?iterations=1000');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('STRESS_APPLIED');
  });
});
