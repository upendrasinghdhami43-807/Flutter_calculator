import 'package:flutter/material.dart';

import '../../../core/conics/conic_result.dart';
import '../../../core/conics/conic_solver.dart';
import '../../../core/expression_engine/errors.dart';
import '../../../core/graphing/function_graph.dart';
import '../../../shared/widgets/guided_number_entry_sheet.dart';
import 'conic_graph_view.dart';
import '../graph_finder/function_graph_view.dart';

enum ManualConicShape { circle, ellipse, parabola, hyperbola, rectangularHyperbola }

/// Shared interaction surface for Graph Finder and Conic Value Finder. Both
/// entry paths deliberately call the same [ConicSolver] and render through
/// the same [ConicPainter], so a visual graph and its reported values cannot
/// disagree because of duplicate classification code.
class ConicWorkspace extends StatefulWidget {
  const ConicWorkspace({required this.title, required this.subtitle, this.includeFunctionGraphs = false, super.key});

  final String title;
  final String subtitle;
  final bool includeFunctionGraphs;

  @override
  State<ConicWorkspace> createState() => _ConicWorkspaceState();
}

class _ConicWorkspaceState extends State<ConicWorkspace> with SingleTickerProviderStateMixin {
  final _solver = const ConicSolver();
  final _functionGraphEngine = const FunctionGraphEngine();
  late final TabController _tabs;
  final _centerX = TextEditingController(text: '0');
  final _centerY = TextEditingController(text: '0');
  final _radius = TextEditingController(text: '2');
  final _axisX = TextEditingController(text: '2');
  final _axisY = TextEditingController(text: '3');
  final _p = TextEditingController(text: '1');
  final _generalA = TextEditingController(text: '1');
  final _generalB = TextEditingController(text: '1');
  final _generalH = TextEditingController(text: '0');
  final _generalG = TextEditingController(text: '0');
  final _generalF = TextEditingController(text: '0');
  final _generalC = TextEditingController(text: '-4');
  final _functionExpression = TextEditingController(text: 'sin(x)');
  ManualConicShape _shape = ManualConicShape.circle;
  String _parabolaDirection = 'Up';
  String _hyperbolaAxis = 'Horizontal';
  ConicResult? _result;
  List<List<FunctionGraphPoint>>? _functionSegments;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: widget.includeFunctionGraphs ? 3 : 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final controller in [_centerX, _centerY, _radius, _axisX, _axisY, _p, _generalA, _generalB, _generalH, _generalG, _generalF, _generalC, _functionExpression]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _applyTemplate(ManualConicShape shape) {
    setState(() {
      _shape = shape;
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
      final result = _solver.solveGeneral(
        _generalValue(_generalA),
        2 * _generalValue(_generalH),
        _generalValue(_generalB),
        2 * _generalValue(_generalG),
        2 * _generalValue(_generalF),
        _generalValue(_generalC),
      );
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

  void _generateFunction() {
    try {
      final segments = _functionGraphEngine.sample(_functionExpression.text.trim());
      setState(() {
        _functionSegments = segments;
        _error = null;
      });
    } on MathException catch (error) {
      setState(() => _error = error.message);
    } on FormatException {
      setState(() => _error = 'Enter a valid expression in x, such as sin(x) or ln(x).');
    }
  }

  double _read(TextEditingController controller) => double.parse(controller.text.trim());

  double _generalValue(TextEditingController controller) => double.parse(controller.text.trim());

  double _signedParabolaP() {
    final value = _read(_p);
    return (_parabolaDirection == 'Left' || _parabolaDirection == 'Down') ? -value.abs() : value.abs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            const Tab(text: 'Pick a Shape'),
            const Tab(text: 'Enter Equation'),
            if (widget.includeFunctionGraphs) const Tab(text: 'Function Graphs'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabs,
          children: [
            _buildScrollView(context, _manualForm(context)),
            _buildScrollView(context, _equationForm(context)),
            if (widget.includeFunctionGraphs) _buildFunctionScrollView(context),
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
        Text('General second-degree equation', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('a x² + 2h xy + b y² + 2g x + 2f y + c = 0', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        _ParameterGrid(
          children: [
            _generalField('a', _generalA),
            _generalField('b', _generalB),
            _generalField('h', _generalH),
            _generalField('g', _generalG),
            _generalField('f', _generalF),
            _generalField('c', _generalC),
          ],
        ),
        const SizedBox(height: 12),
        _GeneralConicConditions(
          a: _tryGeneralValue(_generalA),
          b: _tryGeneralValue(_generalB),
          h: _tryGeneralValue(_generalH),
          g: _tryGeneralValue(_generalG),
          f: _tryGeneralValue(_generalF),
          c: _tryGeneralValue(_generalC),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(onPressed: _openGeneralGuidedEntry, icon: const Icon(Icons.dialpad_outlined), label: const Text('Fast coefficient entry')),
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: _generateEquation, icon: const Icon(Icons.auto_graph), label: const Text('Generate Graph')),
      ],
    );
  }

  Widget _buildFunctionScrollView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Plot supported expressions of x with radians for trigonometric functions. Pan or pinch to move through the graph, use +/- for one-handed zoom, or open full screen to inspect points.', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        Text('Function expression', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _functionExpression,
          decoration: const InputDecoration(labelText: 'y = f(x)', hintText: 'sin(x), exp(x), ln(x)', border: OutlineInputBorder()),
          autocorrect: false,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final example in const [
                'sin(x)', 'cos(x)', 'tan(x)',
                'asin(x)', 'acos(x)', 'atan(x)',
                'exp(x)', 'ln(x)', 'log(x)',
                'x^2', 'x^3', 'sqrt(x)',
                '1/x', 'abs(x)',
              ])
              ActionChip(
                label: Text(example),
                onPressed: () => setState(() => _functionExpression.text = example),
              ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: _generateFunction, icon: const Icon(Icons.show_chart), label: const Text('Generate Function Graph')),
        if (_error != null) ...[
          const SizedBox(height: 16),
          _StatusPanel(message: _error!, isError: true),
        ],
        if (_functionSegments != null) ...[
          const SizedBox(height: 20),
          SizedBox(height: 420, child: FunctionGraphView(expression: _functionExpression.text, segments: _functionSegments!)),
        ],
      ],
    );
  }

  Widget _numberField(String label, TextEditingController controller) => TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
  );

