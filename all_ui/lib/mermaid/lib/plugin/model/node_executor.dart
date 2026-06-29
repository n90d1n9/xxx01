import '../../execution/cost_estimate.dart';
import '../../execution/node_execution_chunk.dart';
import 'node_execution_context.dart';
import 'node_execution_result.dart';
import 'node_schema.dart';

abstract class NodeExecutor {
  String get nodeType;
  NodeSchema get schema;

  Future<NodeExecutionResult> execute(NodeExecutionContext context);

  // Optional: Batch execution
  Future<List<NodeExecutionResult>> executeBatch(
    List<NodeExecutionContext> contexts,
  ) async {
    return Future.wait(contexts.map((ctx) => execute(ctx)));
  }

  // Optional: Streaming execution
  Stream<NodeExecutionChunk>? executeStream(NodeExecutionContext context) =>
      null;

  // Validation
  Future<ValidationResult> validate(NodeExecutionContext context) async {
    return ValidationResult.valid();
  }

  // Cost estimation
  Future<CostEstimate> estimateCost(NodeExecutionContext context) async {
    return CostEstimate.free();
  }
}
