import '../expression_engine/errors.dart';

/// Standard Simplex algorithm for solving linear programming problems.
/// Supports maximize/minimize with up to 4 variables and 6 constraints.
class SimplexSolver {
  const SimplexSolver();

  SimplexResult solve({
    required List<double> objective,
    required List<List<double>> constraints,
    required List<double> rhs,
    required List<String> constraintTypes,
    bool maximize = true,
  }) {
    final numVars = objective.length;
    final numConstraints = constraints.length;

    if (numVars < 1 || numVars > 4) {
      throw const MathDomainException('Number of variables must be between 1 and 4.');
    }
    if (numConstraints < 1 || numConstraints > 6) {
      throw const MathDomainException('Number of constraints must be between 1 and 6.');
    }

    // Convert to standard form (all <=, maximize)
    // Add slack variables
    final totalVars = numVars + numConstraints;
    final tableau = List.generate(
      numConstraints + 1,
      (i) => List.filled(totalVars + 1, 0.0),
    );

    // Fill constraint rows
    for (var i = 0; i < numConstraints; i++) {
      for (var j = 0; j < numVars; j++) {
        var coeff = constraints[i][j];
        if (constraintTypes[i] == '>=') coeff = -coeff;
        tableau[i][j] = coeff;
      }
      // Slack variable
      tableau[i][numVars + i] = 1.0;
      var rhsVal = rhs[i];
      if (constraintTypes[i] == '>=') rhsVal = -rhsVal;
      if (rhsVal < 0) {
        // Multiply entire row by -1
        for (var j = 0; j <= totalVars; j++) {
          tableau[i][j] = -tableau[i][j];
        }
        rhsVal = -rhsVal;
      }
      tableau[i][totalVars] = rhsVal;
    }

    // Fill objective row (negate for maximization in simplex)
    for (var j = 0; j < numVars; j++) {
      tableau[numConstraints][j] = maximize ? -objective[j] : objective[j];
    }

    // Basis tracking
    final basis = List.generate(numConstraints, (i) => numVars + i);

    // Simplex iterations (max 100 to prevent infinite loops)
    for (var iteration = 0; iteration < 100; iteration++) {
      // Find pivot column (most negative in objective row)
      var pivotCol = -1;
      var minVal = -1e-10;
      for (var j = 0; j < totalVars; j++) {
        if (tableau[numConstraints][j] < minVal) {
          minVal = tableau[numConstraints][j];
          pivotCol = j;
        }
      }
      if (pivotCol == -1) break; // Optimal

      // Find pivot row (minimum ratio test)
      var pivotRow = -1;
      var minRatio = double.infinity;
      for (var i = 0; i < numConstraints; i++) {
        if (tableau[i][pivotCol] > 1e-10) {
          final ratio = tableau[i][totalVars] / tableau[i][pivotCol];
          if (ratio < minRatio) {
            minRatio = ratio;
            pivotRow = i;
          }
        }
      }

      if (pivotRow == -1) {
        return SimplexResult(
          feasible: false,
          bounded: false,
          message: 'The problem is unbounded.',
          optimalValue: 0,
          variables: List.filled(numVars, 0),
        );
      }

      // Pivot
      basis[pivotRow] = pivotCol;
      final pivotValue = tableau[pivotRow][pivotCol];
      for (var j = 0; j <= totalVars; j++) {
        tableau[pivotRow][j] /= pivotValue;
      }
      for (var i = 0; i <= numConstraints; i++) {
        if (i == pivotRow) continue;
        final factor = tableau[i][pivotCol];
        for (var j = 0; j <= totalVars; j++) {
          tableau[i][j] -= factor * tableau[pivotRow][j];
        }
      }
    }

    // Extract solution
    final variables = List.filled(numVars, 0.0);
    for (var i = 0; i < numConstraints; i++) {
      if (basis[i] < numVars) {
        variables[basis[i]] = tableau[i][totalVars];
      }
    }

    final optimalValue = maximize
        ? tableau[numConstraints][totalVars]
        : -tableau[numConstraints][totalVars];

    return SimplexResult(
      feasible: true,
      bounded: true,
      message: 'Optimal solution found.',
      optimalValue: optimalValue,
      variables: variables,
    );
  }
}

class SimplexResult {
  const SimplexResult({
    required this.feasible,
    required this.bounded,
    required this.message,
    required this.optimalValue,
    required this.variables,
  });

  final bool feasible;
  final bool bounded;
  final String message;
  final double optimalValue;
  final List<double> variables;
}
