import 'errors.dart';
import 'expression_node.dart';
import 'tokenizer.dart';

class ExpressionParser {
  ExpressionParser({this.tokenizer = const Tokenizer()});

  final Tokenizer tokenizer;
  late List<Token> _tokens;
  var _current = 0;

  ExpressionNode parse(String source) {
    _tokens = tokenizer.tokenize(source);
    _current = 0;
    final expression = _parseAddSubtract();
    if (!_isAtEnd) {
      throw MathParseException('Unexpected token: ${_peek.lexeme}');
    }
    return expression;
  }

  ExpressionNode _parseAddSubtract() {
    var node = _parseMultiplyDivide();
    while (_matchOperator('+') || _matchOperator('-')) {
      final operatorSymbol = _previous.lexeme;
      node = BinaryOpNode(operatorSymbol, node, _parseMultiplyDivide());
    }
    return node;
  }

  ExpressionNode _parseMultiplyDivide() {
    var node = _parsePower();
    while (true) {
      if (_matchOperator('*') || _matchOperator('/') || _matchOperator('%')) {
        final operatorSymbol = _previous.lexeme;
        node = BinaryOpNode(operatorSymbol, node, _parsePower());
      } else if (_startsPrimary(_peek)) {
        node = BinaryOpNode('*', node, _parsePower());
      } else {
        return node;
      }
    }
  }

  ExpressionNode _parsePower() {
    var node = _parseUnary();
    if (_matchOperator('^')) {
      node = BinaryOpNode('^', node, _parsePower());
    }
    return node;
  }

  ExpressionNode _parseUnary() {
    if (_matchOperator('-') || _matchOperator('+')) {
      return UnaryOpNode(_previous.lexeme, _parseUnary());
    }
    return _parsePrimary();
  }

  ExpressionNode _parsePrimary() {
    if (_match(TokenType.number)) {
      return NumberNode(double.parse(_previous.lexeme));
    }
    if (_match(TokenType.identifier)) {
      final name = _previous.lexeme.toLowerCase();
      if (_match(TokenType.leftParen)) {
        final argument = _parseAddSubtract();
        _consume(TokenType.rightParen, 'Expected ) after function argument.');
        return FunctionCallNode(name, argument);
      }
      return VariableNode(name);
    }
    if (_match(TokenType.leftParen)) {
      final node = _parseAddSubtract();
      _consume(TokenType.rightParen, 'Expected ) after expression.');
      return node;
    }
    throw MathParseException('Expected a number, variable, or (.');
  }

  bool _startsPrimary(Token token) =>
      token.type == TokenType.number || token.type == TokenType.identifier || token.type == TokenType.leftParen;

  bool _match(TokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  bool _matchOperator(String operatorSymbol) {
    if (_check(TokenType.operator) && _peek.lexeme == operatorSymbol) {
      _advance();
      return true;
    }
    return false;
  }

  void _consume(TokenType type, String message) {
    if (_match(type)) {
      return;
    }
    throw MathParseException(message);
  }

  bool _check(TokenType type) => !_isAtEnd && _peek.type == type;
  Token _advance() => _tokens[_current++];
  bool get _isAtEnd => _peek.type == TokenType.end;
  Token get _peek => _tokens[_current];
  Token get _previous => _tokens[_current - 1];
}
