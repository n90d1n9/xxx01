import 'dart:ui';

import 'features/workflow/components/connection/model/connection_data.dart';
import 'features/workflow/exception/exception.dart';
import 'features/workflow/components/node/model/schema/node_data.dart';

import 'features/execution/execution_config.dart';
import 'features/workflow/schema/workflow_data.dart';
import 'features/workflow/service/workflow_execution.dart';
import 'features/workflow/schema/workflow_metadata.dart';

void exampleExecutionUsage() async {
  // Create workflow
  final workflow = WorkflowData(
    id: 'workflow-1',
    name: 'Test Workflow',
    description: 'Test workflow with loops and conditions',
    nodes: [
      NodeData(
        id: 'node-1',
        type: 'webhook',
        label: 'Start',
        position: Offset.zero,
        config: {},
      ),
      NodeData(
        id: 'node-2',
        type: 'llm',
        label: 'Process',
        position: const Offset(200, 0),
        config: {'model': 'gpt-4'},
      ),
    ],
    connections: [
      ConnectionData(
        id: 'conn-1',
        sourceNodeId: 'node-1',
        targetNodeId: 'node-2',
        sourcePortId: 'output',
        targetPortId: 'input',
        start: Offset(0, 0),
        end: Offset(0, 0),
      ),
    ],
    metadata: WorkflowMetadata(
      id: 'workflow-1',
      name: 'Test Workflow',
      description: '',
      version: '1.0.0',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'user-1',
    ),
  );

  // Create executor
  final logger = LoggingExecutionListener();
  final executor = WorkflowExecutor(
    workflow: workflow,
    initialContext: {'input': 'test data'},
    config: ExecutionConfig(maxRetries: 3),
    listeners: [logger],
  );

  // Execute
  final result = await executor.execute();
  print('Execution status: ${result.status}');
  print('Duration: ${result.duration?.inSeconds}s');

  // Print logs
  logger.printLogs();
}
