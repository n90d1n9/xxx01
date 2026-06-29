import 'dart:convert';
import 'dart:math';

import 'fact.dart';
import 'constraint.dart';

class Pattern {
  final String alias;
  final String type;
  final List<Constraint> constraints;
  final bool Function(Fact, Map<String, Fact>)? customPredicate;
  Pattern(
    this.alias,
    this.type, {
    this.constraints = const [],
    this.customPredicate,
  });
  bool matches(Fact fact, Map<String, Fact> bindings) {
    if (fact.type != type) return false;
    for (final constraint in constraints) {
      if (!constraint.evaluate(fact)) return false;
    }
    if (customPredicate != null) {
      bindings[alias] = fact;
      return customPredicate!(fact, bindings);
    }
    return true;
  }
}
