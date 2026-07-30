import 'dart:math' as math;

import '../expression_engine/evaluator.dart';
import '../expression_engine/parser.dart';
import 'projection_3d.dart';

/// Generates wireframe meshes for common 3D shapes and custom z=f(x,y) surfaces.
class MeshGenerator {
  const MeshGenerator();

  Mesh3D cube({double size = 1}) {
    final s = size / 2;
    final vertices = [
      Point3D(-s, -s, -s), Point3D(s, -s, -s), Point3D(s, s, -s), Point3D(-s, s, -s),
      Point3D(-s, -s, s), Point3D(s, -s, s), Point3D(s, s, s), Point3D(-s, s, s),
    ];
    final edges = [
      const Edge3D(0, 1), const Edge3D(1, 2), const Edge3D(2, 3), const Edge3D(3, 0),
      const Edge3D(4, 5), const Edge3D(5, 6), const Edge3D(6, 7), const Edge3D(7, 4),
      const Edge3D(0, 4), const Edge3D(1, 5), const Edge3D(2, 6), const Edge3D(3, 7),
    ];
    return Mesh3D(vertices: vertices, edges: edges);
  }

  Mesh3D sphere({double radius = 1, int segments = 16, int rings = 12}) {
    final vertices = <Point3D>[];
    final edges = <Edge3D>[];

    for (var ring = 0; ring <= rings; ring++) {
      final phi = math.pi * ring / rings;
      for (var seg = 0; seg < segments; seg++) {
        final theta = 2 * math.pi * seg / segments;
        vertices.add(Point3D(
          radius * math.sin(phi) * math.cos(theta),
          radius * math.cos(phi),
          radius * math.sin(phi) * math.sin(theta),
        ));
      }
    }

    // Horizontal rings
    for (var ring = 0; ring <= rings; ring++) {
      for (var seg = 0; seg < segments; seg++) {
        final current = ring * segments + seg;
        final next = ring * segments + (seg + 1) % segments;
        edges.add(Edge3D(current, next));
      }
    }

    // Vertical segments
    for (var ring = 0; ring < rings; ring++) {
      for (var seg = 0; seg < segments; seg++) {
        final current = ring * segments + seg;
        final below = (ring + 1) * segments + seg;
        edges.add(Edge3D(current, below));
      }
    }

    return Mesh3D(vertices: vertices, edges: edges);
  }

  Mesh3D cone({double radius = 1, double height = 2, int segments = 20}) {
    final vertices = <Point3D>[Point3D(0, height / 2, 0)]; // apex
    final edges = <Edge3D>[];

    // Base circle
    for (var i = 0; i < segments; i++) {
      final theta = 2 * math.pi * i / segments;
      vertices.add(Point3D(
        radius * math.cos(theta),
        -height / 2,
        radius * math.sin(theta),
      ));
    }

    // Apex to base edges
    for (var i = 1; i <= segments; i++) {
      edges.add(Edge3D(0, i));
    }

    // Base circle edges
    for (var i = 1; i < segments; i++) {
      edges.add(Edge3D(i, i + 1));
    }
    edges.add(Edge3D(segments, 1));

    return Mesh3D(vertices: vertices, edges: edges);
  }

  Mesh3D cylinder({double radius = 1, double height = 2, int segments = 20}) {
    final vertices = <Point3D>[];
    final edges = <Edge3D>[];

    // Top circle
    for (var i = 0; i < segments; i++) {
      final theta = 2 * math.pi * i / segments;
      vertices.add(Point3D(radius * math.cos(theta), height / 2, radius * math.sin(theta)));
    }

    // Bottom circle
    for (var i = 0; i < segments; i++) {
      final theta = 2 * math.pi * i / segments;
      vertices.add(Point3D(radius * math.cos(theta), -height / 2, radius * math.sin(theta)));
    }

    // Top circle edges
    for (var i = 0; i < segments; i++) {
      edges.add(Edge3D(i, (i + 1) % segments));
    }

    // Bottom circle edges
    for (var i = 0; i < segments; i++) {
      edges.add(Edge3D(segments + i, segments + (i + 1) % segments));
    }

    // Vertical edges
    for (var i = 0; i < segments; i++) {
      edges.add(Edge3D(i, segments + i));
    }

    return Mesh3D(vertices: vertices, edges: edges);
  }

  Mesh3D pyramid({double base = 1, double height = 1.5}) {
    final s = base / 2;
    final h = height / 2;
    final vertices = [
      Point3D(0, h, 0), // apex
      Point3D(-s, -h, -s), Point3D(s, -h, -s), Point3D(s, -h, s), Point3D(-s, -h, s),
    ];
    final edges = [
      const Edge3D(0, 1), const Edge3D(0, 2), const Edge3D(0, 3), const Edge3D(0, 4),
      const Edge3D(1, 2), const Edge3D(2, 3), const Edge3D(3, 4), const Edge3D(4, 1),
    ];
    return Mesh3D(vertices: vertices, edges: edges);
  }

