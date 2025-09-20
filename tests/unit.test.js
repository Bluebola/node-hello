// ===== SIMPLE UNIT TESTS (No HTTP server needed) =====
const { generateHTML } = require('../lib/htmlGenerator');

describe('HTML Generator Unit Tests', () => {
  
  test('generateHTML returns a string', () => {
    const html = generateHTML();
    expect(typeof html).toBe('string');
  });

  test('generateHTML contains Hello World heading', () => {
    const html = generateHTML();
    expect(html).toContain('<h1>Hello World!</h1>');
  });

  test('generateHTML contains time display elements', () => {
    const html = generateHTML();
    expect(html).toContain('Current Server Time:');
    expect(html).toContain('class="time-box"');
  });

  test('generateHTML contains current time', () => {
    const html = generateHTML();
    // Check that some time format is present
    expect(html).toMatch(/\d{1,2}[\/\-\.:\s]/); // Basic time pattern
  });

  test('generateHTML contains proper HTML structure', () => {
    const html = generateHTML();
    expect(html).toContain('<!DOCTYPE html>');
    expect(html).toContain('<html>');
    expect(html).toContain('</html>');
  });

  test('generateHTML includes CSS styling', () => {
    const html = generateHTML();
    expect(html).toContain('<style>');
    expect(html).toContain('linear-gradient');
  });
});

// ===== EXPLANATION =====
// These are PURE UNIT TESTS - no server, no HTTP requests
// We test the generateHTML() function directly like any other function
// This is probably more like what you're used to in your CI/CD pipeline
