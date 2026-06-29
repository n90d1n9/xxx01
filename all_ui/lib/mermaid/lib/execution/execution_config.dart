class ExecutionConfig {
  final int maxRetries;
  final int retryDelayMs;
  final int nodeTimeoutSeconds;
  final bool continueOnError;
  final bool enableDebugMode;
  final int maxConcurrentNodes;

  ExecutionConfig({
    this.maxRetries = 3,
    this.retryDelayMs = 1000,
    this.nodeTimeoutSeconds = 300,
    this.continueOnError = false,
    this.enableDebugMode = false,
    this.maxConcurrentNodes = 1,
  });
}
