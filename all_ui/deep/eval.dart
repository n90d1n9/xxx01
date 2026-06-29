import 'rule_engine.dart';

class RobustExpressionEvaluator implements ExpressionEvaluator, FactMatcher {
  @override
  bool evalCondition(dynamic condition, RuleContext context) {
    if (condition is bool) return condition;
    if (condition is num) return condition != 0;
    if (condition is String) {
      return _evalBooleanExpression(condition.trim(), context);
    }
    return false;
  }

  @override
  dynamic evalValue(dynamic expression, RuleContext context) {
    if (expression == null) return null;
    if (expression is num || expression is bool) return expression;
    if (expression is Map || expression is List) return expression;
    if (expression is String)
      return _resolveExpression(expression.trim(), context);
    return expression;
  }

  @override
  bool matches(Fact fact, String predicate) {
    return _evalPredicateOnFact(predicate, fact);
  }

  // ---------------------------------------------------------------------------
  // Improved Boolean Expression Evaluation
  // ---------------------------------------------------------------------------

  bool _evalBooleanExpression(String expression, RuleContext context) {
    if (expression.isEmpty) return false;

    // Handle parentheses
    if (_isParenthesized(expression)) {
      final inner = expression.substring(1, expression.length - 1).trim();
      return _evalBooleanExpression(inner, context);
    }

    // Handle NOT operator
    if (expression.startsWith('not ')) {
      return !_evalBooleanExpression(expression.substring(4).trim(), context);
    }

    // Handle OR
    final orParts = _splitByOperator(expression, ' or ');
    if (orParts.length > 1) {
      return orParts.any((part) => _evalBooleanExpression(part, context));
    }

    // Handle AND
    final andParts = _splitByOperator(expression, ' and ');
    if (andParts.length > 1) {
      return andParts.every((part) => _evalBooleanExpression(part, context));
    }

    // Handle comparisons
    for (final op in ['>=', '<=', '==', '!=', '>', '<']) {
      final index = expression.indexOf(op);
      if (index != -1) {
        final left = expression.substring(0, index).trim();
        final right = expression.substring(index + op.length).trim();
        return _evaluateComparison(left, right, op, context);
      }
    }

    // Direct value check
    final value = _resolveExpression(expression, context);
    return _isTruthy(value);
  }

  // ADD THIS MISSING METHOD
  bool _evaluateComparison(
    String leftExpr,
    String rightExpr,
    String operator,
    RuleContext context,
  ) {
    final left = _resolveExpression(leftExpr, context);
    final right = _resolveExpression(rightExpr, context);

    return _compareValues(left, right, operator);
  }

  // ---------------------------------------------------------------------------
  // Improved Predicate Evaluation
  // ---------------------------------------------------------------------------

  bool _evalPredicateOnFact(String predicate, Fact fact) {
    predicate = predicate.trim();
    if (predicate.isEmpty) return false;

    // Handle parentheses
    if (_isParenthesized(predicate)) {
      final inner = predicate.substring(1, predicate.length - 1).trim();
      return _evalPredicateOnFact(inner, fact);
    }

    // Handle NOT operator
    if (predicate.startsWith('not ')) {
      return !_evalPredicateOnFact(predicate.substring(4).trim(), fact);
    }

    // Handle OR
    final orParts = _splitByOperator(predicate, ' or ');
    if (orParts.length > 1) {
      return orParts.any((part) => _evalPredicateOnFact(part, fact));
    }

    // Handle AND
    final andParts = _splitByOperator(predicate, ' and ');
    if (andParts.length > 1) {
      return andParts.every((part) => _evalPredicateOnFact(part, fact));
    }

    // Handle comparisons - FIXED VERSION
    for (final op in ['>=', '<=', '==', '!=', '>', '<']) {
      final index = predicate.indexOf(op);
      if (index != -1) {
        final left = predicate.substring(0, index).trim();
        final right = predicate.substring(index + op.length).trim();
        return _evaluateFactComparison(left, right, op, fact);
      }
    }

    // Direct field check
    final value = _getFactFieldValue(predicate, fact);
    return _isTruthy(value);
  }

  bool _evaluateFactComparison(
    String left,
    String right,
    String operator,
    Fact fact,
  ) {
    final leftValue = _getFactFieldValue(left, fact);
    final rightValue = _parseComparisonValue(right);

    // Debug output
    print('  Comparison: $leftValue $operator $rightValue');

    return _compareValues(leftValue, rightValue, operator);
  }

  dynamic _parseComparisonValue(String value) {
    value = value.trim();

    // Handle boolean literals
    if (value == 'true') return true;
    if (value == 'false') return false;

    // Handle numeric literals
    final numVal = double.tryParse(value);
    if (numVal != null) {
      return numVal == numVal.toInt() ? numVal.toInt() : numVal;
    }

    // Handle quoted strings
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      return value.substring(1, value.length - 1);
    }

