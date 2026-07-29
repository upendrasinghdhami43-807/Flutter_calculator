import 'package:flutter_calce/core/expression_engine/complex_number.dart';
import 'package:flutter_calce/core/expression_engine/errors.dart';
import 'package:flutter_calce/core/expression_engine/fraction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Complex', () {
    test('multiplies two complex numbers', () {
      final result = const Complex(1, 2) * const Complex(3, 4);
      expect(result.real, -5);
      expect(result.imaginary, 10);
    });

    test('computes magnitude and phase for a point on the unit circle', () {
      const value = Complex(0, 1);
      expect(value.magnitude, closeTo(1, 1e-10));
      expect(value.phaseRadians, closeTo(1.5707963267948966, 1e-10));
    });

    test('rejects division by a zero complex number', () {
      expect(() => const Complex(1, 1) / Complex.zero, throwsA(isA<MathDomainException>()));
    });
  });

  group('Fraction', () {
    test('adds and auto-simplifies fractions', () {
      final result = Fraction(1, 2) + Fraction(1, 3);
      expect(result.numerator, 5);
      expect(result.denominator, 6);
    });

    test('simplifies a reducible fraction on construction', () {
      final fraction = Fraction(4, 8);
      expect(fraction.numerator, 1);
      expect(fraction.denominator, 2);
    });

    test('rejects a zero denominator', () {
      expect(() => Fraction(1, 0), throwsA(isA<MathDomainException>()));
    });
  });
}
