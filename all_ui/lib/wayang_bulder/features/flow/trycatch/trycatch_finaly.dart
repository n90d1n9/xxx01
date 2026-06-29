import 'retry_strategy.dart';
import 'trycatch_finally_defintion.dart';

class TryCatchFinallyNodeExecutor {
  final TryCatchFinallyNodeDefinition definition;

  TryCatchFinallyNodeExecutor(this.definition);

  Future<Map<String, dynamic>> execute(
    Map<String, dynamic> input,
    Future<Map<String, dynamic>> Function(Map<String, dynamic>) tryBlock,
    Future<Map<String, dynamic>> Function(Map<String, dynamic>, dynamic error)?
    catchBlock,
    Future<void> Function(Map<String, dynamic>)? finallyBlock,
  ) async {
    var attempts = 0;
    dynamic lastError;
    Map<String, dynamic>? result;

    try {
      while (attempts <= definition.maxRetries) {
        try {
          result = await tryBlock(input);

          return {
            'success': true,
            'output_port': 'success',
            'data': result,
            'attempts': attempts + 1,
          };
        } catch (e) {
          lastError = e;
          attempts++;

          if (attempts > definition.maxRetries) {
            break;
          }

          // Calculate retry delay
          final delay = _calculateRetryDelay(attempts);
          await Future.delayed(delay);
        }
      }

      // All retries exhausted, execute catch block
      if (catchBlock != null) {
        result = await catchBlock(input, lastError);
        return {
          'success': false,
          'output_port': 'catch',
          'data': result,
          'error': lastError.toString(),
          'attempts': attempts,
        };
      } else {
        return {
          'success': false,
          'output_port': 'error',
          'data': input,
          'error': lastError.toString(),
          'attempts': attempts,
        };
      }
    } finally {
      if (finallyBlock != null &&
          (definition.executeFinallyOnError || result != null)) {
        await finallyBlock(result ?? input);
      }
    }
  }

  Duration _calculateRetryDelay(int attempt) {
    switch (definition.retryStrategy) {
      case RetryStrategy.none:
        return Duration.zero;
      case RetryStrategy.fixedDelay:
        return definition.retryDelay;
      case RetryStrategy.exponentialBackoff:
        final multiplier = definition.backoffMultiplier;
        final delayMs =
            definition.retryDelay.inMilliseconds * (multiplier * (attempt - 1));
        return Duration(milliseconds: delayMs.toInt());
      case RetryStrategy.custom:
        return definition.retryDelay;
    }
  }
}
