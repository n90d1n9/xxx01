import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/widgets/dashboard/survey_focused_section_highlight.dart';
import 'package:ky_survey/widgets/dashboard/survey_requested_section_focus.dart';

void main() {
  group('SurveyRequestedSectionFocus', () {
    testWidgets('scrolls and highlights a section for each new request', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.binding.setSurfaceSize(const Size(640, 360));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_focusHarness(controller: controller));

      expect(controller.offset, 0);
      expect(_focusedHighlight().highlighted, isFalse);

      await tester.pumpWidget(
        _focusHarness(controller: controller, requestId: 1),
      );
      await tester.pump();

      expect(_focusedHighlight().highlighted, isTrue);

      await tester.pumpAndSettle();

      expect(controller.offset, greaterThan(0));

      await tester.pump(const Duration(milliseconds: 1900));
      await tester.pumpAndSettle();

      expect(_focusedHighlight().highlighted, isFalse);

      await tester.pumpWidget(
        _focusHarness(controller: controller, requestId: 1),
      );
      await tester.pump();

      expect(_focusedHighlight().highlighted, isFalse);
    });

    testWidgets('forwards custom highlight padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SurveyRequestedSectionFocus(
              requestId: 1,
              semanticsLabel: 'Requested survey section',
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 120,
                child: Center(child: Text('Target evidence work')),
              ),
            ),
          ),
        ),
      );

      expect(_focusedHighlight().padding, EdgeInsets.zero);
    });
  });
}

SurveyFocusedSectionHighlight _focusedHighlight() {
  return find
          .byWidgetPredicate(
            (widget) =>
                widget is SurveyFocusedSectionHighlight &&
                widget.semanticsLabel == 'Requested survey section',
          )
          .evaluate()
          .single
          .widget
      as SurveyFocusedSectionHighlight;
}

Widget _focusHarness({
  required ScrollController controller,
  int requestId = 0,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        controller: controller,
        child: Column(
          children: [
            const SizedBox(height: 720),
            SurveyRequestedSectionFocus(
              requestId: requestId,
              semanticsLabel: 'Requested survey section',
              child: const SizedBox(
                height: 120,
                child: Center(child: Text('Target evidence work')),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
