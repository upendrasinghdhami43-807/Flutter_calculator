sealed class ExpressionNode {
  const ExpressionNode();
}

final class NumberNode extends ExpressionNode {
  const NumberNode(this.value);

  final double value;
}

final class VariableNode extends ExpressionNode {
  const VariableNode(this.name);

  final String name;
}

final class UnaryOpNode extends ExpressionNode {
  const UnaryOpNode(this.operatorSymbol, this.operand);

  final String operatorSymbol;
  final ExpressionNode operand;
}

final class BinaryOpNode extends ExpressionNode {
  const BinaryOpNode(this.operatorSymbol, this.left, this.right);

  final String operatorSymbol;
  final ExpressionNode left;
  final ExpressionNode right;
}

final class FunctionCallNode extends ExpressionNode {
  const FunctionCallNode(this.name, this.arguments);

  final String name;
  final List<ExpressionNode> arguments;
}

final class FactorialNode extends ExpressionNode {
  const FactorialNode(this.operand);

  final ExpressionNode operand;
}
