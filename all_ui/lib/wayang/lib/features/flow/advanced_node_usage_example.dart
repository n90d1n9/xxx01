import 'batch/batch_process_executor.dart';
import 'batch/batch_processor_node_definition.dart';
import 'batch/batch_trigger.dart';
import 'router/router_route.dart';
import 'router/router_strategy.dart';
import 'switch/switch_editor.dart';
import 'switch/switch_router_node_executor.dart';
import 'trycatch/pararel_execution_exception.dart';
import 'trycatch/retry_strategy.dart';
import 'trycatch/trycatch_finally_defintion.dart';
import 'trycatch/trycatch_finaly.dart';

class AdvancedNodesUsageExample {
  // Try-Catch-Finally Example
  Future<void> demonstrateTryCatchFinally() async {
    final tryCatchNode = TryCatchFinallyNodeDefinition(
      id: 'api_retry',
      name: 'API Call with Retry',
      description: 'Call external API with automatic retry',
      maxRetries: 3,
      retryStrategy: RetryStrategy.exponentialBackoff,
      retryDelay: const Duration(seconds: 1),
      backoffMultiplier: 2.0,
    );

    final executor = TryCatchFinallyNodeExecutor(tryCatchNode);

    final result = await executor.execute(
      {'url': 'https://api.example.com/data'},
      // Try block
      (input) async {
        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 500));
        // Simulate random failure
        if (DateTime.now().millisecond % 2 == 0) {
          throw Exception('API temporarily unavailable');
        }
        return {'data': 'Success response', 'status': 200};
      },
      // Catch block
      (input, error) async {
        print('All retries failed: $error');
        return {'data': 'Fallback response', 'status': 500};
      },
      // Finally block
      (data) async {
        print('Cleaning up resources...');
      },
    );

    print('Result: $result');
  }

  // Parallel Execution Example
  Future<void> demonstrateParallelExecution() async {
    final parallelNode = ParallelExecutionNodeDefinition(
      id: 'multi_search',
      name: 'Multi-Source Search',
      description: 'Search multiple databases simultaneously',
      parallelBranches: 3,
      waitStrategy: ParallelWaitStrategy.all,
      branchTimeout: const Duration(seconds: 10),
    );

    final executor = ParallelExecutionNodeExecutor(parallelNode);

    final result = await executor.execute(
      {'query': 'customer data'},
      [
        // Branch 1: Search SQL database
        (input) async {
          await Future.delayed(const Duration(seconds: 1));
          return {
            'source': 'sql',
            'results': ['customer1', 'customer2'],
          };
        },
        // Branch 2: Search NoSQL database
        (input) async {
          await Future.delayed(const Duration(milliseconds: 800));
          return {
            'source': 'nosql',
            'results': ['customer3', 'customer4'],
          };
        },
        // Branch 3: Search API
        (input) async {
          await Future.delayed(const Duration(milliseconds: 1200));
          return {
            'source': 'api',
            'results': ['customer5'],
          };
        },
      ],
    );

    print('Parallel execution result: $result');
    // Result contains data from all branches
  }

  // Switch/Router Example
  Future<void> demonstrateSwitchRouter() async {
    final routerNode = SwitchRouterNodeDefinition(
      id: 'load_balancer',
      name: 'Agent Load Balancer',
      description: 'Distribute requests across agents',
      routes: [
        RouterRoute(id: 'agent_1', label: 'Agent 1', weight: 2),
        RouterRoute(id: 'agent_2', label: 'Agent 2', weight: 1),
        RouterRoute(id: 'agent_3', label: 'Agent 3', weight: 1),
      ],
      strategy: RouterStrategy.weightedRandom,
      enableLoadBalancing: true,
    );

    final executor = SwitchRouterNodeExecutor(routerNode);

    // Route 10 requests
    for (var i = 0; i < 10; i++) {
      final result = await executor.execute({'request_id': i});
      print('Request $i routed to: ${result['route']}');
    }
  }

  // Batch Processor Example
  Future<void> demonstrateBatchProcessor() async {
    final batchNode = BatchProcessorNodeDefinition(
      id: 'email_batch',
      name: 'Email Batch Sender',
      description: 'Send emails in batches',
      batchSize: 5,
      batchTimeout: const Duration(seconds: 10),
      trigger: BatchTrigger.both,
    );

    final executor = BatchProcessorNodeExecutor(batchNode);

    // Add items one by one
    for (var i = 1; i <= 12; i++) {
      final result = await executor.addItem(
        {'email': 'user$i@example.com', 'subject': 'Newsletter $i'},
        // Process batch function
        (batch) async {
          print('Processing batch of ${batch.length} emails...');
          await Future.delayed(const Duration(seconds: 1));
          return {
            'sent': batch.length,
            'timestamp': DateTime.now().toIso8601String(),
          };
        },
      );

      if (result['batch_processed'] == true) {
        print('Batch processed: ${result['batch_size']} emails sent');
      } else {
        print('Email queued (${result['queue_size']}/${batchNode.batchSize})');
      }
    }
  }

  // Combined workflow example
  Future<void> demonstrateCombinedWorkflow() async {
    print('=== Combined Workflow Demo ===\n');

    // 1. Try to fetch data with retry
    print('Step 1: Fetching data with retry logic...');
    await demonstrateTryCatchFinally();

    // 2. Process in parallel
    print('\nStep 2: Processing in parallel...');
    await demonstrateParallelExecution();

    // 3. Route to appropriate agent
    print('\nStep 3: Routing to agents...');
    await demonstrateSwitchRouter();

    // 4. Batch process results
    print('\nStep 4: Batch processing results...');
    await demonstrateBatchProcessor();

    print('\n=== Workflow Complete ===');
  }
}
