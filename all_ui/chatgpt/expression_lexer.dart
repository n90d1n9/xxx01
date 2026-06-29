// Tokenizer for expression parsing. Converts a raw string into Tokens.
// Supports identifiers, numbers, string literals, logical operators,
// comparison operators, arithmetic operators, parentheses, keywords,
// and dot-path identifiers like "facts.Member.count".

enum TokenType {
  identifier,
  number,
  string,
  boolean,
  nullValue,
  lParen,
  rParen,
  comma,

  // operators
  plus,
  minus,
  star,
  slash,
  percent,
  bang,

  andOp,
  orOp,
  notOp,

  eq, // ==
  neq, // !=
  gt, // >
  lt, // <
  gte, // >=
  lte, // <=

  eof,
}

class Token {
  final TokenType type;
  final String lexeme; // raw text
  final dynamic literal; // parsed literal value (num, string, bool)
  final int position;

  Token(this.type, this.lexeme, this.literal, this.position);

  @override
  String toString() =>
      'Token(type: $type, lexeme: "$lexeme", literal: $literal, pos: $position)';
}

class Lexer {
  final String source;
  int _start = 0;
  int _current = 0;

  Lexer(this.source);

  List<Token> tokenize() {
    final tokens = <Token>[];

    while (!_isAtEnd()) {
      _start = _current;
      final token = _scanToken();
      if (token != null) tokens.add(token);
    }

    tokens.add(Token(TokenType.eof, '', null, _current));
    return tokens;
  }

  Token? _scanToken() {
    final c = _advance();

    switch (c) {
      case ' ':
      case '\r':
      case '\t':
      case '\n':
        return null; // ignore whitespace

      case '(':
        return _token(TokenType.lParen);
      case ')':
        return _token(TokenType.rParen);
      case ',':
        return _token(TokenType.comma);

      case '+':
        return _token(TokenType.plus);
      case '-':
        return _token(TokenType.minus);
      case '*':
        return _token(TokenType.star);
      case '/':
        return _token(TokenType.slash);
      case '%':
        return _token(TokenType.percent);

      case '!':
        if (_match('=')) return _token(TokenType.neq, '!=');
        return _token(TokenType.bang);

      case '=':
        if (_match('=')) return _token(TokenType.eq, '==');
        throw _error('Unexpected "=" — did you mean "=="?');

      case '>':
        if (_match('=')) return _token(TokenType.gte, '>=');
        return _token(TokenType.gt);

      case '<':
        if (_match('=')) return _token(TokenType.lte, '<=');
        return _token(TokenType.lt);

      case '&':
        if (_match('&')) return _token(TokenType.andOp, '&&');
        throw _error('Unexpected "&" — did you mean "&&"?');

      case '|':
        if (_match('|')) return _token(TokenType.orOp, '||');
        throw _error('Unexpected "|" — did you mean "||"?');

      case '"':
      case "'":
        return _string(c);
    }

    if (_isDigit(c)) return _number();
    if (_isAlpha(c)) return _identifier();

    throw _error('Unexpected character: "$c"');
  }

  Token _token(TokenType type, [String? lex]) {
    final text = lex ?? source.substring(_start, _current);
    return Token(type, text, null, _start);
  }

  /// Handle string literal: single or double quotes.
  Token _string(String quote) {
    while (!_isAtEnd() && _peek() != quote) {
      _advance();
    }

    if (_isAtEnd()) throw _error('Unterminated string literal');

    // closing quote
    _advance();

    final value = source.substring(_start + 1, _current - 1);
    return Token(TokenType.string, value, value, _start);
  }

  /// Number literal (supports int & double)
  Token _number() {
    while (_isDigit(_peek())) _advance();

    // decimal fraction
    if (_peek() == '.' && _isDigit(_peekNext())) {
      _advance();
      while (_isDigit(_peek())) _advance();
    }

    final text = source.substring(_start, _current);
    final value = num.tryParse(text);
    return Token(TokenType.number, text, value, _start);
  }

  /// Identifier, boolean literal, null literal,
  /// OR keyword `and`, `or`, `not`.
  Token _identifier() {
    while (_isAlphaNumeric(_peek()) || _peek() == '.') {
      _advance();
    }

    final text = source.substring(_start, _current).trim();

    switch (text) {
      case 'true':
        return Token(TokenType.boolean, text, true, _start);
      case 'false':
        return Token(TokenType.boolean, text, false, _start);
      case 'null':
        return Token(TokenType.nullValue, text, null, _start);
      case 'and':
        return Token(TokenType.andOp, text, null, _start);
      case 'or':
        return Token(TokenType.orOp, text, null, _start);
      case 'not':
        return Token(TokenType.notOp, text, null, _start);
    }

    return Token(TokenType.identifier, text, text, _start);
  }

  String _advance() => source[_current++];

  bool _match(String expected) {
    if (_isAtEnd()) return false;
    if (source[_current] != expected) return false;
    _current++;
    return true;
  }

  String _peek() => _isAtEnd() ? '\u0000' : source[_current];
  String _peekNext() {
    if (_current + 1 >= source.length) return '\u0000';
    return source[_current + 1];
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _isAlpha(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) || // A-Z
        (code >= 97 && code <= 122) || // a-z
        (c == '_');
  }

  bool _isAlphaNumeric(String c) => _isAlpha(c) || _isDigit(c);

  bool _isAtEnd() => _current >= source.length;

  Exception _error(String msg) => FormatException('$msg at $_current');
}
