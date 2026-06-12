import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_insights.dart';
import 'package:ky_survey/analytics/survey_response_insights.dart';
import 'package:ky_survey/analytics/survey_response_sync_readiness.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/widgets/dashboard/survey_focused_section_highlight.dart';
import 'package:ky_survey/widgets/dashboard/survey_reports_section.dart';

void main() {
  group('SurveyReportsSection', () {
    testWidgets('focuses the evidence sync area when requested', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.binding.setSurfaceSize(const Size(760, 360));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_reportsSection(controller: controller));

      expect(controller.offset, 0);
      expect(find.text('Evidence Upload Plan'), findsOneWidget);

      await tester.pumpWidget(
        _reportsSection(controller: controller, evidenceSyncFocusRequestId: 1),
      );
      await tester.pump();

      expect(_focusedHighlight().highlighted, isTrue);

      await tester.pumpAndSettle();

      expect(controller.offset, greaterThan(0));

      await tester.pump(const Duration(milliseconds: 1900));
      await tester.pumpAndSettle();

      expect(_focusedHighlight().highlighted, isFalse);
    });
  });
}

SurveyFocusedSectionHighlight _focusedHighlight() {
  return find
          .byWidgetPredicate(
            (widget) =>
                widget is SurveyFocusedSectionHighlight &&
                widget.semanticsLabel == 'Focused evidence sync work area',
          )
          .evaluate()
          .single
          .widget
      as SurveyFocusedSectionHighlight;
}

Widget _reportsSection({
  required ScrollController controller,
  int evidenceSyncFocusRequestId = 0,
}) {
  const surveys = <Survey>[];
  const responses = <SurveyResponse>[];

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.all(16),
        child: SurveyReportsSection(
          insights: const SurveyInsights(surveys),
          responseInsights: const SurveyResponseInsights(
            surveys: surveys,
            responses: responses,
          ),
          responseSyncReadiness: SurveyResponseSyncReadinessInsights.evaluate(
            surveys: surveys,
            responses: responses,
          ),
          evidenceSyncInsights: const SurveyEvidenceSyncInsights(
            surveys: surveys,
            responses: responses,
          ),
          surveys: surveys,
          evidenceSyncFocusRequestId: evidenceSyncFocusRequestId,
        ),
      ),
    ),
  );
}
