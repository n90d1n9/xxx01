import 'dart:convert';
import 'dart:math';

import 'fact.dart';
import 'constraint.dart';
import 'pattern.dart';
import 'rule.dart';
import 'rule_engine.dart';

/// Action function type
typedef ActionFunction =
    void Function(Map<String, Fact> bindings, RuleEngine engine);

class RuleBuilder {
  String? _name;
  String? _description;
  int _salience = 0;
  String? _agendaGroup;
  String? _activationGroup;
  bool _noLoop = false;
  bool _lockOnActive = false;
  final List<Pattern> _patterns = [];
  ActionFunction? _action;
  RuleBuilder name(String name) {
    _name = name;
    return this;
  }

  RuleBuilder description(String description) {
    _description = description;
    return this;
  }

  RuleBuilder salience(int salience) {
    _salience = salience;
    return this;
  }

  RuleBuilder agendaGroup(String group) {
    _agendaGroup = group;
    return this;
  }

  RuleBuilder activationGroup(String group) {
    _activationGroup = group;
    return this;
  }

  RuleBuilder noLoop(bool value) {
    _noLoop = value;
    return this;
  }

  RuleBuilder lockOnActive(bool value) {
    _lockOnActive = value;
    return this;
  }

  RuleBuilder when(
    String alias,
    String type, {
    List<Constraint>? constraints,
    bool Function(Fact, Map<String, Fact>)? predicate,
  }) {
    _patterns.add(
      Pattern(
        alias,
        type,
        constraints: constraints ?? [],
        customPredicate: predicate,
      ),
    );
    return this;
  }

  RuleBuilder then(ActionFunction action) {
    _action = action;
    return this;
  }

  Rule build() {
    if (_name == null) throw StateError('Rule name is required');
    if (_action == null) throw StateError('Rule action is required');
    return Rule(
      name: _name!,
      description: _description,
      salience: _salience,
      agendaGroup: _agendaGroup,
      activationGroup: _activationGroup,
      noLoop: _noLoop,
      lockOnActive: _lockOnActive,
      when: _patterns,
      then: _action!,
    );
  }
}
