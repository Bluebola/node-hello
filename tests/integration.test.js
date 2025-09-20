// ===== INTEGRATION TESTS =====
// These tests verify that the HTTP server works correctly end-to-end
// They test the complete request-response cycle

const http = require('http');
const request = require('supertest');
const { generateHTML } = require('../lib/htmlGenerator');

// Create a test server using the same logic as index.js
const createServer = () => {
  return http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/html');
    const html = generateHTML();
    res.end(html);
  });
};

describe('HTTP Server Integration Tests', () => {
  let server;

  beforeAll(() => {
    server = createServer();
  });

  test('should return 200 status code', async () => {
    const response = await request(server).get('/');
    expect(response.status).toBe(200);
  });

  test('should return HTML content type', async () => {
    const response = await request(server).get('/');
    expect(response.headers['content-type']).toBe('text/html');
  });

  test('should serve complete HTML page', async () => {
    const response = await request(server).get('/');
    expect(response.text).toContain('Hello World!');
    expect(response.text).toContain('Current Server Time:');
  });

  test('should handle multiple requests', async () => {
    const response1 = await request(server).get('/');
    const response2 = await request(server).get('/');
    
    expect(response1.status).toBe(200);
    expect(response2.status).toBe(200);
  });
});
