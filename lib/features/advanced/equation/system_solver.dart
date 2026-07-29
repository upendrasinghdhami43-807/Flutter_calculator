import '../../../core/linear_algebra/linear_system_solver.dart';

/// Formats the shared Gauss-Jordan solver's three possible outcomes for the
/// Equation screen without changing its numerical behavior.
class SystemEquationSolver {
  const SystemEquationSolver({this.solver = const LinearSystemSolver()});

  final LinearSystemSolver solver;

  String solveAndFormat(List<List<double>> coefficients, List<double> constants) {
    final solution = solver.solve(coefficients, constants);
    return switch (solution.type) {
      SystemSolutionType.unique => solution.values.asMap().entries.map((entry) => 'x${entry.key + 1} = ${_format(entry.value)}').join('\n'),
      SystemSolutionType.none => 'No solution. The equations are inconsistent.',
      SystemSolutionType.infinite => 'Infinitely many solutions. The equations are dependent.',
    };
  }

  String _format(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsPrecision(10).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}
