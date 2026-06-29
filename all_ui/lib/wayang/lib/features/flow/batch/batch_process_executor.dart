import 'package:wayang_builder/features/flow/batch/batch_processor_node_definition.dart';

class BatchProcessorNodeExecutor {
  BatchProcessorNodeExecutor(BatchProcessorNodeDefinition batchNode);

  Future addItem(
    Map<String, String> map,
    Future<Map<String, dynamic>> Function(dynamic batch) param1,
  ) async {}
}
