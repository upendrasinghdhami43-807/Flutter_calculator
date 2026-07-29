import 'errors.dart';

enum TokenType { number, identifier, operator, leftParen, rightParen, comma, end }

class Token {
  const Token(this.type, this.lexeme);

  final TokenType type;
  final String lexeme;
}

class Tokenizer {
  const Tokenizer();

  List<Token> tokenize(String source) {
    final tokens = <Token>[];
    var index = 0;
    while (index < source.length) {
      final character = source[index];
      if (character.trim().isEmpty) {
        index++;
      } else if (_isDigit(character) || character == '.') {
        final start = index++;
        while (index < source.length &&
            (_isDigit(source[index]) || source[index] == '.')) {
          index++;
        }
        final value = source.substring(start, index);
        if (value == '.' || value.split('.').length > 2) {
          throw MathParseException('Invalid number: $value');
        }
        tokens.add(Token(TokenType.number, value));
      } else if (_isLetter(character)) {
        final start = index++;
        while (index < source.length && _isLetter(source[index])) {
          index++;
        }
        tokens.add(Token(TokenType.identifier, source.substring(start, index)));
      } else if ('+-*/^%!'.contains(character)) {
        tokens.add(Token(TokenType.operator, character));
        index++;
      } else if (character == '(') {
        tokens.add(const Token(TokenType.leftParen, '('));
        index++;
      } else if (character == ')') {
        tokens.add(const Token(TokenType.rightParen, ')'));
        index++;
      } else if (character == ',') {
        tokens.add(const Token(TokenType.comma, ','));
        index++;
      } else {
        throw MathParseException('Unsupported character: $character');
      }
    }
    tokens.add(const Token(TokenType.end, ''));
    return tokens;
  }

  bool _isDigit(String value) => value.codeUnitAt(0) >= 48 && value.codeUnitAt(0) <= 57;

  bool _isLetter(String value) {
    final code = value.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }
}
