// Simple registry to register and execute actions by name.
// Action handlers receive (Map<String,dynamic> args, RuleContext ctx, EvalEnv env)

import 'ast_nodes.dart';
import 'core.dart';

typedef ActionHandler =
    Future<void> Function(
      Map<String, dynamic> args,
      RuleContext ctx,
      EvalEnv env,
    );

class ActionRegistry {
  final Map<String, ActionHandler> _handlers = {};

  void register(String name, ActionHandler handler) {
    _handlers[name] = handler;
  }

  bool has(String name) => _handlers.containsKey(name);

  Future<void> execute(
    String name,
    Map<String, dynamic> args,
    RuleContext ctx,
    EvalEnv env,
  ) async {
    final handler = _handlers[name];
    if (handler == null) {
      throw StateError('No action registered for "$name"');
    }
    await handler(args, ctx, env);
  }

  List<String> registeredActions() => List.unmodifiable(_handlers.keys);
}
