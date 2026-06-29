import 'cache/cache_node_definition.dart';
import 'cache/cache_node_executor.dart';
import 'cache/cache_strategy.dart';
import 'delay_schedule_node_definition.dart';
import 'delay_scheduled_node_executor.dart';
import 'filter_transform_definition.dart';
import 'filter_transform_executor.dart';
import 'merge_join_definition.dart';
import 'merge_join_executor.dart';
import 'merge_strategy.dart';
import 'schedule_type.dart';
import 'transform_operation.dart';

class AdvancedNodesPart3Examples {
  // Merge/Join Example
  Future<void> demonstrateMergeJoin() async {
    final mergeNode = MergeJoinNodeDefinition(
      id: 'data_merger',
      name: 'Merge User Data',
      description: 'Combine user data from multiple sources',
      inputCount: 3,
      strategy: MergeStrategy.union,
      waitForAll: true,
    );

    final executor = MergeJoinNodeExecutor(mergeNode);

    // Add inputs from different sources
    await executor.addInput(0, {'id': '123', 'name': 'John', 'age': 30});
    await executor.addInput(1, {
      'id': '123',
      'email': 'john@example.com',
      'verified': true,
    });
    final result = await executor.addInput(2, {
      'id': '123',
      'subscription': 'premium',
      'joined': '2024-01-01',
    });

    print('Merged data: ${result['data']}');
  }

  // Delay/Schedule Example
  Future<void> demonstrateDelaySchedule() async {
    final delayNode = DelayScheduleNodeDefinition(
      id: 'delayed_email',
      name: 'Delayed Email Sender',
      description: 'Send email after delay',
      scheduleType: ScheduleType.delay,
      delay: const Duration(seconds: 5),
    );

    final executor = DelayScheduleNodeExecutor(delayNode);

    print('Scheduling email send in 5 seconds...');
    final result = await executor.execute(
      {'to': 'user@example.com', 'subject': 'Welcome!'},
      (input) async {
        print('Sending email to ${input['to']}...');
        return {'sent': true, 'timestamp': DateTime.now().toIso8601String()};
      },
    );

    print('Result: $result');
  }

  // Filter/Transform Example
  Future<void> demonstrateFilterTransform() async {
    // Filter example
    final filterNode = FilterTransformNodeDefinition(
      id: 'high_value_filter',
      name: 'High Value Filter',
      description: 'Filter high-value customers',
      operation: TransformOperation.filter,
      filterCondition: 'value > 1000',
    );

    final filterExecutor = FilterTransformNodeExecutor(filterNode);

    final filterResult = await filterExecutor.execute({
      'items': [
        {'id': 1, 'name': 'Customer A', 'value': 1500},
        {'id': 2, 'name': 'Customer B', 'value': 500},
        {'id': 3, 'name': 'Customer C', 'value': 2000},
      ],
    });

    print('Filtered customers: ${filterResult['data']['items']}');

    // Aggregate example
    final aggNode = FilterTransformNodeDefinition(
      id: 'revenue_sum',
      name: 'Total Revenue',
      description: 'Calculate total revenue',
      operation: TransformOperation.aggregate,
      aggregateField: 'value',
      aggregateFunction: 'sum',
    );

    final aggExecutor = FilterTransformNodeExecutor(aggNode);
    final aggResult = await aggExecutor.execute(filterResult['data']);

    print('Total revenue: ${aggResult['data']['aggregate_result']}');
  }

  // Cache Example
  Future<void> demonstrateCache() async {
    final cacheNode = CacheNodeDefinition(
      id: 'api_cache',
      name: 'API Response Cache',
      description: 'Cache expensive API calls',
      strategy: CacheStrategy.timeToLive,
      ttl: const Duration(minutes: 5),
      maxSize: 100,
      cacheKeyField: 'user_id',
    );

    final executor = CacheNodeExecutor(cacheNode);

    // First call - miss
    print('First call...');
    var result = await executor.execute(
      {'user_id': '123', 'query': 'profile'},
      (input) async {
        print('Making expensive API call...');
        await Future.delayed(const Duration(seconds: 2));
        return {
          'data': 'user profile data',
          'timestamp': DateTime.now().toIso8601String(),
        };
      },
    );
    print('Cache hit: ${result['cache_hit']}'); // false

    // Second call - hit
    print('\nSecond call...');
    result = await executor.execute({'user_id': '123', 'query': 'profile'}, (
      input,
    ) async {
      print('Making expensive API call...');
      await Future.delayed(const Duration(seconds: 2));
      return {
        'data': 'user profile data',
        'timestamp': DateTime.now().toIso8601String(),
      };
    });
    print('Cache hit: ${result['cache_hit']}'); // true
    print('Cache stats: ${executor.getStats()}');
  }
}
