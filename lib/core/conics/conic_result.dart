/// A point in the conic's original (un-rotated, un-translated) coordinate
/// system — the same coordinate system the user typed their equation in.
class Point2D {
  const Point2D(this.x, this.y);

  final double x;
  final double y;

  @override
  String toString() => '(${_format(x)}, ${_format(y)})';

  static String _format(double value) {
    if (value.isNaN) return '—';
    if ((value - value.roundToDouble()).abs() < 1e-9) return value.round().toString();
    return value.toStringAsPrecision(6).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}

/// A finite line segment used to draw directrices/asymptotes on the graph.
class LineSegment {
  const LineSegment(this.start, this.end);

  final Point2D start;
  final Point2D end;
}

enum ConicType { circle, ellipse, parabola, hyperbola, rectangularHyperbola, degenerate }

/// Every computed fact about a conic section, in original-coordinate space,
/// ready for either text display or curve rendering.
class ConicResult {
  const ConicResult({
    required this.type,
    required this.standardFormEquation,
    required this.center,
    required this.vertices,
    required this.foci,
    required this.curvePoints,
    this.isDegenerate = false,
    this.degeneracyMessage,
    this.eccentricity,
    this.semiMajorAxis,
    this.semiMinorAxis,
    this.radius,
    this.directrixDescriptions = const [],
    this.directrixSegments = const [],
    this.asymptoteDescriptions = const [],
    this.asymptoteSegments = const [],
    this.latusRectumLength,
    this.latusRectumEndpoints = const [],
    this.rotationAngleRadians = 0,
  });

  final ConicType type;
  final bool isDegenerate;
  final String? degeneracyMessage;
  final String standardFormEquation;
  final Point2D center;
  final List<Point2D> vertices;
  final List<Point2D> foci;
  final double? eccentricity;
  final double? semiMajorAxis;
  final double? semiMinorAxis;
  final double? radius;
  final List<String> directrixDescriptions;
  final List<LineSegment> directrixSegments;
  final List<String> asymptoteDescriptions;
  final List<LineSegment> asymptoteSegments;
  final double? latusRectumLength;
  final List<Point2D> latusRectumEndpoints;
  final double rotationAngleRadians;

  /// Sampled points along the curve in original-coordinate space, ready to
  /// be drawn as a polyline (or two polylines for a hyperbola's branches —
  /// callers detect a branch break by a large jump between consecutive
  /// points and start a new sub-path).
  final List<Point2D> curvePoints;

  String get shapeName => switch (type) {
    ConicType.circle => 'Circle',
    ConicType.ellipse => 'Ellipse',
    ConicType.parabola => 'Parabola',
    ConicType.hyperbola => 'Hyperbola',
    ConicType.rectangularHyperbola => 'Rectangular Hyperbola',
    ConicType.degenerate => 'Degenerate Conic',
  };
}
