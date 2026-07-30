import 'package:flutter/material.dart';

import 'function_graph.dart';

class FunctionGraphPainter extends CustomPainter {
  FunctionGraphPainter({required this.segments, this.selectedPoint, this.pixelsPerUnit = 42});

  final List<List<FunctionGraphPoint>> segments;
  final FunctionGraphPoint? selectedPoint;
  final double pixelsPerUnit;

  FunctionGraphPoint pointAt(Offset position, Size size) => FunctionGraphPoint(
    (position.dx - size.width / 2) / pixelsPerUnit,
    (size.height / 2 - position.dy) / pixelsPerUnit,
  );

  Offset screenPoint(FunctionGraphPoint point, Size size) => Offset(
    size.width / 2 + point.x * pixelsPerUnit,
    size.height / 2 - point.y * pixelsPerUnit,
  );

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size);
    _paintNumberedTicks(canvas, size);
    _paintCurves(canvas, size);
    if (selectedPoint != null) _paintSelectedPoint(canvas, size);
  }

  void _paintGrid(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height / 2);
    final minorPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.12)
      ..strokeWidth = 0.5;
    final majorPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.25)
      ..strokeWidth = 0.8;

    // Minor grid (subdivisions)
    final subStep = pixelsPerUnit / 2;
    for (var x = origin.dx % subStep; x <= size.width; x += subStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minorPaint);
    }
    for (var y = origin.dy % subStep; y <= size.height; y += subStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minorPaint);
    }

    // Major grid (unit lines)
    for (var x = origin.dx % pixelsPerUnit; x <= size.width; x += pixelsPerUnit) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), majorPaint);
    }
    for (var y = origin.dy % pixelsPerUnit; y <= size.height; y += pixelsPerUnit) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), majorPaint);
    }

    // Axes with arrow heads
    final axisPaint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 1.8;
    // X axis
    canvas.drawLine(Offset(0, origin.dy), Offset(size.width, origin.dy), axisPaint);
    // Arrow head right
    canvas.drawLine(Offset(size.width - 8, origin.dy - 4), Offset(size.width, origin.dy), axisPaint);
    canvas.drawLine(Offset(size.width - 8, origin.dy + 4), Offset(size.width, origin.dy), axisPaint);
    // Y axis
    canvas.drawLine(Offset(origin.dx, 0), Offset(origin.dx, size.height), axisPaint);
    // Arrow head up
    canvas.drawLine(Offset(origin.dx - 4, 8), Offset(origin.dx, 0), axisPaint);
    canvas.drawLine(Offset(origin.dx + 4, 8), Offset(origin.dx, 0), axisPaint);
  }

  void _paintNumberedTicks(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height / 2);
    final tickPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 1.2;

    // X axis numbers
    final startX = -((origin.dx / pixelsPerUnit).ceil());
    final endX = ((size.width - origin.dx) / pixelsPerUnit).ceil();
    for (var i = startX; i <= endX; i++) {
      if (i == 0) continue;
      final x = origin.dx + i * pixelsPerUnit;
      // Tick mark
      canvas.drawLine(Offset(x, origin.dy - 4), Offset(x, origin.dy + 4), tickPaint);
      // Number label
      _paintTickLabel(canvas, Offset(x, origin.dy + 6), i.toString());
    }

    // Y axis numbers
    final startY = -((origin.dy / pixelsPerUnit).ceil());
    final endY = (((size.height - origin.dy)) / pixelsPerUnit).ceil();
    for (var i = startY; i <= endY; i++) {
      if (i == 0) continue;
      final y = origin.dy - i * pixelsPerUnit;
      canvas.drawLine(Offset(origin.dx - 4, y), Offset(origin.dx + 4, y), tickPaint);
      _paintTickLabel(canvas, Offset(origin.dx + 6, y - 6), i.toString());
    }

    // Origin "0" label
    _paintTickLabel(canvas, Offset(origin.dx + 4, origin.dy + 4), '0');
  }

  void _paintTickLabel(Canvas canvas, Offset position, String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.w500),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, position);
  }

  void _paintCurves(Canvas canvas, Size size) {
    final curvePaint = Paint()
      ..color = Colors.blue.shade700
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    for (final segment in segments) {
      if (segment.length < 2) continue;
      final path = Path();
      final first = screenPoint(segment.first, size);
      path.moveTo(first.dx, first.dy);
      for (final point in segment.skip(1)) {
        final screen = screenPoint(point, size);
        path.lineTo(screen.dx, screen.dy);
      }
      canvas.drawPath(path, curvePaint);
    }
  }

  void _paintSelectedPoint(Canvas canvas, Size size) {
    final selected = screenPoint(selectedPoint!, size);

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
    _paintLabel(canvas, selected, '(${_format(selectedPoint!.x)}, ${_format(selectedPoint!.y)})');
  }

  void _paintLabel(Canvas canvas, Offset point, String label) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, point + const Offset(10, -22));
  }

  String _format(double value) => value.toStringAsPrecision(6).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');

  @override
  bool shouldRepaint(covariant FunctionGraphPainter oldDelegate) =>
      oldDelegate.segments != segments || oldDelegate.selectedPoint != selectedPoint || oldDelegate.pixelsPerUnit != pixelsPerUnit;
}
