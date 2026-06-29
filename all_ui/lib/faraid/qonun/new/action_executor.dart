import 'ast_nodes.dart';
import 'core.dart';

abstract class ActionExecutor {
  final RuleContext context;

  ActionExecutor(this.context);

  Future<void> execute(dynamic action);

  // Helper methods
  dynamic evaluate(dynamic value, EvalEnv env);
  Map<String, dynamic> normalizeArgs(dynamic raw);
  EvalEnv buildEnv();
}

abstract class ActionExecutorDecorator extends ActionExecutor {
  final ActionExecutor parent;

  ActionExecutorDecorator(this.parent) : super(parent.context);
}
