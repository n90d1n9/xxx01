import 'dart:math' as math;

import 'cel_exception.dart';

class CELEvaluator {
  final Map<String, Function> _functions = {};
  final Map<String, dynamic> _macros = {};

  CELEvaluator() {
    _registerStandardFunctions();
  }

  /// Register standard CEL functions
  void _registerStandardFunctions() {
    // String functions
    _functions['size'] = (dynamic value) {
      if (value is String) return value.length;
      if (value is List) return value.length;
      if (value is Map) return value.length;
      throw CELEvaluationException('size() requires string, list, or map');
    };

    _functions['contains'] = (String str, String substr) =>
        str.contains(substr);
    _functions['startsWith'] = (String str, String prefix) =>
        str.startsWith(prefix);
    _functions['endsWith'] = (String str, String suffix) =>
        str.endsWith(suffix);
    _functions['matches'] = (String str, String pattern) {
      try {
        return RegExp(pattern).hasMatch(str);
      } catch (e) {
        throw CELEvaluationException('Invalid regex pattern: $pattern');
      }
    };

    // List functions
    _functions['filter'] = (List list, Function predicate) {
      return list.where((item) => predicate(item) == true).toList();
    };

    _functions['map'] = (List list, Function mapper) {
      return list.map((item) => mapper(item)).toList();
    };

    _functions['exists'] = (List list, Function predicate) {
      return list.any((item) => predicate(item) == true);
    };

    _functions['all'] = (List list, Function predicate) {
      return list.every((item) => predicate(item) == true);
    };

    // Type conversion
    _functions['int'] = (dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    };

    _functions['double'] = (dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    };

    _functions['string'] = (dynamic value) => value.toString();

    // Math functions
    _functions['abs'] = (num value) => value.abs();
    _functions['ceil'] = (num value) => value.ceil();
    _functions['floor'] = (num value) => value.floor();
    _functions['round'] = (num value) => value.round();
    _functions['min'] = (num a, num b) => math.min(a, b);
    _functions['max'] = (num a, num b) => math.max(a, b);

    // Utility functions
    _functions['has'] = (Map map, String key) => map.containsKey(key);
    _functions['timestamp'] = () => DateTime.now().millisecondsSinceEpoch;
    _functions['duration'] = (String duration) => _parseDuration(duration);
  }

  Duration _parseDuration(String duration) {
    final regex = RegExp(r'(\d+)([smhd])');
    final match = regex.firstMatch(duration);
    if (match == null) {
      throw CELEvaluationException('Invalid duration format: $duration');
    }

    final value = int.parse(match.group(1)!);
    final unit = match.group(2)!;

    switch (unit) {
      case 's':
        return Duration(seconds: value);
      case 'm':
        return Duration(minutes: value);
      case 'h':
        return Duration(hours: value);
      case 'd':
        return Duration(days: value);
      default:
        throw CELEvaluationException('Unknown duration unit: $unit');
    }
  }

  /// Register custom function
  void registerFunction(String name, Function function) {
    _functions[name] = function;
  }

  /// Evaluate CEL expression
  dynamic evaluate(String expression, Map<String, dynamic> context) {
    try {
      final tokens = _tokenize(expression);
      final parser = _CELParser(tokens, context, _functions);
      return parser.parse();
    } catch (e) {
      if (e is CELEvaluationException) rethrow;
      throw CELEvaluationException(
        'Evaluation error: $e',
        expression: expression,
      );
    }
  }

