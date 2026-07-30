import 'dart:math' as math;

/// Software 3D projection utilities for rendering wireframe meshes
/// using Flutter's CustomPainter.
class Projection3D {
  const Projection3D({
    this.rotationX = 0.5,
    this.rotationY = 0.4,
    this.rotationZ = 0,
    this.zoom = 1.0,
    this.perspective = 800,
  });

  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final double zoom;
  final double perspective;

  Projection3D copyWith({
    double? rotationX,
    double? rotationY,
    double? rotationZ,
    double? zoom,
  }) =>
      Projection3D(
        rotationX: rotationX ?? this.rotationX,
        rotationY: rotationY ?? this.rotationY,
        rotationZ: rotationZ ?? this.rotationZ,
        zoom: zoom ?? this.zoom,
        perspective: perspective,
      );

  /// Project a 3D point to 2D screen coordinates.
  Point2DScreen project(Point3D point, double centerX, double centerY) {
    // Rotate around X axis
    final cosX = math.cos(rotationX);
    final sinX = math.sin(rotationX);
    final y1 = point.y * cosX - point.z * sinX;
    final z1 = point.y * sinX + point.z * cosX;

    // Rotate around Y axis
    final cosY = math.cos(rotationY);
    final sinY = math.sin(rotationY);
    final x2 = point.x * cosY + z1 * sinY;
    final z2 = -point.x * sinY + z1 * cosY;

    // Rotate around Z axis
    final cosZ = math.cos(rotationZ);
    final sinZ = math.sin(rotationZ);
    final x3 = x2 * cosZ - y1 * sinZ;
    final y3 = x2 * sinZ + y1 * cosZ;

    // Perspective projection
    final scale = perspective / (perspective + z2);
    final screenX = centerX + x3 * scale * zoom * 80;
    final screenY = centerY - y3 * scale * zoom * 80;

    return Point2DScreen(screenX, screenY, z2);
  }
}

class Point3D {
  const Point3D(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;
}

class Point2DScreen {
  const Point2DScreen(this.x, this.y, this.depth);

  final double x;
  final double y;
  final double depth;
}

/// An edge connecting two vertex indices.
class Edge3D {
  const Edge3D(this.from, this.to);

  final int from;
  final int to;
}

/// A face defined by vertex indices (for depth sorting and optional fill).
class Face3D {
  const Face3D(this.vertices);

  final List<int> vertices;
}

/// A 3D mesh with vertices, edges, and optional faces.
class Mesh3D {
  const Mesh3D({required this.vertices, required this.edges, this.faces = const []});

  final List<Point3D> vertices;
  final List<Edge3D> edges;
  final List<Face3D> faces;
}
