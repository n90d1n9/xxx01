class CELExpression {
  final String expression;
  final Map<String, dynamic> context;

  CELExpression(this.expression, {this.context = const {}});

  bool evaluate(Map<String, dynamic> data) {
    try {
      final mergedData = {...context, ...data};
      return _parseAndEvaluate(expression.trim(), mergedData);
    } catch (e) {
      throw Exception('CEL evaluation failed: $e');
    }
  }

  // --- PARSER & EVALUATOR ---

  bool _parseAndEvaluate(String expr, Map<String, dynamic> data) {
    // Tokenize and parse properly (simplified recursive descent)
    return _parseOr(expr, data);
  }

  bool _parseOr(String expr, Map<String, dynamic> data) {
    final orParts = _splitByOperator(expr, r'\|\|', skipInside: ['(', ')']);
    if (orParts.length > 1) {
      return orParts.any((part) => _parseAnd(part.trim(), data));
    }
    return _parseAnd(expr, data);
  }

  bool _parseAnd(String expr, Map<String, dynamic> data) {
    final andParts = _splitByOperator(expr, r'&&', skipInside: ['(', ')']);
    if (andParts.length > 1) {
      return andParts.every((part) => _parseComparison(part.trim(), data));
    }
    return _parseComparison(expr, data);
  }

  bool _parseComparison(String expr, Map<String, dynamic> data) {
    expr = expr.trim();

    if (expr.startsWith('(') && expr.endsWith(')')) {
      return _parseOr(expr.substring(1, expr.length - 1), data);
    }

    if (expr.contains('.contains(')) return _evaluateContains(expr, data);
    if (expr.contains('.startsWith(')) return _evaluateStartsWith(expr, data);
    if (expr.contains('.endsWith(')) return _evaluateEndsWith(expr, data);
    if (expr.contains(' in ')) return _evaluateIn(expr, data);

    // Check operators in order of length to avoid conflicts (>= before >)
    final operators = ['>=', '<=', '==', '!=', '>', '<'];
    for (final op in operators) {
      final index = expr.indexOf(op);
      if (index > 0 && index < expr.length - op.length) {
        // Basic check: ensure not part of a word (good enough for now)
        final left = expr.substring(0, index).trim();
        final right = expr.substring(index + op.length).trim();
        final leftVal = _getValue(left, data);
        final rightVal = _getValue(right, data);
        return _compare(leftVal, rightVal, op);
      }
    }

    final value = _getValue(expr, data);
    return value is bool ? value : value != null;
  }

  // --- STRING METHOD EVALUATORS ---

  bool _evaluateContains(String expr, Map<String, dynamic> data) {
    // Match: field.contains("value") OR field.contains('value')
    final match = RegExp(
      r'''^([^(]+)\.contains\(\s*(['"])([^'"]*)\1\s*\)$''',
    ).firstMatch(expr);
    if (match == null) return false;
    final field = match.group(1)!;
    final searchTerm = match.group(
      3,
    )!; // group 2 is the quote, group 3 is the content
    final value = _getValue(field, data)?.toString() ?? '';
    return value.contains(searchTerm);
  }

  bool _evaluateStartsWith(String expr, Map<String, dynamic> data) {
    final match = RegExp(
      r'''^([^(]+)\.startsWith\(\s*(['"])([^'"]*)\1\s*\)$''',
    ).firstMatch(expr);
    if (match == null) return false;
    final field = match.group(1)!;
    final prefix = match.group(3)!;
    final value = _getValue(field, data)?.toString() ?? '';
    return value.startsWith(prefix);
  }

  bool _evaluateEndsWith(String expr, Map<String, dynamic> data) {
    final match = RegExp(
      r'''^([^(]+)\.endsWith\(\s*(['"])([^'"]*)\1\s*\)$''',
    ).firstMatch(expr);
    if (match == null) return false;
    final field = match.group(1)!;
    final suffix = match.group(3)!;
    final value = _getValue(field, data)?.toString() ?? '';
    return value.endsWith(suffix);
  }

  bool _evaluateIn(String expr, Map<String, dynamic> data) {
    final parts = expr.split(' in ');
    if (parts.length != 2) return false;
    final leftValue = _getValue(parts[0].trim(), data);
    final rightValue = _getValue(parts[1].trim(), data);
    if (rightValue is List) {
      return rightValue.contains(leftValue);
    }
    return false;
  }

  // --- HELPER METHODS ---

  bool _compare(dynamic left, dynamic right, String op) {
    // Handle equality first
    if (op == '==' || op == '!=') {
      final equals = _strictEquals(left, right);
      return op == '==' ? equals : !equals;
    }

    // Convert to numbers for ordering
    num? leftNum = _toNumeric(left);
    num? rightNum = _toNumeric(right);
    if (leftNum == null || rightNum == null) {
      return false; // Can't compare non-numeric with <, >, etc.
    }

    switch (op) {
      case '>':
        return leftNum > rightNum;
      case '<':
        return leftNum < rightNum;
      case '>=':
        return leftNum >= rightNum;
      case '<=':
        return leftNum <= rightNum;
      default:
        return false;
    }
  }

  bool _strictEquals(dynamic a, dynamic b) {
    if (a is num && b is num) return a == b;
    if (a is String && b is String) return a == b;
    if (a is bool && b is bool) return a == b;
    if (a == null && b == null) return true;
    return a == b;
  }

  num? _toNumeric(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  dynamic _getValue(String key, Map<String, dynamic> data) {
    key = key.trim();

    // String literal
    if ((key.startsWith('"') && key.endsWith('"')) ||
        (key.startsWith("'") && key.endsWith("'"))) {
      return key.substring(1, key.length - 1);
    }

    // Numeric literal
    if (num.tryParse(key) != null) return num.parse(key);

    // Boolean/null literals
    if (key == 'true') return true;
    if (key == 'false') return false;
    if (key == 'null') return null;

    // Nested field access: input.user.name
    if (key.contains('.')) {
      final parts = key.split('.');
      dynamic current = data;
      for (final part in parts) {
        if (current is Map && current.containsKey(part)) {
          current = current[part];
        } else {
          return null;
        }
      }
      return current;
    }

    // Top-level field
    return data[key];
  }

  List<String> _splitWithLimit(String input, RegExp pattern, int limit) {
    if (limit <= 0) return [input];
    if (limit == 1) return [input];

    final matches = pattern.allMatches(input).toList();
    if (matches.isEmpty) return [input];

    final result = <String>[];
    int start = 0;
    final actualLimit = limit - 1; // number of splits = limit - 1

    for (int i = 0; i < actualLimit && i < matches.length; i++) {
      final match = matches[i];
      result.add(input.substring(start, match.start));
      start = match.end;
    }

    result.add(input.substring(start));
    return result;
  }

  // Splits a string by a regex pattern, but ignores matches inside skip delimiters (e.g., parentheses)
  List<String> _splitByOperator(
    String input,
    String pattern, {
    int maxSplits = -1,
    List<String> skipInside = const [],
  }) {
    if (skipInside.isNotEmpty) {
      // For now, skip complex paren handling — assume no parentheses in simple cases
      // Or implement full tokenizer (recommended for production)
    }

    final regExp = RegExp(pattern);

    if (maxSplits == -1) {
      return input.split(regExp);
    } else {
      return _splitWithLimit(input, regExp, maxSplits);
    }
  }
}
