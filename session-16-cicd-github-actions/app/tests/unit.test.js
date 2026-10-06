const { add, calculateThroughput, calculateAvailability } = require('../src/math');

describe('TaskPulse Unit Tests — Math & Business Logic', () => {
  test('add() should sum two numbers correctly', () => {
    expect(add(10, 25)).toBe(35);
    expect(add(-5, 5)).toBe(0);
  });

  test('add() should throw TypeError if arguments are not numbers', () => {
    expect(() => add('10', 20)).toThrow(TypeError);
    expect(() => add(10, null)).toThrow(TypeError);
  });

  test('calculateThroughput() computes tasks per hour correctly', () => {
    expect(calculateThroughput(100, 4)).toBe(25.00);
    expect(calculateThroughput(15, 2)).toBe(7.50);
  });

  test('calculateThroughput() throws Error if hours <= 0', () => {
    expect(() => calculateThroughput(10, 0)).toThrow('Time in hours must be greater than zero');
    expect(() => calculateThroughput(10, -2)).toThrow('Time in hours must be greater than zero');
  });

  test('calculateAvailability() returns correct SLA percentage', () => {
    expect(calculateAvailability(3600, 3600)).toBe(100.00);
    expect(calculateAvailability(1800, 3600)).toBe(50.00);
    expect(calculateAvailability(0, 100)).toBe(0.00);
  });
});
