// AST node definitions for the expression engine.
// These nodes are evaluator-agnostic; the evaluator supplies an EvalEnv
// with a resolver to translate identifiers/paths into concrete values.

import 'core.dart';

/// Evaluation environment used by AST nodes.
class EvalEnv {
  /// The rule engine's contextual runtime (facts, globals, hooks, log).
  final RuleContext context;

  /// Resolver function. Given an identifier/path string, returns the resolved value.
  /// Example identifiers: "global.remainingShare", "facts.FamilyMember.count",
  /// "person.age", "facts.Member.where(...)" (the resolver decides supported syntax).
  final dynamic Function(String identifier) resolve;

  EvalEnv({required this.context, required this.resolve});
}

/// Base expression node.
abstract class ExprNode {
  const ExprNode();

  /// Evaluate the node under given EvalEnv.
  /// Can return bool, num, String, List, Map, or null depending on expression.
  dynamic evaluate(EvalEnv env);
}

/// Literal values

class NullLiteral extends ExprNode {
  const NullLiteral();
  @override
  dynamic evaluate(EvalEnv env) => null;
}

class NumberLiteral extends ExprNode {
  final num value;
  const NumberLiteral(this.value);
  @override
  dynamic evaluate(EvalEnv env) => value;
}

class StringLiteral extends ExprNode {
  final String value;
  const StringLiteral(this.value);
  @override
  dynamic evaluate(EvalEnv env) => value;
}

class BoolLiteral extends ExprNode {
  final bool value;
  const BoolLiteral(this.value);
  @override
  dynamic evaluate(EvalEnv env) => value;
}

/// Identifier (field path) — resolved via EvalEnv.resolve
class Identifier extends ExprNode {
  final String
  name; // e.g. 'global.remainingShare' or 'facts.FamilyMember.count'
  const Identifier(this.name);

  @override
  dynamic evaluate(EvalEnv env) {
    try {
      return env.resolve(name);
    } catch (e) {
      // Resolver errors should not crash the evaluator — return null and let
      // higher level decide how to handle missing fields.
      return null;
    }
  }
}

/// Unary operator node (like !, -)
class UnaryOp extends ExprNode {
  final String operator; // '!' or '-'
  final ExprNode operand;

  const UnaryOp(this.operator, this.operand);

  @override
  dynamic evaluate(EvalEnv env) {
    final val = operand.evaluate(env);

    switch (operator) {
      case '!':
        return !_isTruthy(val);
      case '-':
        if (val is num) return -val;
        final n = _tryParseNum(val);
        return n != null ? -n : null;
      default:
        throw UnsupportedError('Unsupported unary operator: $operator');
    }
  }
}

/// Binary operator node
class BinaryOp extends ExprNode {
  final String operator;
  final ExprNode left;
  final ExprNode right;

  const BinaryOp(this.operator, this.left, this.right);

  @override
  dynamic evaluate(EvalEnv env) {
    final l = left.evaluate(env);
    final r = right.evaluate(env);

    switch (operator) {
      // Logical
      case '||':
      case 'or':
        return _isTruthy(l) ? l : r; // short-circuit style (truthy value)
      case '&&':
      case 'and':
        return _isTruthy(l) ? r : l;

      // Comparisons
      case '==':
        return _equals(l, r);
      case '!=':
        return !_equals(l, r);
      case '>':
        return _compare(l, r) > 0;
      case '<':
        return _compare(l, r) < 0;
      case '>=':
        return _compare(l, r) >= 0;
      case '<=':
        return _compare(l, r) <= 0;

      // Arithmetic
      case '+':
        return _add(l, r);
      case '-':
        return _arithmeticOp((a, b) => a - b, l, r);
      case '*':
        return _arithmeticOp((a, b) => a * b, l, r);
      case '/':
        return _arithmeticOp((a, b) => b == 0 ? null : a / b, l, r);
      case '%':
        return _arithmeticOp((a, b) => a % b, l, r);

      default:
        throw UnsupportedError('Unsupported binary operator: $operator');
    }
  }
}

/// Helper / utility functions used by AST nodes

bool _isTruthy(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value.isNotEmpty;
  if (value is Iterable || value is Map) return (value as dynamic).isNotEmpty;
  return true;
}

num? _tryParseNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  if (v is String) {
    final parsed = num.tryParse(v);
    return parsed;
  }
  return null;
}

bool _equals(dynamic a, dynamic b) {
  // Nulls equal only to null
  if (a == null || b == null) return a == b;

  // numeric equality if both numeric (or both parseable to numbers)
  final aNum = _tryParseNum(a);
  final bNum = _tryParseNum(b);
  if (aNum != null && bNum != null) {
    return aNum == bNum;
  }

  // Default equality
  return a == b;
}

int _compare(dynamic a, dynamic b) {
  // Null handling: treat null as less than any non-null
  if (a == null && b == null) return 0;
  if (a == null) return -1;
  if (b == null) return 1;

  final aNum = _tryParseNum(a);
  final bNum = _tryParseNum(b);
  if (aNum != null && bNum != null) {
    return aNum.compareTo(bNum);
  }

  final aStr = a.toString();
  final bStr = b.toString();
  return aStr.compareTo(bStr);
}

dynamic _arithmeticOp(num? Function(num, num) op, dynamic a, dynamic b) {
  final aNum = _tryParseNum(a);
  final bNum = _tryParseNum(b);
  if (aNum == null || bNum == null) return null;
  return op(aNum, bNum);
}

dynamic _add(dynamic a, dynamic b) {
  // If both numeric -> numeric add
  final aNum = _tryParseNum(a);
  final bNum = _tryParseNum(b);
  if (aNum != null && bNum != null) return aNum + bNum;

  // If either is a string -> concatenate
  if (a is String || b is String) return '${a ?? ''}${b ?? ''}';

  // As fallback, attempt numeric add
  if (aNum != null && bNum != null) return aNum + bNum;

  return null;
}
