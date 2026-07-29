import '../linear_algebra/matrix.dart';
import 'conic_result.dart';

/// Result of classifying a general second-degree equation
/// `A·x² + B·x·y + C·y² + D·x + E·y + F = 0` before any rotation/translation
/// is attempted.
class ConicClassification {
  const ConicClassification({required this.type, required this.isDegenerate, this.degeneracyMessage});

  final ConicType type;
  final bool isDegenerate;
  final String? degeneracyMessage;
}

/// Implements the classification half of the SuperCalc conic auto-detect
/// algorithm: a degeneracy check via the 3x3 matrix determinant, followed by
/// discriminant-based shape classification.
class ConicClassifier {
  const ConicClassifier({this.tolerance = 1e-6});

  final double tolerance;

  ConicClassification classify(double a, double b, double c, double d, double e, double f) {
    final degeneracyDeterminant = Matrix([
      [a, b / 2, d / 2],
      [b / 2, c, e / 2],
      [d / 2, e / 2, f],
    ]).determinant();

    final discriminant = b * b - 4 * a * c;

    if (degeneracyDeterminant.abs() < tolerance) {
      return ConicClassification(
        type: ConicType.degenerate,
        isDegenerate: true,
        degeneracyMessage: _degeneracyMessage(discriminant),
      );
    }

    if (discriminant < -tolerance) {
      final isCircle = b.abs() < tolerance && (a - c).abs() < tolerance;
      return ConicClassification(type: isCircle ? ConicType.circle : ConicType.ellipse, isDegenerate: false);
    }
    if (discriminant.abs() <= tolerance) {
      return const ConicClassification(type: ConicType.parabola, isDegenerate: false);
    }
    final isRectangular = (a + c).abs() < tolerance;
    return ConicClassification(
      type: isRectangular ? ConicType.rectangularHyperbola : ConicType.hyperbola,
      isDegenerate: false,
    );
  }

  String _degeneracyMessage(double discriminant) {
    if (discriminant < -tolerance) return 'This is a degenerate ellipse-type conic: a single point or no real locus.';
    if (discriminant.abs() <= tolerance) return 'This is a degenerate parabola-type conic: a pair of parallel lines (or none).';
    return 'This is a degenerate hyperbola-type conic: a pair of intersecting lines.';
  }
}
