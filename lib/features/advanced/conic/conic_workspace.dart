import 'package:flutter/material.dart';

import '../../../core/conics/conic_painter.dart';
import '../../../core/conics/conic_result.dart';
import '../../../core/conics/conic_solver.dart';
import '../../../core/expression_engine/errors.dart';
import 'general_conic_parser.dart';

enum ManualConicShape { circle, ellipse, parabola, hyperbola, rectangularHyperbola }

/// Shared interaction surface for Graph Finder and Conic Value Finder. Both
/// entry paths deliberately call the same [ConicSolver] and render through
/// the same [ConicPainter], so a visual graph and its reported values cannot
/// disagree because of duplicate classification code.
class ConicWorkspace extends StatefulWidget {
  const ConicWorkspace({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  State<ConicWorkspace> createState() => _ConicWorkspaceState();
}

class _ConicWorkspaceState extends State<ConicWorkspace> with SingleTickerProviderStateMixin {
  final _solver = const ConicSolver();
  final _parser = const GeneralConicParser();
  late final TabController _tabs;
  final _centerX = TextEditingController(text: '0');
  final _centerY = TextEditingController(text: '0');
  final _radius = TextEditingController(text: '2');
  final _axisX = TextEditingController(text: '2');
  final _axisY = TextEditingController(text: '3');
  final _p = TextEditingController(text: '1');
  final _equation = TextEditingController(text: 'x² + y² - 4 = 0');
  ManualConicShape _shape = ManualConicShape.circle;
  String _parabolaDirection = 'Up';
  String _hyperbolaAxis = 'Horizontal';
  ConicResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final controller in [_centerX, _centerY, _radius, _axisX, _axisY, _p, _equation]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _applyTemplate(ManualConicShape shape) {
    setState(() {
      _shape = shape;
      switch (shape) {
        case ManualConicShape.circle:
          _equation.text = 'x² + y² - 4 = 0';
        case ManualConicShape.ellipse:
          _equation.text = '9x² + 4y² - 36 = 0';
        case ManualConicShape.parabola:
          _equation.text = 'x² - 4y = 0';
        case ManualConicShape.hyperbola:
          _equation.text = 'x² - 4y² - 4 = 0';
        case ManualConicShape.rectangularHyperbola:
          _equation.text = 'x² - y² - 1 = 0';
      }
    });
  }

  void _generateManual() {
    try {
      final center = Point2D(_read(_centerX), _read(_centerY));
      final result = switch (_shape) {
        ManualConicShape.circle => _solver.manualCircle(center: center, radius: _read(_radius)),
        ManualConicShape.ellipse => _solver.manualEllipse(center: center, axisX: _read(_axisX), axisY: _read(_axisY)),
        ManualConicShape.parabola => _solver.manualParabola(
          vertex: center,
          p: _signedParabolaP(),
          opensAlongX: _parabolaDirection == 'Left' || _parabolaDirection == 'Right',
        ),
        ManualConicShape.hyperbola => _solver.manualHyperbola(
          center: center,
          a: _read(_axisX),
          b: _read(_axisY),
          transverseAlongX: _hyperbolaAxis == 'Horizontal',
        ),
        ManualConicShape.rectangularHyperbola => _solver.manualRectangularHyperbola(center: center, a: _read(_axisX)),
      };
      setState(() {
        _result = result;
        _error = null;
      });
    } on MathException catch (error) {
      setState(() => _error = error.message);
    } on FormatException {
      setState(() => _error = 'Every parameter must contain a valid number.');
    }
  }

  void _generateEquation() {
    try {
      final coefficients = _parser.parse(_equation.text);
      final result = _solver.solveGeneral(coefficients.a, coefficients.b, coefficients.c, coefficients.d, coefficients.e, coefficients.f);
      setState(() {
        _result = result;
        _error = null;
      });
    } on MathException catch (error) {
      setState(() => _error = error.message);
    } on FormatException {
      setState(() => _error = 'Enter a valid second-degree equation.');
    }
  }

  double _read(TextEditingController controller) => double.parse(controller.text.trim());

  double _signedParabolaP() {
    final value = _read(_p);
    return (_parabolaDirection == 'Left' || _parabolaDirection == 'Down') ? -value.abs() : value.abs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), bottom: TabBar(controller: _tabs, tabs: const [Tab(text: 'Pick a Shape'), Tab(text: 'Enter Equation')])),
      body: SafeArea(
        child: TabBarView(
          controller: _tabs,
          children: [
            _buildScrollView(context, _manualForm(context)),
            _buildScrollView(context, _equationForm(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollView(BuildContext context, Widget form) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(widget.subtitle, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        form,
        if (_error != null) ...[
          const SizedBox(height: 16),
          _StatusPanel(message: _error!, isError: true),
        ],
        if (_result != null) ...[
          const SizedBox(height: 20),
          _ConicOutput(result: _result!),
        ],
      ],
    );
  }

  Widget _manualForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shape template', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<ManualConicShape>(
          initialValue: _shape,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: ManualConicShape.values.map((shape) => DropdownMenuItem(value: shape, child: Text(_shapeName(shape)))).toList(),
          onChanged: (shape) => _applyTemplate(shape!),
        ),
        const SizedBox(height: 16),
        _ParameterGrid(
          children: [
            _numberField('Center/vertex x', _centerX),
            _numberField('Center/vertex y', _centerY),
            ...switch (_shape) {
              ManualConicShape.circle => [_numberField('Radius', _radius)],
              ManualConicShape.ellipse => [_numberField('Semi-axis x', _axisX), _numberField('Semi-axis y', _axisY)],
              ManualConicShape.parabola => [_numberField('Focal distance p', _p), _directionPicker()],
              ManualConicShape.hyperbola => [_numberField('Transverse semi-axis a', _axisX), _numberField('Conjugate semi-axis b', _axisY), _hyperbolaAxisPicker()],
              ManualConicShape.rectangularHyperbola => [_numberField('Semi-axis a', _axisX)],
            },
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: _generateManual, icon: const Icon(Icons.auto_graph), label: const Text('Generate Graph')),
      ],
    );
  }

  Widget _equationForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Other equation', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _equation,
          decoration: const InputDecoration(labelText: 'Ax² + Bxy + Cy² + Dx + Ey + F = 0', border: OutlineInputBorder()),
          autocorrect: false,
        ),
        const SizedBox(height: 12),
        Text('Choose a template above to preload a known equation, then refine it here.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: _generateEquation, icon: const Icon(Icons.auto_graph), label: const Text('Generate Graph')),
      ],
    );
  }

  Widget _numberField(String label, TextEditingController controller) => TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
  );

  Widget _directionPicker() => DropdownButtonFormField<String>(
    initialValue: _parabolaDirection,
    decoration: const InputDecoration(labelText: 'Opens', border: OutlineInputBorder()),
    items: const ['Up', 'Down', 'Left', 'Right'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
    onChanged: (value) => setState(() => _parabolaDirection = value!),
  );

  Widget _hyperbolaAxisPicker() => DropdownButtonFormField<String>(
    initialValue: _hyperbolaAxis,
    decoration: const InputDecoration(labelText: 'Transverse axis', border: OutlineInputBorder()),
    items: const ['Horizontal', 'Vertical'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
    onChanged: (value) => setState(() => _hyperbolaAxis = value!),
  );

  String _shapeName(ManualConicShape shape) => switch (shape) {
    ManualConicShape.circle => 'Circle',
    ManualConicShape.ellipse => 'Ellipse',
    ManualConicShape.parabola => 'Parabola',
    ManualConicShape.hyperbola => 'Hyperbola',
    ManualConicShape.rectangularHyperbola => 'Rectangular hyperbola',
  };
}

class _ParameterGrid extends StatelessWidget {
  const _ParameterGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 2.2,
    children: children,
  );
}

