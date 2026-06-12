import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue_actions.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue_coordinator.dart';
import 'package:ky_survey/logic/survey_evidence_upload_service.dart';
import 'package:ky_survey/widgets/dashboard/survey_evidence_upload_queue_action_panel.dart';
import 'package:ky_survey/widgets/dashboard/survey_evidence_upload_queue_dashboard_binding.dart';

void main() {
  group('SurveyEvidenceUploadQueuePanelBuilderResolver', () {
    testWidgets('prefers a custom panel builder', (tester) async {
      final builder = SurveyEvidenceUploadQueuePanelBuilderResolver(
        customBuilder: (context, plan) {
          return const SizedBox(key: Key('custom-panel'));
        },
        legacyController: _controller(),
      ).resolve();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return builder!(
                context,
                const SurveyEvidenceUploadPlan(tasks: []),
              );
            },
          ),
        ),
      );

      expect(find.byKey(const Key('custom-panel')), findsOneWidget);
      expect(find.byType(SurveyEvidenceUploadQueueActionPanel), findsNothing);
    });

    test(
      'returns null without a custom builder, binding, or legacy controller',
      () {
        final builder = const SurveyEvidenceUploadQueuePanelBuilderResolver()
            .resolve();

        expect(builder, isNull);
      },
    );

    testWidgets('resolves an explicit binding with a fallback observer', (
      tester,
    ) async {
      final controller = _controller();
      final fallbackObserver = _RecordingObserver();
      final binding = SurveyEvidenceUploadQueueDashboardBinding(
        controller: controller,
      );
      final builder = SurveyEvidenceUploadQueuePanelBuilderResolver(
        binding: binding,
      ).resolve(fallbackObserver: fallbackObserver);
      final context = await _captureContext(tester);

      final panel =
          builder!(context, const SurveyEvidenceUploadPlan(tasks: []))
              as SurveyEvidenceUploadQueueActionPanel;

      expect(panel.controller, controller);
      expect(panel.uploadObserver, fallbackObserver);
    });

    testWidgets('resolves legacy controller inputs into an action panel', (
      tester,
    ) async {
      final controller = _controller();
      final observer = _RecordingObserver();
      void handleState(SurveyEvidenceUploadQueueActionState state) {}
      void handleResult(SurveyEvidenceUploadQueueActionResult result) {}
      void handleError(Object error, StackTrace stackTrace) {}

      final builder = SurveyEvidenceUploadQueuePanelBuilderResolver(
        legacyController: controller,
        legacyUploadObserver: observer,
        onStateChanged: handleState,
        onActionComplete: handleResult,
        onActionError: handleError,
      ).resolve();
      final context = await _captureContext(tester);

      final panel =
          builder!(context, const SurveyEvidenceUploadPlan(tasks: []))
              as SurveyEvidenceUploadQueueActionPanel;

      expect(panel.controller, controller);
      expect(panel.uploadObserver, observer);
      expect(panel.onStateChanged, handleState);
      expect(panel.onActionComplete, handleResult);
      expect(panel.onActionError, handleError);
    });
  });
}

Future<BuildContext> _captureContext(WidgetTester tester) async {
  late BuildContext capturedContext;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return capturedContext;
}

SurveyEvidenceUploadQueueActionController _controller() {
  return SurveyEvidenceUploadQueueActionController.fromStore(
    store: SurveyEvidenceUploadMemoryQueueStore(),
    uploader: _NoopUploader(),
  );
}

class _RecordingObserver extends SurveyEvidenceUploadObserver {}

class _NoopUploader implements SurveyEvidenceUploader {
  @override
  Future<SurveyEvidenceUploadResult> upload(
    SurveyEvidenceUploadRequest request,
  ) async {
    return const SurveyEvidenceUploadResult.skipped(message: 'not used');
  }
}
