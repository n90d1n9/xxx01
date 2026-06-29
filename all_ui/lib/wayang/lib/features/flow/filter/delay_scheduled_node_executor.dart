import 'dart:async';

import 'delay_schedule_node_definition.dart';
import 'schedule_type.dart';

class DelayScheduleNodeExecutor {
  final DelayScheduleNodeDefinition definition;
  Timer? _timer;
  int _executionCount = 0;

  DelayScheduleNodeExecutor(this.definition);

  Future<Map<String, dynamic>> execute(
    Map<String, dynamic> input,
    Future<Map<String, dynamic>> Function(Map<String, dynamic>) action,
  ) async {
    switch (definition.scheduleType) {
      case ScheduleType.delay:
        return await _executeDelay(input, action);
      case ScheduleType.fixedTime:
        return await _executeFixedTime(input, action);
      case ScheduleType.cron:
        return await _executeCron(input, action);
      case ScheduleType.recurring:
        return await _executeRecurring(input, action);
    }
  }

  Future<Map<String, dynamic>> _executeDelay(
    Map<String, dynamic> input,
    Future<Map<String, dynamic>> Function(Map<String, dynamic>) action,
  ) async {
    if (definition.delay == null) {
      return {'success': false, 'error': 'Delay duration not specified'};
    }

    await Future.delayed(definition.delay!);
    final result = await action(input);

    return {
      'success': true,
      'output_port': 'executed',
      'data': result,
      'delay': definition.delay!.inMilliseconds,
    };
  }

  Future<Map<String, dynamic>> _executeFixedTime(
    Map<String, dynamic> input,
    Future<Map<String, dynamic>> Function(Map<String, dynamic>) action,
  ) async {
    if (definition.scheduledTime == null) {
      return {'success': false, 'error': 'Scheduled time not specified'};
    }

    final now = DateTime.now();
    final scheduledTime = definition.scheduledTime!;

    if (scheduledTime.isBefore(now)) {
      return {'success': false, 'error': 'Scheduled time is in the past'};
    }

    final delay = scheduledTime.difference(now);
    await Future.delayed(delay);
    final result = await action(input);

    return {
      'success': true,
      'output_port': 'executed',
      'data': result,
      'scheduled_time': scheduledTime.toIso8601String(),
      'executed_at': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> _executeCron(
    Map<String, dynamic> input,
    Future<Map<String, dynamic>> Function(Map<String, dynamic>) action,
  ) async {
    // Simplified cron - in production use a proper cron parser
    if (definition.cronExpression == null) {
      return {'success': false, 'error': 'Cron expression not specified'};
    }

    return {
      'success': true,
      'scheduled': true,
      'cron': definition.cronExpression,
      'message': 'Cron scheduled (implementation required)',
    };
  }

  Future<Map<String, dynamic>> _executeRecurring(
    Map<String, dynamic> input,
    Future<Map<String, dynamic>> Function(Map<String, dynamic>) action,
  ) async {
    if (definition.recurInterval == null) {
      return {'success': false, 'error': 'Recurrence interval not specified'};
    }

    final results = <Map<String, dynamic>>[];

    while (definition.maxRecurrences == null ||
        _executionCount < definition.maxRecurrences!) {
      await Future.delayed(definition.recurInterval!);
      final result = await action(input);
      results.add(result);
      _executionCount++;
    }

    return {
      'success': true,
      'output_port': 'completed',
      'executions': _executionCount,
      'results': results,
    };
  }

  void cancel() {
    _timer?.cancel();
  }

  void reset() {
    _executionCount = 0;
    _timer?.cancel();
  }
}