class _ConicOutput extends StatelessWidget {
  const _ConicOutput({required this.result});

  final ConicResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 360,
          child: DecoratedBox(
            decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(80),
                minScale: 0.6,
                maxScale: 4,
                child: SizedBox(width: 600, height: 400, child: CustomPaint(painter: ConicPainter(result))),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('${result.shapeName} values', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _StatusPanel(message: _factsText(result), isError: result.isDegenerate),
      ],
    );
  }

  String _factsText(ConicResult result) {
    if (result.isDegenerate) return result.degeneracyMessage ?? 'No real curve exists.';
    final lines = [
      'Standard form: ${result.standardFormEquation}',
      'Center / vertex: ${result.center}',
      'Vertices: ${result.vertices.join(', ')}',
      'Foci: ${result.foci.join(', ')}',
      if (result.radius != null) 'Radius: ${_format(result.radius!)}',
      if (result.semiMajorAxis != null) 'Semi-major axis: ${_format(result.semiMajorAxis!)}',
      if (result.semiMinorAxis != null) 'Semi-minor axis: ${_format(result.semiMinorAxis!)}',
      if (result.eccentricity != null) 'Eccentricity: ${_format(result.eccentricity!)}',
      if (result.latusRectumLength != null) 'Latus rectum: ${_format(result.latusRectumLength!)}',
      ...result.directrixDescriptions.map((value) => 'Directrix: $value'),
      ...result.asymptoteDescriptions.map((value) => 'Asymptote: $value'),
    ];
    return lines.join('\n');
  }

  String _format(double value) => value.toStringAsPrecision(7).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: isError ? colors.errorContainer : colors.secondaryContainer, borderRadius: BorderRadius.circular(8)),
      child: SelectableText(message, style: TextStyle(color: isError ? colors.onErrorContainer : colors.onSecondaryContainer)),
    );
  }
}
