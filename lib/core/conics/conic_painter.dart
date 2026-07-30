import 'package:flutter/material.dart';

import 'conic_result.dart';

/// Renders a computed [ConicResult] onto a canvas: grid, axes, the curve
/// itself (handling hyperbola's disjoint branches without a connecting
/// line), directrix/asymptote guide lines, and labeled center/vertex/focus
/// points. Meant to be wrapped in an [InteractiveViewer] by the consuming
/// screen for pinch-zoom/pan, so this painter always fits the whole shape
/// to the given canvas size.
class ConicPainter extends CustomPainter {
  ConicPainter(this.result, {this.showGrid = true, this.selectedPoint});

  final ConicResult result;
  final bool showGrid;
  final Point2D? selectedPoint;

  static const double _margin = 32;

  /// Converts a tap in this painter's canvas space back to the equation's
  /// original x/y coordinate system. Consumers use it to show an inspected
  /// coordinate in the interactive graph view.
  Point2D pointAt(Offset position, Size size) {
    final bounds = _computeWorldBounds(size);
    final scale = _computeScale(size, bounds);
    return Point2D(
      bounds.center.dx + (position.dx - size.width / 2) / scale,
      bounds.center.dy - (position.dy - size.height / 2) / scale,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (result.isDegenerate) {
      _paintMessage(canvas, size, result.degeneracyMessage ?? 'No real curve to draw.');
      return;
    }

    final bounds = _computeWorldBounds(size);
    final scale = _computeScale(size, bounds);
    Offset toScreen(Point2D p) => Offset(size.width / 2 + (p.x - bounds.center.dx) * scale, size.height / 2 - (p.y - bounds.center.dy) * scale);

    if (showGrid) _paintGrid(canvas, size, bounds.center, scale);
    _paintAxes(canvas, size, bounds.center, scale);

    final guidePaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (final segment in result.directrixSegments) {
      canvas.drawLine(toScreen(segment.start), toScreen(segment.end), guidePaint);
    }
    final asymptotePaint = Paint()
      ..color = Colors.purple.withValues(alpha: 0.8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (final segment in result.asymptoteSegments) {
      canvas.drawLine(toScreen(segment.start), toScreen(segment.end), asymptotePaint);
    }

    final curvePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    for (final segment in result.curveSegments) {
      if (segment.length < 2) continue;
      final path = Path()..moveTo(toScreen(segment.first).dx, toScreen(segment.first).dy);
      for (final point in segment.skip(1)) {
        final screen = toScreen(point);
        path.lineTo(screen.dx, screen.dy);
      }
      canvas.drawPath(path, curvePaint);
    }

    _paintLabeledPoint(canvas, toScreen(result.center), 'C', Colors.black);
    for (var i = 0; i < result.vertices.length; i++) {
      _paintLabeledPoint(canvas, toScreen(result.vertices[i]), 'V${i + 1}', Colors.green.shade700);
    }
    for (var i = 0; i < result.foci.length; i++) {
      _paintLabeledPoint(canvas, toScreen(result.foci[i]), 'F${i + 1}', Colors.red.shade700);
    }

    if (selectedPoint != null) {
      final selected = toScreen(selectedPoint!);
      
      // Crosshair lines
      final crossPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.4)
        ..strokeWidth = 0.8;
      canvas.drawLine(Offset(selected.dx, 0), Offset(selected.dx, size.height), crossPaint);
      canvas.drawLine(Offset(0, selected.dy), Offset(size.width, selected.dy), crossPaint);
      
      // Point dot
      canvas.drawCircle(selected, 6, Paint()..color = Colors.red.withValues(alpha: 0.3));
      canvas.drawCircle(selected, 4, Paint()..color = Colors.red);
      
      // Coordinate label
      final painter = TextPainter(
        text: TextSpan(
          text: '(${_format(selectedPoint!.x)}, ${_format(selectedPoint!.y)})',
          style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, selected + const Offset(10, -22));
    }
  }

  String _format(double value) => value.toStringAsPrecision(6).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');

  void _paintMessage(Canvas canvas, Size size, String message) {
    final painter = TextPainter(
      text: TextSpan(text: message, style: const TextStyle(color: Colors.black87, fontSize: 14)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width - 32);
    painter.paint(canvas, Offset((size.width - painter.width) / 2, (size.height - painter.height) / 2));
  }

  void _paintLabeledPoint(Canvas canvas, Offset at, String label, Color color) {
    canvas.drawCircle(at, 4, Paint()..color = color);
    final painter = TextPainter(text: TextSpan(text: label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)
      ..layout();
    painter.paint(canvas, at + const Offset(6, -14));
  }

  void _paintGrid(Canvas canvas, Size size, Offset worldCenter, double scale) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    final step = _niceStep(scale);
    final screenStep = step * scale;
    if (screenStep <= 0 || screenStep.isNaN) return;
    for (double x = size.width / 2 % screenStep; x < size.width; x += screenStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = size.height / 2 % screenStep; y < size.height; y += screenStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _paintAxes(Canvas canvas, Size size, Offset worldCenter, double scale) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 1.5;
    final originX = size.width / 2 - worldCenter.dx * scale;
    final originY = size.height / 2 + worldCenter.dy * scale;
    canvas.drawLine(Offset(0, originY), Offset(size.width, originY), paint);
    canvas.drawLine(Offset(originX, 0), Offset(originX, size.height), paint);
  }

  double _niceStep(double scale) {
    // Pick a "nice" world-space grid spacing (1, 2, or 5 × a power of ten)
    // that yields roughly 40-80 screen pixels between grid lines.
    const targetScreenSpacing = 50.0;
    var step = targetScreenSpacing / scale;
    final magnitude = _pow10Floor(step);
    final normalized = step / magnitude;
    final niceNormalized = normalized <= 1 ? 1.0 : (normalized <= 2 ? 2.0 : (normalized <= 5 ? 5.0 : 10.0));
    return niceNormalized * magnitude;
  }

  double _pow10Floor(double value) {
    if (value <= 0) return 1;
    var magnitude = 1.0;
    if (value >= 1) {
      while (magnitude * 10 <= value) {
        magnitude *= 10;
      }
    } else {
      while (magnitude > value) {
        magnitude /= 10;
      }
    }
    return magnitude;
  }

  _WorldBounds _computeWorldBounds(Size size) {
    final points = <Point2D>[result.center, ...result.vertices, ...result.foci, for (final segment in result.curveSegments) ...segment];
    if (points.isEmpty) return _WorldBounds(const Offset(0, 0), 10, 10);
    var minX = points.first.x, maxX = points.first.x, minY = points.first.y, maxY = points.first.y;
    for (final p in points) {
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }
    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    final width = (maxX - minX).abs().clamp(1, double.infinity);
    final height = (maxY - minY).abs().clamp(1, double.infinity);
    return _WorldBounds(Offset(centerX, centerY), width.toDouble(), height.toDouble());
  }

  double _computeScale(Size size, _WorldBounds bounds) {
    final usableWidth = size.width - 2 * _margin;
    final usableHeight = size.height - 2 * _margin;
    final scaleX = usableWidth / bounds.width;
    final scaleY = usableHeight / bounds.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    return scale.isFinite && scale > 0 ? scale : 1;
  }

  @override
  bool shouldRepaint(covariant ConicPainter oldDelegate) => 
    oldDelegate.result != result || oldDelegate.showGrid != showGrid || oldDelegate.selectedPoint != selectedPoint;
}

class _WorldBounds {
  _WorldBounds(this.center, this.width, this.height);

  final Offset center;
  final double width;
  final double height;
}
