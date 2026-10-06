/**
 * Mathematical & business logic utility module for TaskPulse
 */

function add(a, b) {
  if (typeof a !== 'number' || typeof b !== 'number') {
    throw new TypeError('Both arguments must be numbers');
  }
  return a + b;
}

function calculateThroughput(completedTasks, timeInHours) {
  if (timeInHours <= 0) {
    throw new Error('Time in hours must be greater than zero');
  }
  return Number((completedTasks / timeInHours).toFixed(2));
}

function calculateAvailability(uptimeSeconds, totalSeconds) {
  if (totalSeconds <= 0) return 0;
  const ratio = (uptimeSeconds / totalSeconds) * 100;
  return Number(Math.min(100, Math.max(0, ratio)).toFixed(2));
}

module.exports = {
  add,
  calculateThroughput,
  calculateAvailability
};
