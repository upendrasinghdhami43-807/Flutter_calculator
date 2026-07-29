import '../expression_engine/errors.dart';

class NumericIntegration {
  const NumericIntegration();

  double simpson(double Function(double) function, double lower, double upper, {int intervals = 100}) {
    if (intervals <= 0 || intervals.isOdd) {
      throw const MathDomainException('Simpson integration requires a positive even interval count.');
    }
    final step = (upper - lower) / intervals;
    var total = function(lower) + function(upper);
    for (var index = 1; index < intervals; index++) {
      total += (index.isOdd ? 4 : 2) * function(lower + index * step);
    }
    return total * step / 3;
  }
}
