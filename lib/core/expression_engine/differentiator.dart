import 'errors.dart';
import 'expression_node.dart';

/// Symbolic differentiation over an [ExpressionNode] tree with respect to a
/// single variable (conventionally `x`). Implements the constant rule,
/// power rule, sum/difference rule, product rule, quotient rule, and the
/// chain rule for the standard function set supported by the evaluator.
///
/// This node tree result can be evaluated numerically (see
/// `ExpressionEvaluator`) or displayed symbolically after a light
/// simplification pass (`simplify`). General variable-exponent-of-variable
/// forms (`x^x`) are intentionally unsupported and raise a clear error
/// rather than guessing.
class Differentiator {
  const Differentiator({this.variable = 'x'});

  final String variable;

  ExpressionNode differentiate(ExpressionNode node) => simplify(_derive(node));

  ExpressionNode _derive(ExpressionNode node) {
    return switch (node) {
      NumberNode() => const NumberNode(0),
      VariableNode(:final name) => NumberNode(name == variable ? 1 : 0),
      UnaryOpNode(:final operatorSymbol, :final operand) => UnaryOpNode(operatorSymbol, _derive(operand)),
      BinaryOpNode(:final operatorSymbol, :final left, :final right) => _deriveBinary(operatorSymbol, left, right),
      FunctionCallNode(:final name, :final arguments) => _deriveFunction(name, arguments),
      FactorialNode() => throw const MathDomainException('The derivative of a factorial expression is not supported.'),
    };
  }

  ExpressionNode _deriveBinary(String operatorSymbol, ExpressionNode left, ExpressionNode right) {
    switch (operatorSymbol) {
      case '+':
        return BinaryOpNode('+', _derive(left), _derive(right));
      case '-':
        return BinaryOpNode('-', _derive(left), _derive(right));
      case '*':
        return BinaryOpNode(
          '+',
          BinaryOpNode('*', _derive(left), right),
          BinaryOpNode('*', left, _derive(right)),
        );
      case '/':
        return BinaryOpNode(
          '/',
          BinaryOpNode(
            '-',
            BinaryOpNode('*', _derive(left), right),
            BinaryOpNode('*', left, _derive(right)),
          ),
          BinaryOpNode('^', right, const NumberNode(2)),
        );
      case '^':
        return _derivePower(left, right);
      default:
        throw MathEvaluationException('Cannot differentiate operator: $operatorSymbol');
    }
  }

  ExpressionNode _derivePower(ExpressionNode base, ExpressionNode exponent) {
    if (exponent is NumberNode) {
      // Generalized power rule: d/dx[u^n] = n * u^(n-1) * u'
      final reducedExponent = NumberNode(exponent.value - 1);
      return BinaryOpNode(
        '*',
        BinaryOpNode('*', NumberNode(exponent.value), BinaryOpNode('^', base, reducedExponent)),
        _derive(base),
      );
    }
    if (base is NumberNode) {
      // d/dx[a^u] = a^u * ln(a) * u'
      return BinaryOpNode(
        '*',
        BinaryOpNode('*', BinaryOpNode('^', base, exponent), FunctionCallNode('ln', [base])),
        _derive(exponent),
      );
    }
    throw const MathDomainException('Differentiating a variable exponent of a variable base is not supported.');
  }

  ExpressionNode _deriveFunction(String name, List<ExpressionNode> arguments) {
    if (arguments.length != 1) {
      throw MathEvaluationException('Cannot differentiate $name with ${arguments.length} arguments.');
    }
    final argument = arguments.first;
    final argumentDerivative = _derive(argument);
    ExpressionNode chain(ExpressionNode outerDerivative) => BinaryOpNode('*', outerDerivative, argumentDerivative);

    return switch (name) {
      'sin' => chain(FunctionCallNode('cos', [argument])),
      'cos' => chain(UnaryOpNode('-', FunctionCallNode('sin', [argument]))),
      'tan' => chain(BinaryOpNode('^', FunctionCallNode('sec', [argument]), const NumberNode(2))),
      'exp' => chain(FunctionCallNode('exp', [argument])),
      'ln' => chain(BinaryOpNode('/', const NumberNode(1), argument)),
      'log' => chain(BinaryOpNode('/', const NumberNode(1), BinaryOpNode('*', argument, FunctionCallNode('ln', [const NumberNode(10)])))),
      'sqrt' => chain(BinaryOpNode('/', const NumberNode(1), BinaryOpNode('*', const NumberNode(2), FunctionCallNode('sqrt', [argument])))),
      _ => throw MathEvaluationException('Differentiation of $name is not supported.'),
    };
  }

  /// A best-effort simplifier that folds obvious identities (`x+0`, `x*1`,
  /// `x*0`, `0-x`) so repeated differentiation doesn't produce absurdly
  /// large trees. This is not a full computer-algebra simplifier.
  ExpressionNode simplify(ExpressionNode node) {
    if (node is BinaryOpNode) {
      final left = simplify(node.left);
      final right = simplify(node.right);
      if (left is NumberNode && right is NumberNode) {
        return switch (node.operatorSymbol) {
          '+' => NumberNode(left.value + right.value),
          '-' => NumberNode(left.value - right.value),
          '*' => NumberNode(left.value * right.value),
          '^' when right.value >= 0 => NumberNode(_pow(left.value, right.value)),
          _ => BinaryOpNode(node.operatorSymbol, left, right),
        };
      }
      if (node.operatorSymbol == '+' && left is NumberNode && left.value == 0) return right;
      if (node.operatorSymbol == '+' && right is NumberNode && right.value == 0) return left;
      if (node.operatorSymbol == '-' && right is NumberNode && right.value == 0) return left;
      if (node.operatorSymbol == '*' && (left is NumberNode && left.value == 0 || right is NumberNode && right.value == 0)) {
        return const NumberNode(0);
      }
      if (node.operatorSymbol == '*' && left is NumberNode && left.value == 1) return right;
      if (node.operatorSymbol == '*' && right is NumberNode && right.value == 1) return left;
      if (node.operatorSymbol == '^' && right is NumberNode && right.value == 1) return left;
      return BinaryOpNode(node.operatorSymbol, left, right);
    }
    if (node is UnaryOpNode) {
      final operand = simplify(node.operand);
      if (operand is NumberNode) {
        return NumberNode(node.operatorSymbol == '-' ? -operand.value : operand.value);
      }
      return UnaryOpNode(node.operatorSymbol, operand);
    }
    if (node is FunctionCallNode) {
      return FunctionCallNode(node.name, node.arguments.map(simplify).toList());
    }
    return node;
  }

  double _pow(double base, double exponent) {
    var result = 1.0;
    final count = exponent.round();
    for (var i = 0; i < count; i++) {
      result *= base;
    }
    return result;
  }
}
