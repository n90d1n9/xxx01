class ParallelProcessor {
  /// Processes data in parallel with advanced error handling
  Future<ProcessingResult> processInParallel<T>({
    required List<T> items,
    required Future<void> Function(T) processor,
    required ProcessingConfig config,
  }) async {
    final pool = Pool(config.maxConcurrent);
    final results = <ProcessingResult>[];
    final errors = <ProcessingError>[];
    
    await pool.forEach(items, (item) async {
      try {
        await processor(item);
        results.add(ProcessingResult(item: item, success: true));
      } catch (e) {
        final error = ProcessingError(
          item: item,
          error: e,
          timestamp: DateTime.now(),
        );
        errors.add(error);
        await _handleProcessingError(error, config);
      }
    });
    
    return BatchProcessingResult(
      successful: results,
      failed: errors,
      metrics: await _calculateProcessingMetrics(results, errors),
    );
  }
}
