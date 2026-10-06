const { hashPassword, sanitizeInput, validateTokenFormat } = require('../src/crypto-util');

describe('VaultShield Unit Tests — Cryptography & Sanitization', () => {
  test('hashPassword() generates deterministic HMAC-SHA256 hex string', () => {
    const hash1 = hashPassword('SecurePass123!');
    const hash2 = hashPassword('SecurePass123!');
    expect(hash1).toBe(hash2);
    expect(hash1).toHaveLength(64); // 256 bits = 64 hex characters
  });

  test('hashPassword() throws TypeError on non-string input', () => {
    expect(() => hashPassword(null)).toThrow(TypeError);
    expect(() => hashPassword(12345)).toThrow(TypeError);
  });

  test('sanitizeInput() strips HTML script tags and escapes special characters', () => {
    const malicious = '<script>alert("xss")</script>Hello & Welcome!';
    const cleaned = sanitizeInput(malicious);
    expect(cleaned).not.toContain('<script>');
    expect(cleaned).toContain('&amp;');
  });

  test('validateTokenFormat() accepts valid tokens and rejects invalid tokens', () => {
    const valid = 'vs_live_1234567890abcdef1234567890abcdef';
    const invalid = 'vs_test_badtoken';
    expect(validateTokenFormat(valid)).toBe(true);
    expect(validateTokenFormat(invalid)).toBe(false);
    expect(validateTokenFormat('')).toBe(false);
  });
});
