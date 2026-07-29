import 'package:flutter/material.dart';

import '../../../core/graphing/function_graph.dart';
import '../../../core/graphing/function_graph_painter.dart';

/// An inspectable function graph canvas. InteractiveViewer provides panning
/// and pinch zoom; the explicit +/- controls are retained for one-handed use.
/// Tapping chooses the closest sampled curve point and shows its coordinate.
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
    _transformController.value = Matrix4.identity()..scaleByDouble(next);
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
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            InteractiveViewer(
              transformationController: _transformController,
              boundaryMargin: const EdgeInsets.all(320),
              minScale: 0.6,
              maxScale: 5,
              constrained: false,
              child: GestureDetector(
                onTapDown: (details) => _selectPoint(details.localPosition),
                child: SizedBox(width: _canvasSize.width, height: _canvasSize.height, child: CustomPaint(painter: painter)),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(tooltip: 'Zoom out', onPressed: () => _setZoom(0.8), icon: const Icon(Icons.remove)),
                    IconButton(tooltip: 'Zoom in', onPressed: () => _setZoom(1.25), icon: const Icon(Icons.add)),
                    if (!widget.fullscreen)
                      IconButton(
                        tooltip: 'Open full screen',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => _FunctionGraphFullscreen(expression: widget.expression, segments: widget.segments)),
                        ),
                        icon: const Icon(Icons.fullscreen),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(6)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Text(
                    _selectedPoint == null ? 'Tap a curve to inspect a point' : 'x = ${_format(_selectedPoint!.x)}, y = ${_format(_selectedPoint!.y)}',
                    style: Theme.of(context).textTheme.labelMedium,
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
    appBar: AppBar(title: Text('Graph: $expression')),
    body: SafeArea(child: Padding(padding: const EdgeInsets.all(12), child: FunctionGraphView(expression: expression, segments: segments, fullscreen: true))),
  );
}
