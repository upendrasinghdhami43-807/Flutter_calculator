import 'dart:math' as math;

import 'conic_result.dart';

/// Rotates the local point `(localX, localY)` by [rotation] radians and
/// translates by [origin]. Used both by the auto-detect solver (where
/// [origin] is the world origin and the translation is already folded into
/// `localX`/`localY` from completing the square in the rotated frame) and by
/// the manual shape builders (where [rotation] is 0 and [origin] is the
/// user-entered world-space center).
Point2D transformPoint(double localX, double localY, double rotation, Point2D origin) {
  final cosT = math.cos(rotation);
  final sinT = math.sin(rotation);
  return Point2D(origin.x + localX * cosT - localY * sinT, origin.y + localX * sinT + localY * cosT);
}

/// Builds a finite, drawable [LineSegment] for a line that passes through
/// local point `(localX, localY)` running in direction `(dirX, dirY)`
/// (not necessarily normalized), extended [halfLength] in each direction.
LineSegment lineSegmentThrough(
  double localX,
  double localY,
  double dirX,
  double dirY,
  double halfLength,
  double rotation,
  Point2D origin,
) {
  final length = math.sqrt(dirX * dirX + dirY * dirY);
  final ux = length < 1e-12 ? 0 : dirX / length;
  final uy = length < 1e-12 ? 0 : dirY / length;
  final start = transformPoint(localX - ux * halfLength, localY - uy * halfLength, rotation, origin);
  final end = transformPoint(localX + ux * halfLength, localY + uy * halfLength, rotation, origin);
  return LineSegment(start, end);
}

String formatCoefficient(double value) {
  if (value.abs() < 1e-9) return '0';
  if ((value - value.roundToDouble()).abs() < 1e-9) return value.round().toString();
  return value.toStringAsPrecision(6).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}