  Widget _generalField(String label, TextEditingController controller) => TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    onChanged: (_) => setState(() {}),
  );

  double? _tryGeneralValue(TextEditingController controller) => double.tryParse(controller.text.trim());

  void _openGeneralGuidedEntry() {
    final controllers = [_generalA, _generalB, _generalH, _generalG, _generalF, _generalC];
    GuidedNumberEntrySheet.show(
      context,
      title: 'General conic coefficients',
      labels: const ['a (x²)', 'b (y²)', 'h (2hxy)', 'g (2gx)', 'f (2fy)', 'c (constant)'],
      values: controllers.map((controller) => controller.text).toList(),
      onValue: (index, value) {
        controllers[index].text = value;
        setState(() {});
      },
      onFinished: _generateEquation,
    );
  }

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
        SizedBox(height: 400, child: ConicGraphView(result: result)),
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

class _GeneralConicConditions extends StatelessWidget {
  const _GeneralConicConditions({required this.a, required this.b, required this.h, required this.g, required this.f, required this.c});

  final double? a;
  final double? b;
  final double? h;
  final double? g;
  final double? f;
  final double? c;

  @override
  Widget build(BuildContext context) {
    if ([a, b, h, g, f, c].any((value) => value == null)) {
      return const _StatusPanel(message: 'Enter all six numeric coefficients to calculate the determinant and conditions.', isError: true);
    }
    final determinant = a! * b! * c! + 2 * h! * g! * f! - a! * f! * f! - b! * g! * g! - c! * h! * h!;
    final discriminant = h! * h! - a! * b!;
    const tolerance = 1e-9;
    final type = determinant.abs() < tolerance
        ? 'Degenerate conic'
        : discriminant < -tolerance
            ? (h!.abs() < tolerance && (a! - b!).abs() < tolerance ? 'Circle' : 'Ellipse')
            : discriminant > tolerance
                ? 'Hyperbola'
                : 'Parabola';
    final conditions = [
      'Determinant Delta = abc + 2hgf - af² - bg² - ch² = ${_format(determinant)}',
      'h² - ab = ${_format(discriminant)}',
      'Classification: $type',
      'Circle condition: h = 0 and a = b, with h² - ab < 0.',
      'Ellipse condition: h² - ab < 0.',
      'Parabola condition: h² - ab = 0.',
      'Hyperbola condition: h² - ab > 0.',
      if (determinant.abs() < tolerance) 'Delta = 0: the equation is degenerate; it may represent lines, a point, or no real locus.',
    ];
    return _StatusPanel(message: conditions.join('\n'), isError: determinant.abs() < tolerance);
  }

  String _format(double value) => value.toStringAsPrecision(7).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}
