sealed class MathException implements Exception {
  const MathException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class MathParseException extends MathException {
  const MathParseException(super.message);
}

final class MathDomainException extends MathException {
  const MathDomainException(super.message);
}

final class MathEvaluationException extends MathException {
  const MathEvaluationException(super.message);
}
