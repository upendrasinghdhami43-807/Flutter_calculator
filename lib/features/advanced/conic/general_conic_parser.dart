import '../../../core/expression_engine/errors.dart';

class ConicCoefficients {
  const ConicCoefficients(this.a, this.b, this.c, this.d, this.e, this.f);

  final double a;
  final double b;
  final double c;
  final double d;
  final double e;
  final double f;
}

/// Parses the practical canonical entry format used by the Graph Finder,
/// such as `9x^2 + 4y^2 - 36 = 0` or `x² - 4y = 0`. Terms may appear in any
/// order; coefficients omitted before a variable are interpreted as 1.
class GeneralConicParser {
  const GeneralConicParser();

  ConicCoefficients parse(String source) {
    final normalized = source
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('²', '^2')
        .replaceAll('×', '*')
        .replaceAll('*', '');
    final parts = normalized.split('=');
    if (parts.length != 2 || parts[1] != '0') {
      throw const MathParseException('Enter a second-degree equation in the form Ax² + Bxy + Cy² + Dx + Ey + F = 0.');
    }
    final left = parts.first;
    if (left.isEmpty) throw const MathParseException('Enter a second-degree equation.');
    final signedTerms = RegExp(r'[+-]?[^+-]+').allMatches(left.startsWith('+') || left.startsWith('-') ? left : '+$left');
    var a = 0.0, b = 0.0, c = 0.0, d = 0.0, e = 0.0, f = 0.0;
    for (final match in signedTerms) {
      final term = match.group(0)!;
      if (term == '+' || term == '-') continue;
      if (term.endsWith('x^2')) {
        a += _coefficient(term.substring(0, term.length - 3));
      } else if (term.endsWith('xy') || term.endsWith('yx')) {
        b += _coefficient(term.substring(0, term.length - 2));
      } else if (term.endsWith('y^2')) {
        c += _coefficient(term.substring(0, term.length - 3));
      } else if (term.endsWith('x')) {
        d += _coefficient(term.substring(0, term.length - 1));
      } else if (term.endsWith('y')) {
        e += _coefficient(term.substring(0, term.length - 1));
      } else {
        f += _number(term);
      }
    }
    if (a == 0 && b == 0 && c == 0) {
      throw const MathParseException('The equation must include at least one squared term.');
    }
    return ConicCoefficients(a, b, c, d, e, f);
  }

  double _coefficient(String source) {
    if (source.isEmpty || source == '+') return 1;
    if (source == '-') return -1;
    return _number(source);
  }

  double _number(String source) {
    final value = double.tryParse(source);
    if (value == null) throw MathParseException('Could not read “$source” as a coefficient.');
    return value;
  }
}
