import 'package:flutter/material.dart';

import '../../../core/graphing/function_graph.dart';
import '../../../core/graphing/function_graph_painter.dart';

/// An inspectable function graph canvas. InteractiveViewer provides panning
/// and pinch zoom; the explicit +/- controls are retained for one-handed use.
/// Tapping shows crosshair lines through the selected point with coordinates.
class FunctionGraphView extends StatefulWidget {
  const FunctionGraphView({required this.expression, required this.segments, this.fullscreen = false, super.key});

  final String expression;
  final List<List<FunctionGraphPoint>> segments;
  final bool fullscreen;

  @override
  State<FunctionGraphView> createState() => _FunctionGraphViewState();
}

class _FunctionGraphViewState extends State<FunctionGraphView> {
  static const _canvasSize = Size(1000, 700);
  final _transformController = TransformationController();
  FunctionGraphPoint? _selectedPoint;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _setZoom(double factor) {
    final current = _transformController.value.getMaxScaleOnAxis();
    final next = (current * factor).clamp(0.6, 5.0);
    final center = Offset(_canvasSize.width / 2, _canvasSize.height / 2);
    final matrix = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0.0, 1.0)
      ..scaleByDouble(next, next, 1.0, 1.0)
      ..translateByDouble(-center.dx, -center.dy, 0.0, 1.0);
    _transformController.value = matrix;
  }

  void _pan(double dx, double dy) {
    final current = _transformController.value.clone();
    current.translateByDouble(dx, dy, 0.0, 1.0);
    _transformController.value = current;
  }

  void _selectPoint(Offset localPosition) {
    final painter = FunctionGraphPainter(segments: widget.segments);
    FunctionGraphPoint? nearest;
    var nearestDistance = double.infinity;
    for (final segment in widget.segments) {
      for (final point in segment) {
        final screen = painter.screenPoint(point, _canvasSize);
        final distance = (screen - localPosition).distanceSquared;
        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearest = point;
        }
      }
    }
    if (nearest != null) setState(() => _selectedPoint = nearest);
  }

  @override
  Widget build(BuildContext context) {
    final painter = FunctionGraphPainter(segments: widget.segments, selectedPoint: _selectedPoint);
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            InteractiveViewer(
              transformationController: _transformController,
              boundaryMargin: const EdgeInsets.all(400),
              minScale: 0.6,
              maxScale: 5,
              constrained: false,
              child: GestureDetector(
                onTapDown: (details) => _selectPoint(details.localPosition),
                child: SizedBox(
                  width: _canvasSize.width,
                  height: _canvasSize.height,
                  child: CustomPaint(painter: painter),
                ),
              ),
            ),
            // Controls - top right
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: colors.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(tooltip: 'Zoom in', onPressed: () => _setZoom(1.25), icon: const Icon(Icons.add, size: 20)),
                      IconButton(tooltip: 'Zoom out', onPressed: () => _setZoom(0.8), icon: const Icon(Icons.remove, size: 20)),
                      const Divider(height: 8),
                      IconButton(tooltip: 'Pan up', onPressed: () => _pan(0, 50), icon: const Icon(Icons.keyboard_arrow_up, size: 20)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(tooltip: 'Pan left', onPressed: () => _pan(50, 0), icon: const Icon(Icons.keyboard_arrow_left, size: 20)),
                          IconButton(tooltip: 'Pan right', onPressed: () => _pan(-50, 0), icon: const Icon(Icons.keyboard_arrow_right, size: 20)),
                        ],
                      ),
                      IconButton(tooltip: 'Pan down', onPressed: () => _pan(0, -50), icon: const Icon(Icons.keyboard_arrow_down, size: 20)),
                      const Divider(height: 8),
                      if (!widget.fullscreen)
                        IconButton(
                          tooltip: 'Full screen',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => _FunctionGraphFullscreen(expression: widget.expression, segments: widget.segments)),
                          ),
                          icon: const Icon(Icons.fullscreen, size: 20),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Coordinate info - bottom left
            Positioned(
              left: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Text(
                  _selectedPoint == null
                      ? 'Tap the curve to inspect a point'
                      : 'x = ${_format(_selectedPoint!.x)}, y = ${_format(_selectedPoint!.y)}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: _selectedPoint != null ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _format(double value) => value.toStringAsPrecision(6).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

class _FunctionGraphFullscreen extends StatelessWidget {
  const _FunctionGraphFullscreen({required this.expression, required this.segments});

  final String expression;
  final List<List<FunctionGraphPoint>> segments;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('y = $expression')),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: FunctionGraphView(expression: expression, segments: segments, fullscreen: true),
      ),
    ),
  );
}
