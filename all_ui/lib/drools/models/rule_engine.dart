import 'dart:convert';
import 'dart:math';

import 'fact.dart';
import 'pattern.dart';
import 'rule.dart';

class RuleEngine {
  final List<Rule> _rules = [];
  final List<Fact> _workingMemory = [];
  final Set<Fact> _factsToRetract = {};
  final List<String> _executionLog = [];
  final Map<String, dynamic> _globals = {};
  final Set<String> _firedActivationGroups = {};
  String? _currentAgendaGroup;
  int maxExecutions = 1000;
  bool logExecution = true;
  bool enableTruthMaintenance = false;
  void addRule(Rule rule) {
    _rules.add(rule);
    _sortRules();
  }

  void addRules(List<Rule> rules) {
    _rules.addAll(rules);
    _sortRules();
  }

  bool removeRule(String name) {
    final initialCount = _rules.length;
    _rules.removeWhere((r) => r.name == name);
    final finalCount = _rules.length;
    return finalCount < initialCount;
  }

  void setRuleEnabled(String name, bool enabled) {
    final rule = _rules.firstWhere((r) => r.name == name);
    rule.enabled = enabled;
  }

  void setGlobal(String name, dynamic value) {
    _globals[name] = value;
    _log('Set global: $name = $value');
  }

  dynamic getGlobal(String name) => _globals[name];
  Fact insert(Fact fact) {
    _workingMemory.add(fact);
    _log('Inserted fact: ${fact.type} ${fact.attributes}');
    return fact;
  }

  void update(Fact fact) {
    _log('Updated fact: ${fact.type} ${fact.attributes}');
  }

  void retract(Fact fact) {
    _factsToRetract.add(fact);
    _log('Marked for retraction: ${fact.type}');
  }

  List<Fact> getFactsByType(String type) {
    return _workingMemory.where((f) => f.type == type).toList();
  }

  List<Fact> getAllFacts() => List.unmodifiable(_workingMemory);
  void clearFacts() {
    _workingMemory.clear();
    _factsToRetract.clear();
  }

  void clearRules() {
    _rules.clear();
  }

  List<String> getExecutionLog() => List.unmodifiable(_executionLog);
  void clearLog() {
    _executionLog.clear();
  }

  void setFocus(String? agendaGroup) {
    _currentAgendaGroup = agendaGroup;
  }

  void fireAllRules() {
    _executionLog.clear();
    _firedActivationGroups.clear();
    var iterations = 0;
    var totalFired = 0;
    while (iterations < maxExecutions) {
      final fired = _fireOnce();
      totalFired += fired;
      if (fired == 0) break;
      iterations++;
    }
    _performRetractions();
    _log('Total rules fired: $totalFired in $iterations iterations');
  }

  void fireUntilHalt(bool Function() haltCondition) {
    var iterations = 0;
    while (iterations < maxExecutions && !haltCondition()) {
      final fired = _fireOnce();
      if (fired == 0) break;
      iterations++;
    }
    _performRetractions();
  }

  int _fireOnce() {
    var firedCount = 0;
    final eligibleRules = _getEligibleRules();
    for (final rule in eligibleRules) {
      if (!rule.enabled) continue;
      if (rule.activationGroup != null) {
        if (_firedActivationGroups.contains(rule.activationGroup)) continue;
      }
      final matches = _findMatches(rule);
      for (final bindings in matches) {
        _log('Firing rule: ${rule.name}');
        rule.executionCount++;
        rule.lastFired = DateTime.now();
        rule.then(bindings, this);
        firedCount++;
        if (rule.activationGroup != null) {
          _firedActivationGroups.add(rule.activationGroup!);
        }
        if (rule.noLoop) break;
      }
    }
    return firedCount;
  }

  List<Rule> _getEligibleRules() {
    if (_currentAgendaGroup == null) {
      return _rules.where((r) => r.agendaGroup == null).toList();
    }
    return _rules.where((r) => r.agendaGroup == _currentAgendaGroup).toList();
  }

  List<Map<String, Fact>> _findMatches(Rule rule) {
    if (rule.when.isEmpty) return [];
    final matches = <Map<String, Fact>>[];
    _findMatchesRecursive(rule.when, 0, {}, matches);
    return matches;
  }

  void _findMatchesRecursive(
    List<Pattern> patterns,
    int patternIndex,
    Map<String, Fact> currentBindings,
    List<Map<String, Fact>> matches,
  ) {
    if (patternIndex >= patterns.length) {
      matches.add(Map.from(currentBindings));
      return;
    }
    final pattern = patterns[patternIndex];
    final factsOfType =
        _workingMemory
            .where((fact) => fact.type == pattern.type)
            .where((fact) => !_factsToRetract.contains(fact))
            .toList();
    for (final fact in factsOfType) {
      final newBindings = Map<String, Fact>.from(currentBindings);
      if (pattern.matches(fact, newBindings)) {
        newBindings[pattern.alias] = fact;
        _findMatchesRecursive(patterns, patternIndex + 1, newBindings, matches);
      }
    }
  }

  void _performRetractions() {
    if (_factsToRetract.isNotEmpty) {
      _workingMemory.removeWhere((f) => _factsToRetract.contains(f));
      _log('Retracted ${_factsToRetract.length} facts');
      _factsToRetract.clear();
    }
  }

  void _sortRules() {
    _rules.sort((a, b) => b.salience.compareTo(a.salience));
  }

  void _log(String message) {
    if (logExecution) {
      _executionLog.add(message);
      print(message);
    }
  }

  Map<String, dynamic> getStatistics() {
    return {
      'totalRules': _rules.length,
      'enabledRules': _rules.where((r) => r.enabled).length,
      'totalFacts': _workingMemory.length,
      'globals': _globals.keys.toList(),
      'ruleExecutions':
          _rules
              .map(
                (r) => {
                  'name': r.name,
                  'executions': r.executionCount,
                  'lastFired': r.lastFired?.toIso8601String(),
                },
              )
              .toList(),
    };
  }

  @override
  String toString() {
    return 'RuleEngine(rules: ${_rules.length}, facts: ${_workingMemory.length})';
  }
}
