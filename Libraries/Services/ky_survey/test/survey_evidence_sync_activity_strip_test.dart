import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_evidence_sync_activity_summary.dart';
import 'package:ky_survey/widgets/dashboard/survey_evidence_sync_activity_strip.dart';

void main() {
  group('SurveyEvidenceSyncActivityStrip', () {
    testWidgets('renders active upload context and metrics', (tester) async {
      var opened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SurveyEvidenceSyncActivityStrip(
              summary: const SurveyEvidenceSyncActivitySummary(
                activeUploadCount: 2,
                readyUploadCount: 1,
              ),
              onPressed: () => opened = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.sync_outlined), findsOneWidget);
      expect(find.text('Evidence uploads running'), findsOneWidget);
      expect(find.text('2 uploads running | 1 upload ready'), findsOneWidget);
      expect(find.text('Uploading'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);

      await tester.tap(find.byType(SurveyEvidenceSyncActivityStrip));
      await tester.pump();

      expect(opened, isTrue);
    });

    testWidgets('stays hidden when there is no sync activity', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SurveyEvidenceSyncActivityStrip(
              summary: SurveyEvidenceSyncActivitySummary(),
            ),
          ),
        ),
      );

      expect(find.byType(DecoratedBox), findsNothing);
      expect(find.text('Evidence sync clear'), findsNothing);
    });
  });
}
