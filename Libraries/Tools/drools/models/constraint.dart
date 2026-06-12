import 'dart:convert';
import 'dart:math';

import 'fact.dart';
import 'operator.dart';

class Constraint {
  final String field;
  final Operator operator;
  final dynamic value;
  Constraint(this.field, this.operator, [this.value]);
  bool evaluate(Fact fact) {
    final fieldValue = fact.get(field);
    switch (operator) {
      case Operator.equals:
        return fieldValue == value;
      case Operator.notEquals:
        return fieldValue != value;
      case Operator.greaterThan:
        return _compareNumeric(fieldValue, value, (a, b) => a > b);
      case Operator.lessThan:
        return _compareNumeric(fieldValue, value, (a, b) => a < b);
      case Operator.greaterThanOrEqual:
        return _compareNumeric(fieldValue, value, (a, b) => a >= b);
      case Operator.lessThanOrEqual:
        return _compareNumeric(fieldValue, value, (a, b) => a <= b);
      case Operator.contains:
        if (fieldValue is List) return fieldValue.contains(value);
        return fieldValue.toString().contains(value.toString());
      case Operator.notContains:
        if (fieldValue is List) return !fieldValue.contains(value);
        return !fieldValue.toString().contains(value.toString());
      case Operator.matches:
        return RegExp(value.toString()).hasMatch(fieldValue.toString());
      case Operator.isNull:
        return fieldValue == null;
      case Operator.isNotNull:
        return fieldValue != null;
      case Operator.inList:
        return (value as List).contains(fieldValue);
      case Operator.notInList:
        return !(value as List).contains(fieldValue);
      case Operator.memberOf:
        return (fieldValue is List) && (fieldValue as List).contains(value);
      case Operator.startsWith:
        return fieldValue.toString().startsWith(value.toString());
      case Operator.endsWith:
        return fieldValue.toString().endsWith(value.toString());
    }
  }

  bool _compareNumeric(dynamic a, dynamic b, bool Function(num, num) compare) {
    if (a is num && b is num) return compare(a, b);
    if (a is String && b is num) {
      final numA = num.tryParse(a);
      if (numA != null) return compare(numA, b);
    }
    return false;
  }
}