    // Return as string
    return value;
  }

  bool _compareValues(dynamic left, dynamic right, String operator) {
    // Handle null cases
    if (left == null || right == null) {
      switch (operator) {
        case '==':
          return left == right;
        case '!=':
          return left != right;
        default:
          return false;
      }
    }

    // Handle boolean comparisons
    if (left is bool && right is bool) {
      switch (operator) {
        case '==':
          return left == right;
        case '!=':
          return left != right;
        default:
          return false;
      }
    }

    // Handle numeric comparisons
    final leftNum = _toNumber(left);
    final rightNum = _toNumber(right);
    if (leftNum != null && rightNum != null) {
      switch (operator) {
        case '==':
          return leftNum == rightNum;
        case '!=':
          return leftNum != rightNum;
        case '>':
          return leftNum > rightNum;
        case '<':
          return leftNum < rightNum;
        case '>=':
          return leftNum >= rightNum;
        case '<=':
          return leftNum <= rightNum;
      }
    }

    // Handle string comparisons
    final leftStr = left.toString();
    final rightStr = right.toString();
    switch (operator) {
      case '==':
        return leftStr == rightStr;
      case '!=':
        return leftStr != rightStr;
      case '>':
        return leftStr.compareTo(rightStr) > 0;
      case '<':
        return leftStr.compareTo(rightStr) < 0;
      case '>=':
        return leftStr.compareTo(rightStr) >= 0;
      case '<=':
        return leftStr.compareTo(rightStr) <= 0;
    }

    return false;
  }

  double? _toNumber(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is bool) return value ? 1.0 : 0.0;
    return null;
  }

  // ---------------------------------------------------------------------------
  // Expression Resolution
  // ---------------------------------------------------------------------------

  dynamic _resolveExpression(String expression, RuleContext context) {
    expression = expression.trim();

    // String literals
    if ((expression.startsWith('"') && expression.endsWith('"')) ||
        (expression.startsWith("'") && expression.endsWith("'"))) {
      return expression.substring(1, expression.length - 1);
    }

    // Numeric literals
    if (double.tryParse(expression) != null) {
      final numVal = double.parse(expression);
      return numVal == numVal.toInt() ? numVal.toInt() : numVal;
    }

    // Boolean literals
    if (expression == 'true') return true;
    if (expression == 'false') return false;

    // Global variables
    if (expression.startsWith('global.')) {
      final key = expression.substring(7);
      return context.getGlobal(key);
    }

    // Fact queries
    if (expression.startsWith('facts.')) {
      return _resolveFactQuery(expression.substring(6), context);
    }

    return expression;
  }

  dynamic _resolveFactQuery(String query, RuleContext context) {
    final dotIndex = query.indexOf('.');
    if (dotIndex == -1) {
      return context.facts.where((f) => f.type == query).toList();
    }

    final typeName = query.substring(0, dotIndex);
    final tail = query.substring(dotIndex + 1);
    final factsOfType = context.facts.where((f) => f.type == typeName).toList();

    if (tail == 'count') {
      return factsOfType.length;
    }

    if (tail.startsWith('where(')) {
      final endIndex = tail.indexOf(')', 6);
      if (endIndex != -1) {
        final predicate = tail.substring(6, endIndex);
        final remaining = tail.substring(endIndex + 1);

        final filtered =
            factsOfType.where((f) => matches(f, predicate)).toList();

        if (remaining == '.count') {
          return filtered.length;
        }
        return filtered;
      }
    }

    return factsOfType;
  }

  dynamic _getFactFieldValue(String fieldPath, Fact fact) {
    final parts = fieldPath.split('.');
    dynamic current = fact.data;

    for (final part in parts) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }

  bool _isParenthesized(String s) {
    if (!s.startsWith('(') || !s.endsWith(')')) return false;
    int depth = 0;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '(') depth++;
      if (s[i] == ')') depth--;
      if (depth == 0 && i != s.length - 1) return false;
    }
    return depth == 0;
  }

  List<String> _splitByOperator(String s, String delim) {
    final parts = <String>[];
    int depth = 0;
    int last = 0;
    for (int i = 0; i <= s.length - delim.length; i++) {
      if (s[i] == '(') depth++;
      if (s[i] == ')') depth--;
      if (depth == 0 && s.startsWith(delim, i)) {
        parts.add(s.substring(last, i).trim());
        last = i + delim.length;
        i = last - 1;
      }
    }
    parts.add(s.substring(last).trim());
    return parts;
  }

  bool _isTruthy(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.isNotEmpty;
    if (value is Iterable) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return value != null;
  }
}
