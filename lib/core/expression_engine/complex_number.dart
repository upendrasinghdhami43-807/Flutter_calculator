import 'dart:math' as math;

import 'errors.dart';

/// A minimal immutable complex number type used by Pro-mode CMPLX
/// calculations and by polynomial root finding.
class Complex {
  const Complex(this.real, this.imaginary);

  static const Complex zero = Complex(0, 0);

  final double real;
  final double imaginary;

  Complex operator +(Complex other) => Complex(real + other.real, imaginary + other.imaginary);

  Complex operator -(Complex other) => Complex(real - other.real, imaginary - other.imaginary);

  Complex operator *(Complex other) => Complex(
    real * other.real - imaginary * other.imaginary,
    real * other.imaginary + imaginary * other.real,
  );

  Complex operator /(Complex other) {
    final denominator = other.real * other.real + other.imaginary * other.imaginary;
    if (denominator < 1e-15) {
      throw const MathDomainException('Cannot divide by a zero complex number.');
    }
    return Complex(
      (real * other.real + imaginary * other.imaginary) / denominator,
      (imaginary * other.real - real * other.imaginary) / denominator,
    );
  }

  double get magnitude => math.sqrt(real * real + imaginary * imaginary);

  double get phaseRadians => math.atan2(imaginary, real);

  bool get isApproximatelyReal => imaginary.abs() < 1e-6;

  static Complex fromPolar(double magnitude, double phaseRadians) =>
      Complex(magnitude * math.cos(phaseRadians), magnitude * math.sin(phaseRadians));

  @override
  String toString() {
    if (imaginary == 0) return _formatNumber(real);
    if (real == 0) return '${_formatNumber(imaginary)}i';
    final sign = imaginary < 0 ? '-' : '+';
    return '${_formatNumber(real)} $sign ${_formatNumber(imaginary.abs())}i';
  }

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsPrecision(8).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}
