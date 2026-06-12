import 'pattern.dart';
import 'rule_builder.dart';

class Rule {
  final String name;
  final String? description;
  final int salience;
  final String? agendaGroup;
  final String? activationGroup;
  final bool noLoop;
  final bool lockOnActive;
  final List<Pattern> when;
  final ActionFunction then;
  bool enabled;
  int executionCount = 0;
  DateTime? lastFired;
  Rule({
    required this.name,
    this.description,
    this.salience = 0,
    this.agendaGroup,
    this.activationGroup,
    this.noLoop = false,
    this.lockOnActive = false,
    required this.when,
    required this.then,
    this.enabled = true,
  });
  @override
  String toString() => 'Rule($name, salience: $salience, enabled: $enabled)';
}
