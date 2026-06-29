// Recursive-descent expression parser that converts tokens into ExprNode AST.
// Depends on expression_lexer.dart and ast_nodes.dart
//
// Usage:
//   final lexer = Lexer('global.x > 0 && facts.Member.count > 0');
//   final tokens = lexer.tokenize();
//   final parser = Parser(tokens);
//   final expr = parser.parse(); // ExprNode
//   final result = expr.evaluate(env);

import 'expression_lexer.dart';
import 'ast_nodes.dart';

class Parser {
  final List<Token> _tokens;
  int _current = 0;

  Parser(this._tokens);

  ExprNode parse() {
    if (_tokens.isEmpty) {
      throw FormatException('Empty token list');
    }
    _current = 0;
    final expr = _parseExpression();
    if (!_isAtEnd()) {
      throw FormatException('Unexpected token at end: ${_peek().lexeme}');
    }
    return expr;
  }

  // -----------------------------------------------------------------------
  // Grammar (higher-level entry)
  // expression -> or
  // or -> and ( ( "||" | "or" ) and )*
  // and -> equality ( ( "&&" | "and" ) equality )*
  // equality -> comparison ( ( "==" | "!=" ) comparison )*
  // comparison -> term ( ( ">" | "<" | ">=" | "<=" ) term )*
  // term -> factor ( ( "+" | "-" ) factor )*
  // factor -> unary ( ( "*" | "/" | "%" ) unary )*
  // unary -> ( "!" | "not" | "-" ) unary | primary
  // primary -> NUMBER | STRING | BOOLEAN | NULL | IDENTIFIER | "(" expression ")"
  // -----------------------------------------------------------------------

  ExprNode _parseExpression() => _parseOr();

  ExprNode _parseOr() {
    var expr = _parseAnd();

    while (_match([TokenType.orOp])) {
      final opToken = _previous();
      final right = _parseAnd();
      expr = BinaryOp('||', expr, right);
    }

    return expr;
  }

  ExprNode _parseAnd() {
    var expr = _parseEquality();

    while (_match([TokenType.andOp])) {
      final opToken = _previous();
      final right = _parseEquality();
      expr = BinaryOp('&&', expr, right);
    }

    return expr;
  }

  ExprNode _parseEquality() {
    var expr = _parseComparison();

    while (_match([TokenType.eq, TokenType.neq])) {
      final op = _previous();
      final right = _parseComparison();
      final opStr = op.type == TokenType.eq ? '==' : '!=';
      expr = BinaryOp(opStr, expr, right);
    }

    return expr;
  }

  ExprNode _parseComparison() {
    var expr = _parseTerm();

    while (_match([TokenType.gt, TokenType.lt, TokenType.gte, TokenType.lte])) {
      final op = _previous();
      final right = _parseTerm();

      String opStr;
      switch (op.type) {
        case TokenType.gt:
          opStr = '>';
          break;
        case TokenType.lt:
          opStr = '<';
          break;
        case TokenType.gte:
          opStr = '>=';
          break;
        case TokenType.lte:
          opStr = '<=';
          break;
        default:
          opStr = op.lexeme;
      }

      expr = BinaryOp(opStr, expr, right);
    }

    return expr;
  }

  ExprNode _parseTerm() {
    var expr = _parseFactor();

    while (_match([TokenType.plus, TokenType.minus])) {
      final op = _previous();
      final right = _parseFactor();
      final opStr = op.type == TokenType.plus ? '+' : '-';
      expr = BinaryOp(opStr, expr, right);
    }

    return expr;
  }

  ExprNode _parseFactor() {
    var expr = _parseUnary();

    while (_match([TokenType.star, TokenType.slash, TokenType.percent])) {
      final op = _previous();
      final right = _parseUnary();
      String opStr;
      switch (op.type) {
        case TokenType.star:
          opStr = '*';
          break;
        case TokenType.slash:
          opStr = '/';
          break;
        case TokenType.percent:
          opStr = '%';
          break;
        default:
          opStr = op.lexeme;
      }
      expr = BinaryOp(opStr, expr, right);
    }

    return expr;
  }

  ExprNode _parseUnary() {
    if (_match([TokenType.bang, TokenType.notOp])) {
      // unary NOT
      final op = _previous();
      final right = _parseUnary();
      return UnaryOp('!', right);
    }

    if (_match([TokenType.minus])) {
      final right = _parseUnary();
      return UnaryOp('-', right);
    }

    return _parsePrimary();
  }

  ExprNode _parsePrimary() {
    if (_match([TokenType.number])) {
      final lit = _previous().literal;
      if (lit is num) return NumberLiteral(lit);
      // fallback parse
      final parsed = num.tryParse(_previous().lexeme);
      if (parsed != null) return NumberLiteral(parsed);
      throw FormatException('Invalid numeric literal: ${_previous().lexeme}');
    }

    if (_match([TokenType.string])) {
      final lit = _previous().literal;
      return StringLiteral(lit?.toString() ?? '');
    }

    if (_match([TokenType.boolean])) {
      final lit = _previous().literal;
      return BoolLiteral(lit == true);
    }

    if (_match([TokenType.nullValue])) {
      return NullLiteral();
    }

    if (_match([TokenType.identifier])) {
      final name = _previous().lexeme;
      return Identifier(name);
    }

    if (_match([TokenType.lParen])) {
      final expr = _parseExpression();
      if (!_match([TokenType.rParen])) {
        throw FormatException('Expected closing ")" after expression');
      }
      return expr;
    }

    throw FormatException('Unexpected token: ${_peek().lexeme}');
  }

  // -----------------------------------------------------------------------
  // Token helpers
  // -----------------------------------------------------------------------

  bool _match(List<TokenType> types) {
    for (final t in types) {
      if (_check(t)) {
        _advance();
        return true;
      }
    }
    return false;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  bool _isAtEnd() => _peek().type == TokenType.eof;

  Token _peek() => _tokens[_current];
  Token _previous() => _tokens[_current - 1];
}