  /// Tokenize expression
  List<_Token> _tokenize(String expression) {
    final tokens = <_Token>[];
    var i = 0;

    while (i < expression.length) {
      final char = expression[i];

      // Skip whitespace
      if (char == ' ' || char == '\t' || char == '\n' || char == '\r') {
        i++;
        continue;
      }

      // String literals
      if (char == '"' || char == "'") {
        final quote = char;
        var value = '';
        i++;
        while (i < expression.length && expression[i] != quote) {
          if (expression[i] == '\\' && i + 1 < expression.length) {
            i++;
            switch (expression[i]) {
              case 'n':
                value += '\n';
                break;
              case 't':
                value += '\t';
                break;
              case 'r':
                value += '\r';
                break;
              default:
                value += expression[i];
            }
          } else {
            value += expression[i];
          }
          i++;
        }
        tokens.add(_Token(_TokenType.string, value));
        i++;
        continue;
      }

      // Numbers
      if (char.contains(RegExp(r'[0-9]'))) {
        var value = '';
        while (i < expression.length &&
            expression[i].contains(RegExp(r'[0-9.]'))) {
          value += expression[i];
          i++;
        }
        tokens.add(
          _Token(
            _TokenType.number,
            value.contains('.') ? double.parse(value) : int.parse(value),
          ),
        );
        continue;
      }

      // Identifiers and keywords
      if (char.contains(RegExp(r'[a-zA-Z_]'))) {
        var value = '';
        while (i < expression.length &&
            expression[i].contains(RegExp(r'[a-zA-Z0-9_]'))) {
          value += expression[i];
          i++;
        }

        // Check for keywords
        switch (value) {
          case 'true':
            tokens.add(_Token(_TokenType.boolean, true));
            break;
          case 'false':
            tokens.add(_Token(_TokenType.boolean, false));
            break;
          case 'null':
            tokens.add(_Token(_TokenType.null_, null));
            break;
          case 'in':
            tokens.add(_Token(_TokenType.in_, value));
            break;
          default:
            tokens.add(_Token(_TokenType.identifier, value));
        }
        continue;
      }

      // Operators and symbols
      if (i + 1 < expression.length) {
        final twoChar = expression.substring(i, i + 2);
        switch (twoChar) {
          case '==':
          case '!=':
          case '<=':
          case '>=':
          case '&&':
          case '||':
            tokens.add(_Token(_TokenType.operator, twoChar));
            i += 2;
            continue;
        }
      }

      // Single character tokens
      switch (char) {
        case '+':
        case '-':
        case '*':
        case '/':
        case '%':
        case '<':
        case '>':
        case '!':
          tokens.add(_Token(_TokenType.operator, char));
          break;
        case '(':
          tokens.add(_Token(_TokenType.leftParen, char));
          break;
        case ')':
          tokens.add(_Token(_TokenType.rightParen, char));
          break;
        case '[':
          tokens.add(_Token(_TokenType.leftBracket, char));
          break;
        case ']':
          tokens.add(_Token(_TokenType.rightBracket, char));
          break;
        case '{':
          tokens.add(_Token(_TokenType.leftBrace, char));
          break;
        case '}':
          tokens.add(_Token(_TokenType.rightBrace, char));
          break;
        case '.':
          tokens.add(_Token(_TokenType.dot, char));
          break;
        case ',':
          tokens.add(_Token(_TokenType.comma, char));
          break;
        case ':':
          tokens.add(_Token(_TokenType.colon, char));
          break;
        case '?':
          tokens.add(_Token(_TokenType.question, char));
          break;
        default:
          throw CELEvaluationException('Unexpected character: $char');
      }
      i++;
    }

    return tokens;
  }
}

enum _TokenType {
  number,
  string,
  boolean,
  null_,
  identifier,
  operator,
  leftParen,
  rightParen,
  leftBracket,
  rightBracket,
  leftBrace,
  rightBrace,
  dot,
  comma,
  colon,
  question,
  in_,
}

class _Token {
  final _TokenType type;
  final dynamic value;

  _Token(this.type, this.value);

  @override
  String toString() => 'Token($type, $value)';
}

// ==================== Parser ====================

class _CELParser {
  final List<_Token> tokens;
  final Map<String, dynamic> context;
  final Map<String, Function> functions;
  int position = 0;

  _CELParser(this.tokens, this.context, this.functions);

