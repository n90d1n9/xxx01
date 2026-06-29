// Simple Fact model used by the rule engine.

class Fact {
  final String type;
  final Map<String, dynamic> data;

  Fact(this.type, [Map<String, dynamic>? initialData])
    : data = Map<String, dynamic>.from(initialData ?? {});

  dynamic operator [](String key) => data[key];
  void operator []=(String key, dynamic value) => data[key] = value;

  @override
  String toString() => 'Fact<$type>${data.toString()}';
}

// Rule model used by the loader & engine.
// The `when` field is typed as List<dynamic> for compatibility:
// - it may contain parsed ExprNode objects (from parser/ast_nodes.dart)
// - or legacy string conditions
//
// `then` is List<dynamic> of action maps or strings.
class Rule {
  final String name;
  final String group;
  final int salience;
  final bool noLoop;
  final List<dynamic> when;
  final List<dynamic> then;
  final String? description;

  bool hasFired = false;

  Rule({
    required this.name,
    this.group = 'default',
    this.salience = 0,
    this.noLoop = false,
    List<dynamic>? when,
    List<dynamic>? then,
    this.description,
  }) : when = List<dynamic>.from(when ?? []),
       then = List<dynamic>.from(then ?? []);

  @override
  String toString() =>
      'Rule(name: $name, group: $group, salience: $salience, noLoop: $noLoop, when: ${when.length} conds, then: ${then.length} actions)';
}

// RuleContext (execution context) for the rule engine.
// Holds facts, globals, hooks and execution log.

class RuleContext {
  final Map<String, dynamic> globals;
  final List<Fact> facts;
  final Map<String, Function> hooks;
  final List<String> executionLog;

  RuleContext({
    Map<String, dynamic>? initialGlobals,
    List<Fact>? initialFacts,
    Map<String, Function>? initialHooks,
    List<String>? initialLog,
  }) : globals = Map<String, dynamic>.from(initialGlobals ?? {}),
       facts = List<Fact>.from(initialFacts ?? []),
       hooks = Map<String, Function>.from(initialHooks ?? {}),
       executionLog = List<String>.from(initialLog ?? []);

  void log(String message) {
    final ts = DateTime.now().toIso8601String();
    executionLog.add('[$ts] $message');
  }

  dynamic getGlobal(String key) => globals[key];

  void setGlobal(String key, dynamic value) => globals[key] = value;

  /// Find facts by type name
  List<Fact> factsOfType(String type) =>
      facts.where((f) => f.type == type).toList();

  /// Convenience: clear logs
  void clearLog() => executionLog.clear();

  @override
  String toString() =>
      'RuleContext(globals: ${globals.keys.toList()}, facts: ${facts.length}, hooks: ${hooks.keys.toList()})';
}
