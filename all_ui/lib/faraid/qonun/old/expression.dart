import 'dart:core';

import 'fact.dart';
import 'rule_engine.dart';

class Expression {
  /// Evaluate a boolean expression (can be bool, number, or string expression)
  static bool eval(dynamic expr, RuleEngine engine) {
    if (expr is bool) return expr;
    if (expr is num) return expr != 0;
    if (expr is String) {
      return _evalString(expr.trim(), engine);
    }
    return false;
  }

  /// Evaluate a value expression (numbers, strings, lists, global refs, facts, etc.)
  static dynamic evalValue(dynamic expr, RuleEngine engine) {
    if (expr == null) return null;
    if (expr is num || expr is bool) return expr;
    if (expr is Map || expr is List) return expr;
    if (expr is String) return _resolve(expr.trim(), engine);
    return expr;
  }

  // --------------------------------------------------------------------------
  // Boolean expression handler: supports parentheses, and/or/not and comparisons
  static bool _evalString(String s, RuleEngine engine) {
    s = s.trim();
    if (s.isEmpty) return false;

    // Handle parentheses recursively
    if (_isParenthesizedExpression(s)) {
      final inner = s.substring(1, s.length - 1).trim();
      return _evalString(inner, engine);
    }

    // Handle NOT operator at start
    if (s.startsWith('not ')) {
      return !_evalString(s.substring(4).trim(), engine);
    }

    // Handle OR (lowest precedence)
    final orParts = _splitTopLevel(s, ' or ');
    if (orParts.length > 1) {
      for (var p in orParts) {
        if (_evalString(p, engine)) return true;
      }
      return false;
    }

    // Handle AND
    final andParts = _splitTopLevel(s, ' and ');
    if (andParts.length > 1) {
      for (var p in andParts) {
        if (!_evalString(p, engine)) return false;
      }
      return true;
    }

    // Comparisons
    // Order matters: >=, <=, ==, !=, >, <
    if (s.contains('>=')) {
      final parts = s.split('>=');
      final l = _resolve(parts[0], engine);
      final r = _resolve(parts.sublist(1).join('>='), engine);
      return _compareNumericOrString(l, r) >= 0;
    }
    if (s.contains('<=')) {
      final parts = s.split('<=');
      final l = _resolve(parts[0], engine);
      final r = _resolve(parts.sublist(1).join('<='), engine);
      return _compareNumericOrString(l, r) <= 0;
    }
    if (s.contains('==')) {
      final parts = s.split('==');
      final l = _resolve(parts[0], engine);
      final r = _resolve(parts.sublist(1).join('=='), engine);
      return l == r;
    }
    if (s.contains('!=')) {
      final parts = s.split('!=');
      final l = _resolve(parts[0], engine);
      final r = _resolve(parts.sublist(1).join('!='), engine);
      return l != r;
    }
    if (s.contains('>')) {
      final parts = s.split('>');
      final l = _resolve(parts[0], engine);
      final r = _resolve(parts.sublist(1).join('>'), engine);
      return _compareNumericOrString(l, r) > 0;
    }
    if (s.contains('<')) {
      final parts = s.split('<');
      final l = _resolve(parts[0], engine);
      final r = _resolve(parts.sublist(1).join('<'), engine);
      return _compareNumericOrString(l, r) < 0;
    }

    // Direct boolean/global check: e.g., global.someFlag or facts.Type.where(...).count
    final v = _resolve(s, engine);
    if (v is bool) return v;
    if (v is num) return v != 0;
    return v != null;
  }

  static dynamic _resolve(String expr, RuleEngine engine) {
    expr = expr.trim();

    // quoted string literal
    if ((expr.startsWith('"') && expr.endsWith('"')) ||
        (expr.startsWith("'") && expr.endsWith("'"))) {
      return expr.substring(1, expr.length - 1);
    }

    // numeric
    if (double.tryParse(expr) != null) {
      final numVal = double.parse(expr);
      if (numVal == numVal.toInt()) return numVal.toInt();
      return numVal;
    }

    // global.*
    if (expr.startsWith('global.')) {
      final key = expr.substring(7);
      return engine.getGlobal(key);
    }

    // facts.Type.where(predicate).count or facts.Type.count or facts.Type
    if (expr.startsWith('facts.')) {
      // possible forms:
      // facts.Type.where(predicate).count
      // facts.Type.where(predicate)
      // facts.Type.count
      // facts.Type
      final rest = expr.substring(6); // after 'facts.'
      // extract type name (until first '.' or end)
      final dotIndex = rest.indexOf('.');
      String typeName;
      String tail = '';
      if (dotIndex == -1) {
        typeName = rest;
      } else {
        typeName = rest.substring(0, dotIndex);
        tail = rest.substring(dotIndex + 1); // e.g., where(...).count or count
      }

      if (tail.startsWith('where(')) {
        // find matching parentheses
        final start = tail.indexOf('where(') + 6;
        int depth = 1;
        int i = start;
        for (; i < tail.length; i++) {
          if (tail[i] == '(') depth++;
          if (tail[i] == ')') {
            depth--;
            if (depth == 0) break;
          }
        }
        final predicate = tail.substring(start, i);
        final remaining = (i + 1 < tail.length) ? tail.substring(i + 1) : '';

        final list = engine.getFactsByType(typeName, predicate: predicate);
        if (remaining.trim().startsWith('.count')) return list.length;
        return list;
      } else if (tail.startsWith('count')) {
        final list = engine.getFactsByType(typeName);
        return list.length;
      } else if (tail.isEmpty) {
        return engine.getFactsByType(typeName);
      } else if (tail.startsWith('.')) {
        // possibly '.count' or other
        final prop = tail.substring(1);
        if (prop == 'count') {
          final list = engine.getFactsByType(typeName);
          return list.length;
        }
        // fallback: return list
        return engine.getFactsByType(typeName);
      }
    }

    // fallback: maybe a bare identifier (e.g., true/false)
    if (expr == 'true') return true;
    if (expr == 'false') return false;
    return expr;
  }

