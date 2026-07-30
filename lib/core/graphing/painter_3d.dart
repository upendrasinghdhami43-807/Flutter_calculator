import 'package:flutter/material.dart';

import 'projection_3d.dart';

/// CustomPainter that renders a [Mesh3D] wireframe using [Projection3D].
/// Draws XYZ axes with labels and a ground-plane grid.
class Painter3D extends CustomPainter {
  Painter3D({required this.mesh, required this.projection, this.wireColor = Colors.blue});

  final Mesh3D mesh;
  final Projection3D projection;
  final Color wireColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    _drawAxes(canvas, size, cx, cy);
    _drawMesh(canvas, cx, cy);
  }

  void _drawAxes(Canvas canvas, Size size, double cx, double cy) {
    const axisLength = 2.0;
    final axisPaint = Paint()..strokeWidth = 1.2;

    // X axis - red
    axisPaint.color = Colors.red.withValues(alpha: 0.6);
    final xStart = projection.project(const Point3D(-axisLength, 0, 0), cx, cy);
    final xEnd = projection.project(const Point3D(axisLength, 0, 0), cx, cy);
    canvas.drawLine(Offset(xStart.x, xStart.y), Offset(xEnd.x, xEnd.y), axisPaint);
    _drawLabel(canvas, Offset(xEnd.x + 8, xEnd.y), 'X', Colors.red);

    // Y axis - green
    axisPaint.color = Colors.green.withValues(alpha: 0.6);
    final yStart = projection.project(const Point3D(0, -axisLength, 0), cx, cy);
    final yEnd = projection.project(const Point3D(0, axisLength, 0), cx, cy);
    canvas.drawLine(Offset(yStart.x, yStart.y), Offset(yEnd.x, yEnd.y), axisPaint);
    _drawLabel(canvas, Offset(yEnd.x + 8, yEnd.y), 'Y', Colors.green);

    // Z axis - blue
    axisPaint.color = Colors.blue.withValues(alpha: 0.6);
    final zStart = projection.project(const Point3D(0, 0, -axisLength), cx, cy);
    final zEnd = projection.project(const Point3D(0, 0, axisLength), cx, cy);
    canvas.drawLine(Offset(zStart.x, zStart.y), Offset(zEnd.x, zEnd.y), axisPaint);
    _drawLabel(canvas, Offset(zEnd.x + 8, zEnd.y), 'Z', Colors.blue);

    // Ground grid
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.12)
      ..strokeWidth = 0.5;
    for (var i = -2; i <= 2; i++) {
      final a = projection.project(Point3D(i.toDouble(), 0, -2), cx, cy);
      final b = projection.project(Point3D(i.toDouble(), 0, 2), cx, cy);
      canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y), gridPaint);
      final c = projection.project(Point3D(-2, 0, i.toDouble()), cx, cy);
      final d = projection.project(Point3D(2, 0, i.toDouble()), cx, cy);
      canvas.drawLine(Offset(c.x, c.y), Offset(d.x, d.y), gridPaint);
    }
  }

  void _drawMesh(Canvas canvas, double cx, double cy) {
    final edgePaint = Paint()
      ..color = wireColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Project all vertices
    final projected = mesh.vertices.map((v) => projection.project(v, cx, cy)).toList();

    // Draw edges
    for (final edge in mesh.edges) {
      final from = projected[edge.from];
      final to = projected[edge.to];
      canvas.drawLine(Offset(from.x, from.y), Offset(to.x, to.y), edgePaint);
    }

    // Draw vertices as small dots
    final dotPaint = Paint()..color = wireColor;
    for (final point in projected) {
      canvas.drawCircle(Offset(point.x, point.y), 1.2, dotPaint);
    }
  }

  void _drawLabel(Canvas canvas, Offset position, String text, Color color) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant Painter3D oldDelegate) =>
      oldDelegate.mesh != mesh || oldDelegate.projection != projection || oldDelegate.wireColor != wireColor;
}
