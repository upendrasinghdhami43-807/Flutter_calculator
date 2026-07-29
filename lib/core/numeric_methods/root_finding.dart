import '../expression_engine/errors.dart';

class RootFinding {
  const RootFinding();

  double bisection(
    double Function(double) function,
    double lower,
    double upper, {
    double tolerance = 1e-8,
    int maxIterations = 100,
  }) {
    var low = lower;
    var high = upper;
    var lowValue = function(low);
    if (lowValue * function(high) > 0) {
      throw const MathDomainException('Bisection needs an interval with a sign change.');
    }
    for (var iteration = 0; iteration < maxIterations; iteration++) {
      final middle = (low + high) / 2;
      final middleValue = function(middle);
      if (middleValue.abs() < tolerance || (high - low).abs() < tolerance) return middle;
      if (lowValue * middleValue < 0) {
        high = middle;
      } else {
        low = middle;
        lowValue = middleValue;
      }
    }
    throw const MathEvaluationException('Bisection did not converge.');
  }
}
