import 'package:ky_survey/logic/survey_evidence_upload_retry_policy.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyEvidenceUploadRetryPolicy', () {
    test('does not retry by default', () {
      const policy = SurveyEvidenceUploadRetryPolicy.none();

      expect(policy.maxAttempts, 1);
      expect(policy.shouldRetry(completedAttempts: 1, failed: true), isFalse);
      expect(policy.shouldRetry(completedAttempts: 0, failed: false), isFalse);
      expect(policy.delayAfterAttempt(1), Duration.zero);
    });

    test('allows retries until max attempts with a fixed delay', () {
      final policy = SurveyEvidenceUploadRetryPolicy.fixed(
        maxAttempts: 3,
        delay: const Duration(seconds: 2),
      );

      expect(policy.shouldRetry(completedAttempts: 1, failed: true), isTrue);
      expect(policy.shouldRetry(completedAttempts: 2, failed: true), isTrue);
      expect(policy.shouldRetry(completedAttempts: 3, failed: true), isFalse);
      expect(policy.shouldRetry(completedAttempts: 1, failed: false), isFalse);
      expect(policy.delayAfterAttempt(1), const Duration(seconds: 2));
    });
  });
}