  _Token get current => position < tokens.length
      ? tokens[position]
      : _Token(_TokenType.null_, null);
  bool get hasMore => position < tokens.length;

  void advance() => position++;

  dynamic parse() {
    if (!hasMore) {
      throw CELEvaluationException('Empty expression');
    }
    return _parseTernary();
  }

  dynamic _parseTernary() {
    var expr = _parseLogicalOr();

    if (hasMore && current.type == _TokenType.question) {
      advance(); // consume '?'
      final trueValue = _parseLogicalOr();

      if (!hasMore || current.type != _TokenType.colon) {
        throw CELEvaluationException('Expected : in ternary expression');
      }
      advance(); // consume ':'

      final falseValue = _parseLogicalOr();
      return expr ? trueValue : falseValue;
    }

    return expr;
  }

  dynamic _parseLogicalOr() {
    var left = _parseLogicalAnd();

    while (hasMore &&
        current.type == _TokenType.operator &&
        current.value == '||') {
      advance();
      final right = _parseLogicalAnd();
      left = _toBool(left) || _toBool(right);
    }

    return left;
  }

  dynamic _parseLogicalAnd() {
    var left = _parseComparison();

    while (hasMore &&
        current.type == _TokenType.operator &&
        current.value == '&&') {
      advance();
      final right = _parseComparison();
      left = _toBool(left) && _toBool(right);
    }

    return left;
  }

  dynamic _parseComparison() {
    var left = _parseAdditive();

    if (hasMore && current.type == _TokenType.operator) {
      final op = current.value;
      if (['==', '!=', '<', '<=', '>', '>='].contains(op)) {
        advance();
        final right = _parseAdditive();
        return _compare(left, op, right);
      }
    }

    if (hasMore && current.type == _TokenType.in_) {
      advance();
      final right = _parseAdditive();
      if (right is List) {
        return right.contains(left);
      } else if (right is Map) {
        return right.containsKey(left);
      }
      throw CELEvaluationException('in operator requires list or map');
    }

    return left;
  }

  bool _compare(dynamic left, String op, dynamic right) {
    switch (op) {
      case '==':
        return left == right;
      case '!=':
        return left != right;
      case '<':
        return (left as num) < (right as num);
      case '<=':
        return (left as num) <= (right as num);
      case '>':
        return (left as num) > (right as num);
      case '>=':
        return (left as num) >= (right as num);
      default:
        throw CELEvaluationException('Unknown comparison operator: $op');
    }
  }

  dynamic _parseAdditive() {
    var left = _parseMultiplicative();

    while (hasMore && current.type == _TokenType.operator) {
      final op = current.value;
      if (op == '+' || op == '-') {
        advance();
        final right = _parseMultiplicative();
        if (op == '+') {
          if (left is String || right is String) {
            left = left.toString() + right.toString();
          } else {
            left = (left as num) + (right as num);
          }
        } else {
          left = (left as num) - (right as num);
        }
      } else {
        break;
      }
    }

    return left;
  }

  dynamic _parseMultiplicative() {
    var left = _parseUnary();

    while (hasMore && current.type == _TokenType.operator) {
      final op = current.value;
      if (op == '*' || op == '/' || op == '%') {
        advance();
        final right = _parseUnary();
        switch (op) {
          case '*':
            left = (left as num) * (right as num);
            break;
          case '/':
            if ((right as num) == 0) {
              throw CELEvaluationException('Division by zero');
            }
            left = (left as num) / (right as num);
            break;
          case '%':
            left = (left as num) % (right as num);
            break;
        }
      } else {
        break;
      }
    }

    return left;
  }

  dynamic _parseUnary() {
    if (hasMore && current.type == _TokenType.operator) {
      final op = current.value;
      if (op == '!' || op == '-') {
        advance();
        final operand = _parseUnary();
        if (op == '!') {
          return !_toBool(operand);
        } else {
          return -(operand as num);
        }
      }
    }

    return _parsePostfix();
  }

