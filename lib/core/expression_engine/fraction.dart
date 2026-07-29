import 'errors.dart';

/// An exact fraction type, auto-simplified via GCD reduction, used by
/// Pro-mode fraction-mode arithmetic.
class Fraction {
  factory Fraction(int numerator, int denominator) {
    if (denominator == 0) {
      throw const MathDomainException('Fraction denominator cannot be zero.');
    }
    var n = numerator;
    var d = denominator;
    if (d < 0) {
      n = -n;
      d = -d;
    }
    final divisor = _gcd(n.abs(), d);
    final commonDivisor = divisor == 0 ? 1 : divisor;
    return Fraction._(n ~/ commonDivisor, d ~/ commonDivisor);
  }

  const Fraction._(this.numerator, this.denominator);

  final int numerator;
  final int denominator;

  static int _gcd(int a, int b) => b == 0 ? (a == 0 ? 1 : a) : _gcd(b, a % b);

  Fraction operator +(Fraction other) =>
      Fraction(numerator * other.denominator + other.numerator * denominator, denominator * other.denominator);

  Fraction operator -(Fraction other) =>
      Fraction(numerator * other.denominator - other.numerator * denominator, denominator * other.denominator);

  Fraction operator *(Fraction other) => Fraction(numerator * other.numerator, denominator * other.denominator);

  Fraction operator /(Fraction other) {
    if (other.numerator == 0) {
      throw const MathDomainException('Cannot divide by a zero fraction.');
    }
    return Fraction(numerator * other.denominator, denominator * other.numerator);
  }

  double toDouble() => numerator / denominator;

  @override
  String toString() => denominator == 1 ? '$numerator' : '$numerator/$denominator';

  @override
  bool operator ==(Object other) =>
      other is Fraction && other.numerator == numerator && other.denominator == denominator;

  @override
  int get hashCode => Object.hash(numerator, denominator);
}
