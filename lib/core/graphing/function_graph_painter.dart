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
    if (selectedPoint != null) {
      final selected = screenPoint(selectedPoint!, size);
      canvas.drawCircle(selected, 5, Paint()..color = Colors.red);
      _paintLabel(canvas, selected, '(${_format(selectedPoint!.x)}, ${_format(selectedPoint!.y)})');
    }
  }

  void _paintGrid(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height / 2);
    final minorPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.16)
      ..strokeWidth = 0.7;
    final majorPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.38)
      ..strokeWidth = 1;
    for (var x = origin.dx % pixelsPerUnit; x <= size.width; x += pixelsPerUnit) {
      final isAxis = (x - origin.dx).abs() < 0.5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), isAxis ? majorPaint : minorPaint);
    }
    for (var y = origin.dy % pixelsPerUnit; y <= size.height; y += pixelsPerUnit) {
      final isAxis = (y - origin.dy).abs() < 0.5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), isAxis ? majorPaint : minorPaint);
    }
    final axisPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 1.6;
    canvas.drawLine(Offset(0, origin.dy), Offset(size.width, origin.dy), axisPaint);
    canvas.drawLine(Offset(origin.dx, 0), Offset(origin.dx, size.height), axisPaint);
  }

  void _paintLabel(Canvas canvas, Offset point, String label) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, point + const Offset(8, -22));
  }

  String _format(double value) => value.toStringAsPrecision(6).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');

  @override
  bool shouldRepaint(covariant FunctionGraphPainter oldDelegate) =>
      oldDelegate.segments != segments || oldDelegate.selectedPoint != selectedPoint || oldDelegate.pixelsPerUnit != pixelsPerUnit;
}
