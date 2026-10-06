const request = require('supertest');
const { app } = require('../src/server');

describe('TaskPulse Integration Tests — REST API Endpoints', () => {
  test('GET / returns 200 with service metadata', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('healthy');
    expect(res.body.service).toBe('taskpulse-api');
    expect(res.body.author).toContain('Pranav Gupta');
  });

  test('GET /health returns 200 with UP status', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('UP');
    expect(Array.isArray(res.body.checks)).toBe(true);
  });

  test('GET /api/v1/metrics computes valid metrics query', async () => {
    const res = await request(app).get('/api/v1/metrics?completed=200&hours=10');
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.throughputTasksPerHour).toBe(20.00);
  });

  test('GET /api/v1/metrics handles invalid hours query', async () => {
    const res = await request(app).get('/api/v1/metrics?completed=200&hours=0');
    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
  });

  test('GET /api/v1/tasks returns list of tasks', async () => {
    const res = await request(app).get('/api/v1/tasks');
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.tasks.length).toBe(3);
  });
});
