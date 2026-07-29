import 'package:flutter_calce/core/expression_engine/errors.dart';
import 'package:flutter_calce/features/advanced/conic/general_conic_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = GeneralConicParser();

  test('parses a canonical ellipse equation', () {
    final values = parser.parse('9x² + 4y² - 36 = 0');
    expect(values.a, 9);
    expect(values.b, 0);
    expect(values.c, 4);
    expect(values.f, -36);
  });

  test('parses omitted unit coefficients and a linear y term', () {
    final values = parser.parse('x^2 - 4y = 0');
    expect(values.a, 1);
    expect(values.e, -4);
  });

  test('rejects an equation not normalized to zero', () {
    expect(() => parser.parse('x² + y² = 4'), throwsA(isA<MathParseException>()));
  });
}
