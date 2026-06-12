typedef SurveyEvidenceUploadRetryDelay =
    Duration Function(int completedAttempts);
typedef SurveyEvidenceUploadRetryWait = Future<void> Function(Duration delay);

Future<void> defaultSurveyEvidenceUploadRetryWait(Duration delay) {
  if (delay <= Duration.zero) {
    return Future.value();
  }
  return Future<void>.delayed(delay);
}

class SurveyEvidenceUploadRetryPolicy {
  final int maxAttempts;
  final SurveyEvidenceUploadRetryDelay retryDelay;

  const SurveyEvidenceUploadRetryPolicy({
    this.maxAttempts = 1,
    this.retryDelay = _noDelay,
  }) : assert(maxAttempts > 0);

  const SurveyEvidenceUploadRetryPolicy.none() : this();

  factory SurveyEvidenceUploadRetryPolicy.fixed({
    required int maxAttempts,
    Duration delay = Duration.zero,
  }) {
    return SurveyEvidenceUploadRetryPolicy(
      maxAttempts: maxAttempts,
      retryDelay: (_) => delay,
    );
  }

  bool shouldRetry({required int completedAttempts, required bool failed}) {
    return failed && completedAttempts < maxAttempts;
  }

  Duration delayAfterAttempt(int completedAttempts) {
    if (completedAttempts <= 0) {
      return Duration.zero;
    }
    return retryDelay(completedAttempts);
  }

  static Duration _noDelay(int completedAttempts) => Duration.zero;
}
