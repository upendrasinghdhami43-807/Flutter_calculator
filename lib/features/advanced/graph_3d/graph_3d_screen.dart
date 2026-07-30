import 'package:flutter/material.dart';

import '../../../core/graphing/mesh_generator.dart';
import '../../../core/graphing/painter_3d.dart';
import '../../../core/graphing/projection_3d.dart';

enum Shape3DPreset { cube, sphere, cone, cylinder, pyramid, torus, triangularPrism, rectangularPrism }

class Graph3DScreen extends StatefulWidget {
  const Graph3DScreen({super.key});

  @override
  State<Graph3DScreen> createState() => _Graph3DScreenState();
}

class _Graph3DScreenState extends State<Graph3DScreen> with SingleTickerProviderStateMixin {
  final _meshGen = const MeshGenerator();
  late final TabController _tabs;
  final _expressionController = TextEditingController(text: 'x^2 + y^2');

  Projection3D _projection = const Projection3D();
  Mesh3D? _mesh;
  Shape3DPreset _selectedShape = Shape3DPreset.cube;
  Color _wireColor = Colors.blue;
  bool _fullscreen = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _mesh = _meshGen.cube();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _expressionController.dispose();
    super.dispose();
  }

  void _selectPreset(Shape3DPreset shape) {
    setState(() {
      _selectedShape = shape;
      _mesh = switch (shape) {
        Shape3DPreset.cube => _meshGen.cube(),
        Shape3DPreset.sphere => _meshGen.sphere(),
        Shape3DPreset.cone => _meshGen.cone(),
        Shape3DPreset.cylinder => _meshGen.cylinder(),
        Shape3DPreset.pyramid => _meshGen.pyramid(),
        Shape3DPreset.torus => _meshGen.torus(),
        Shape3DPreset.triangularPrism => _meshGen.triangularPrism(),
        Shape3DPreset.rectangularPrism => _meshGen.rectangularPrism(),
      };
    });
  }

  void _generateSurface() {
    try {
      setState(() {
        _mesh = _meshGen.surface(_expressionController.text.trim());
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _projection = _projection.copyWith(
        rotationY: _projection.rotationY + details.delta.dx * 0.01,
        rotationX: _projection.rotationX + details.delta.dy * 0.01,
      );
    });
  }

  void _setZoom(double factor) {
    setState(() {
      _projection = _projection.copyWith(
        zoom: (_projection.zoom * factor).clamp(0.3, 5.0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_fullscreen) return _buildFullscreen(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Graph'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Preset Shapes'),
            Tab(text: 'Custom Equation'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 3D canvas
            Expanded(
              flex: 3,
              child: _build3DCanvas(context),
            ),
            // Controls below
            Expanded(
              flex: 2,
              child: TabBarView(
                controller: _tabs,
                children: [
                  _presetTab(context),
                  _equationTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullscreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onPanUpdate: _onPanUpdate,
              child: SizedBox.expand(
                child: _mesh != null
                    ? CustomPaint(painter: Painter3D(mesh: _mesh!, projection: _projection, wireColor: _wireColor))
                    : const SizedBox.shrink(),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => setState(() => _fullscreen = false),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _zoomControls(dark: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DCanvas(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Stack(
      children: [
        GestureDetector(
          onPanUpdate: _onPanUpdate,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _mesh != null
                  ? CustomPaint(
                      painter: Painter3D(mesh: _mesh!, projection: _projection, wireColor: _wireColor),
                      child: const SizedBox.expand(),
                    )
                  : const Center(child: Text('Select a shape or enter an equation')),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: _zoomControls(),
        ),
      ],
    );
  }

  Widget _zoomControls({bool dark = false}) {
    final bg = dark ? Colors.white.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surface.withValues(alpha: 0.9);
    final fg = dark ? Colors.white : null;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: Icon(Icons.add, color: fg, size: 20), onPressed: () => _setZoom(1.2), tooltip: 'Zoom in'),
          IconButton(icon: Icon(Icons.remove, color: fg, size: 20), onPressed: () => _setZoom(0.83), tooltip: 'Zoom out'),
          IconButton(
            icon: Icon(_fullscreen ? Icons.fullscreen_exit : Icons.fullscreen, color: fg, size: 20),
            onPressed: () => setState(() => _fullscreen = !_fullscreen),
            tooltip: _fullscreen ? 'Exit full screen' : 'Full screen',
          ),
        ],
      ),
    );
  }

  Widget _presetTab(BuildContext context) {
    final shapes = Shape3DPreset.values;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('Select a 3D shape', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: shapes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (context, index) {
            final shape = shapes[index];
            final selected = shape == _selectedShape;
            return _ShapeChip(
              label: _shapeName(shape),
              icon: _shapeIcon(shape),
              selected: selected,
              onTap: () => _selectPreset(shape),
            );
          },
        ),
        const SizedBox(height: 12),
        // Color picker
        Text('Wire Color', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            for (final color in [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.cyan, Colors.amber])
              GestureDetector(
                onTap: () => setState(() => _wireColor = color),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: color,
                  child: _wireColor == color ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _equationTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('Surface z = f(x, y)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _expressionController,
          decoration: const InputDecoration(
            labelText: 'z = f(x, y)',
            hintText: 'x^2 + y^2, sin(x)*cos(y)',
            border: OutlineInputBorder(),
          ),
          autocorrect: false,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final expr in const ['x^2+y^2', 'sin(x)*cos(y)', 'x*y', 'sin(sqrt(x^2+y^2))', 'exp(-(x^2+y^2))'])
              ActionChip(
                label: Text(expr, style: const TextStyle(fontSize: 11)),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  _expressionController.text = expr;
                  _generateSurface();
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _generateSurface,
          icon: const Icon(Icons.auto_graph),
          label: const Text('Generate Surface'),
        ),
      ],
    );
  }

  String _shapeName(Shape3DPreset shape) => switch (shape) {
    Shape3DPreset.cube => 'Cube',
    Shape3DPreset.sphere => 'Sphere',
    Shape3DPreset.cone => 'Cone',
    Shape3DPreset.cylinder => 'Cylinder',
    Shape3DPreset.pyramid => 'Pyramid',
    Shape3DPreset.torus => 'Torus',
    Shape3DPreset.triangularPrism => 'Tri Prism',
    Shape3DPreset.rectangularPrism => 'Rect Prism',
  };

  IconData _shapeIcon(Shape3DPreset shape) => switch (shape) {
    Shape3DPreset.cube => Icons.view_in_ar,
    Shape3DPreset.sphere => Icons.circle_outlined,
    Shape3DPreset.cone => Icons.change_history,
    Shape3DPreset.cylinder => Icons.view_column_outlined,
    Shape3DPreset.pyramid => Icons.signal_cellular_alt,
    Shape3DPreset.torus => Icons.donut_large,
    Shape3DPreset.triangularPrism => Icons.details,
    Shape3DPreset.rectangularPrism => Icons.crop_square,
  };
}

class _ShapeChip extends StatelessWidget {
  const _ShapeChip({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primaryContainer : colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: selected ? colors.primary : colors.onSurface),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? colors.primary : colors.onSurface)),
          ],
        ),
      ),
    );
  }
}