  Mesh3D torus({double majorRadius = 1.2, double minorRadius = 0.4, int majorSegments = 20, int minorSegments = 12}) {
    final vertices = <Point3D>[];
    final edges = <Edge3D>[];

    for (var i = 0; i < majorSegments; i++) {
      final theta = 2 * math.pi * i / majorSegments;
      for (var j = 0; j < minorSegments; j++) {
        final phi = 2 * math.pi * j / minorSegments;
        final x = (majorRadius + minorRadius * math.cos(phi)) * math.cos(theta);
        final y = minorRadius * math.sin(phi);
        final z = (majorRadius + minorRadius * math.cos(phi)) * math.sin(theta);
        vertices.add(Point3D(x, y, z));
      }
    }

    for (var i = 0; i < majorSegments; i++) {
      for (var j = 0; j < minorSegments; j++) {
        final current = i * minorSegments + j;
        final nextMinor = i * minorSegments + (j + 1) % minorSegments;
        final nextMajor = ((i + 1) % majorSegments) * minorSegments + j;
        edges.add(Edge3D(current, nextMinor));
        edges.add(Edge3D(current, nextMajor));
      }
    }

    return Mesh3D(vertices: vertices, edges: edges);
  }

  Mesh3D triangularPrism({double base = 1, double height = 2}) {
    final h = height / 2;
    final s = base / 2;
    final triH = base * math.sqrt(3) / 2 / 2;
    final vertices = [
      // Top triangle
      Point3D(-s, h, -triH), Point3D(s, h, -triH), Point3D(0, h, triH),
      // Bottom triangle
      Point3D(-s, -h, -triH), Point3D(s, -h, -triH), Point3D(0, -h, triH),
    ];
    final edges = [
      const Edge3D(0, 1), const Edge3D(1, 2), const Edge3D(2, 0),
      const Edge3D(3, 4), const Edge3D(4, 5), const Edge3D(5, 3),
      const Edge3D(0, 3), const Edge3D(1, 4), const Edge3D(2, 5),
    ];
    return Mesh3D(vertices: vertices, edges: edges);
  }

  Mesh3D rectangularPrism({double width = 1.5, double height = 1, double depth = 0.8}) {
    final w = width / 2, h = height / 2, d = depth / 2;
    final vertices = [
      Point3D(-w, -h, -d), Point3D(w, -h, -d), Point3D(w, h, -d), Point3D(-w, h, -d),
      Point3D(-w, -h, d), Point3D(w, -h, d), Point3D(w, h, d), Point3D(-w, h, d),
    ];
    final edges = [
      const Edge3D(0, 1), const Edge3D(1, 2), const Edge3D(2, 3), const Edge3D(3, 0),
      const Edge3D(4, 5), const Edge3D(5, 6), const Edge3D(6, 7), const Edge3D(7, 4),
      const Edge3D(0, 4), const Edge3D(1, 5), const Edge3D(2, 6), const Edge3D(3, 7),
    ];
    return Mesh3D(vertices: vertices, edges: edges);
  }

  /// Generate a surface mesh from z = f(x, y) expression.
  Mesh3D surface(String expression, {double range = 3, int resolution = 20}) {
    final parser = ExpressionParser();
    final evaluator = const ExpressionEvaluator(angleUnit: AngleUnit.radians);
    final node = parser.parse(expression);

    final vertices = <Point3D>[];
    final edges = <Edge3D>[];
    final step = 2 * range / resolution;

    for (var i = 0; i <= resolution; i++) {
      for (var j = 0; j <= resolution; j++) {
        final x = -range + i * step;
        final y = -range + j * step;
        double z;
        try {
          z = evaluator.evaluate(node, variables: {'x': x, 'y': y});
          if (!z.isFinite || z.abs() > 10) z = z.clamp(-10, 10);
        } catch (_) {
          z = 0;
        }
        vertices.add(Point3D(x / range, z / range, y / range));
      }
    }

    // Create grid edges
    final cols = resolution + 1;
    for (var i = 0; i <= resolution; i++) {
      for (var j = 0; j <= resolution; j++) {
        final current = i * cols + j;
        if (j < resolution) edges.add(Edge3D(current, current + 1));
        if (i < resolution) edges.add(Edge3D(current, current + cols));
      }
    }

    return Mesh3D(vertices: vertices, edges: edges);
  }
}
