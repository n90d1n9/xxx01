import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue_action_feedback.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue_actions.dart';
import 'package:ky_survey/widgets/dashboard/survey_evidence_upload_queue_feedback_banner.dart';
import 'package:ky_survey/widgets/survey_feedback_tone.dart';

void main() {
  group('SurveyFeedbackToneStyle', () {
    test('resolves shared tone icon and colors', () {
      final colorScheme = ThemeData().colorScheme;
      final style = SurveyFeedbackToneStyle.resolve(
        colorScheme,
        SurveyFeedbackTone.error,
      );

      expect(style.icon, Icons.error_outline);
      expect(style.color, colorScheme.error);
      expect(style.onColor, colorScheme.onError);
    });

    testWidgets('feeds queue feedback banner visuals', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SurveyEvidenceUploadQueueFeedbackBanner(
              feedback: SurveyEvidenceUploadQueueActionFeedback(
                action: SurveyEvidenceUploadQueueAction.runDueUploads,
                tone: SurveyEvidenceUploadQueueActionFeedbackTone.error,
                title: 'Uploads failed',
                message: '1 failed',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Uploads failed'), findsOneWidget);
      expect(find.text('1 failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
