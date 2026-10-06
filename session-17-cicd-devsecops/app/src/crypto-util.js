const crypto = require('crypto');

/**
 * Cryptographic & Sanitization Utility for VaultShield API
 */

function hashPassword(password, salt = 'vaultshield-static-salt') {
  if (!password || typeof password !== 'string') {
    throw new TypeError('Password must be a non-empty string');
  }
  return crypto.createHmac('sha256', salt).update(password).digest('hex');
}

function sanitizeInput(input) {
  if (typeof input !== 'string') return '';
  // Strip potentially dangerous HTML/script tags (XSS defense)
  return input
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
    .replace(/[&<>"']/g, (match) => {
      const escapeChars = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#x27;'
      };
      return escapeChars[match];
    })
    .trim();
}

function validateTokenFormat(token) {
  if (!token || typeof token !== 'string') return false;
  // VaultShield tokens follow vs_live_[a-f0-9]{32}
  const tokenRegex = /^vs_live_[a-f0-9]{32}$/;
  return tokenRegex.test(token);
}

module.exports = {
  hashPassword,
  sanitizeInput,
  validateTokenFormat
};