  dynamic _parsePostfix() {
    var value = _parsePrimary();

    while (hasMore) {
      if (current.type == _TokenType.dot) {
        advance();
        if (!hasMore || current.type != _TokenType.identifier) {
          throw CELEvaluationException('Expected identifier after dot');
        }
        final member = current.value;
        advance();

        if (value is Map) {
          value = value[member];
        } else {
          throw CELEvaluationException(
            'Cannot access member $member on ${value.runtimeType}',
          );
        }
      } else if (current.type == _TokenType.leftBracket) {
        advance();
        final index = _parseTernary();
        if (!hasMore || current.type != _TokenType.rightBracket) {
          throw CELEvaluationException('Expected ]');
        }
        advance();

        if (value is List) {
          value = value[index as int];
        } else if (value is Map) {
          value = value[index];
        } else {
          throw CELEvaluationException('Cannot index ${value.runtimeType}');
        }
      } else if (current.type == _TokenType.leftParen) {
        // Function call
        if (value is! String || !functions.containsKey(value)) {
          throw CELEvaluationException('Unknown function: $value');
        }
        final funcName = value as String;
        advance(); // consume '('

        final args = <dynamic>[];
        while (hasMore && current.type != _TokenType.rightParen) {
          args.add(_parseTernary());
          if (hasMore && current.type == _TokenType.comma) {
            advance();
          }
        }

        if (!hasMore || current.type != _TokenType.rightParen) {
          throw CELEvaluationException('Expected )');
        }
        advance();

        value = Function.apply(functions[funcName]!, args);
      } else {
        break;
      }
    }

    return value;
  }

  dynamic _parsePrimary() {
    if (!hasMore) {
      throw CELEvaluationException('Unexpected end of expression');
    }

    final token = current;

    switch (token.type) {
      case _TokenType.number:
      case _TokenType.string:
      case _TokenType.boolean:
      case _TokenType.null_:
        advance();
        return token.value;

      case _TokenType.identifier:
        final name = token.value as String;
        advance();

        // Check if it's a function call
        if (hasMore && current.type == _TokenType.leftParen) {
          position--; // Go back to process as function
          return name;
        }

        // Variable lookup
        final parts = name.split('.');
        dynamic value = context;
        for (final part in parts) {
          if (value is Map && value.containsKey(part)) {
            value = value[part];
          } else {
            throw CELEvaluationException('Undefined variable: $name');
          }
        }
        return value;

      case _TokenType.leftParen:
        advance();
        final value = _parseTernary();
        if (!hasMore || current.type != _TokenType.rightParen) {
          throw CELEvaluationException('Expected )');
        }
        advance();
        return value;

      case _TokenType.leftBracket:
        advance();
        final list = <dynamic>[];
        while (hasMore && current.type != _TokenType.rightBracket) {
          list.add(_parseTernary());
          if (hasMore && current.type == _TokenType.comma) {
            advance();
          }
        }
        if (!hasMore || current.type != _TokenType.rightBracket) {
          throw CELEvaluationException('Expected ]');
        }
        advance();
        return list;

      case _TokenType.leftBrace:
        advance();
        final map = <dynamic, dynamic>{};
        while (hasMore && current.type != _TokenType.rightBrace) {
          final key = _parseTernary();
          if (!hasMore || current.type != _TokenType.colon) {
            throw CELEvaluationException('Expected : in map literal');
          }
          advance();
          final value = _parseTernary();
          map[key] = value;

          if (hasMore && current.type == _TokenType.comma) {
            advance();
          }
        }
        if (!hasMore || current.type != _TokenType.rightBrace) {
          throw CELEvaluationException('Expected }');
        }
        advance();
        return map;

      default:
        throw CELEvaluationException('Unexpected token: ${token.type}');
    }
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value == null) return false;
    if (value is num) return value != 0;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }
}