  // --------------------------------------------------------------------------
  static bool _isParenthesizedExpression(String s) {
    if (!s.startsWith('(') || !s.endsWith(')')) return false;
    int depth = 0;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '(') depth++;
      if (s[i] == ')') {
        depth--;
        if (depth == 0 && i != s.length - 1) return false;
      }
    }
    return depth == 0;
  }

  // Split only at top-level (not inside parentheses)
  static List<String> _splitTopLevel(String s, String delim) {
    final parts = <String>[];
    int depth = 0;
    int last = 0;
    for (int i = 0; i <= s.length - delim.length; i++) {
      final sub = s.substring(i, i + delim.length);
      if (s[i] == '(') depth++;
      if (s[i] == ')') depth--;
      if (depth == 0 && sub == delim) {
        parts.add(s.substring(last, i).trim());
        last = i + delim.length;
        i = last - 1;
      }
    }
    parts.add(s.substring(last).trim());
    return parts;
  }

  static int _compareNumericOrString(dynamic a, dynamic b) {
    // try numeric compare first
    if (a is num && b is num) {
      if (a < b) return -1;
      if (a > b) return 1;
      return 0;
    }
    // try numeric parse if string
    if (a is String && double.tryParse(a) != null && b is num) {
      final av = double.parse(a);
      if (av < b) return -1;
      if (av > b) return 1;
      return 0;
    }
    if (b is String && double.tryParse(b) != null && a is num) {
      final bv = double.parse(b);
      if (a < bv) return -1;
      if (a > bv) return 1;
      return 0;
    }
    // fallback string compare
    final as = a?.toString() ?? '';
    final bs = b?.toString() ?? '';
    return as.compareTo(bs);
  }

  // --------------------------------------------------------------------------
  // Predicate evaluation against a single fact (very important for where(...))
  // Supports forms like:
  //   relationName=="son" and isDeceased==false
  //   relationName=="spouse" and genderName=="female" and isDeceased==false
  //   relationName=="son" or relationName=="daughter"
  static bool evalPredicateOnFact(String predicate, Fact fact) {
    // This method is forwarded to the top-level static to allow usage from RuleEngine.
    return _evalPredicateOnFactInternal(predicate, fact);
  }

  static bool _evalPredicateOnFactInternal(String predicate, Fact fact) {
    final s = predicate.trim();

    // handle parentheses/simple not
    if (s.isEmpty) return false;
    if (s.startsWith('not ')) {
      return !_evalPredicateOnFactInternal(s.substring(4).trim(), fact);
    }

    // OR split top-level
    final orParts = _splitTopLevel(s, ' or ');
    if (orParts.length > 1) {
      for (var p in orParts) {
        if (_evalPredicateOnFactInternal(p, fact)) return true;
      }
      return false;
    }

    // AND split top-level
    final andParts = _splitTopLevel(s, ' and ');
    if (andParts.length > 1) {
      for (var p in andParts) {
        if (!_evalPredicateOnFactInternal(p, fact)) return false;
      }
      return true;
    }

    // Comparison inside predicate: supports ==, !=, >=, <=, >, <
    final operators = ['>=', '<=', '==', '!=', '>', '<'];
    for (var op in operators) {
      final idx = s.indexOf(op);
      if (idx != -1) {
        final left = s.substring(0, idx).trim();
        final right = s.substring(idx + op.length).trim();
        final leftVal = _getFactFieldValue(left, fact);
        final rightVal = _stripQuotes(right);
        // try parse rightVal to bool/num if possible
        dynamic rv = _asTyped(rightVal);
        dynamic lv = leftVal;
        // compare
        switch (op) {
          case '==':
            return lv == rv;
          case '!=':
            return lv != rv;
          case '>=':
            return _compareNumericOrString(lv, rv) >= 0;
          case '<=':
            return _compareNumericOrString(lv, rv) <= 0;
          case '>':
            return _compareNumericOrString(lv, rv) > 0;
          case '<':
            return _compareNumericOrString(lv, rv) < 0;
        }
      }
    }

    // If no operator, check truthiness of field (e.g., isDeceased)
    final val = _getFactFieldValue(s, fact);
    if (val is bool) return val;
    if (val is num) return val != 0;
    return val != null;
  }

  static dynamic _getFactFieldValue(String fieldExpr, Fact fact) {
    final f = fieldExpr.trim();
    // support dotted navigation if necessary (not deeply nested here)
    if (f.contains('.')) {
      final parts = f.split('.');
      var current = fact.data;
      for (var p in parts) {
        if (current is Map && current.containsKey(p))
          current = current[p];
        else
          return null;
      }
      return current;
    }
    return fact.data[f];
  }

  static String _stripQuotes(String s) {
    if (s.startsWith('"') && s.endsWith('"')) {
      return s.substring(1, s.length - 1);
    }
    return s; // default
  }

  static dynamic _asTyped(String s) {
    final trimmed = s.trim();
    if (trimmed == 'true') return true;
    if (trimmed == 'false') return false;
    if (double.tryParse(trimmed) != null) {
      final d = double.parse(trimmed);
      if (d == d.toInt()) return d.toInt();
      return d;
    }
    // string literal maybe quoted or not
    return _stripQuotes(trimmed);
  }
}
