import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/json_render_safety_example.dart';
import 'package:tenun_showcase/example/json_render_safety_models.dart';

import 'support/showcase_widget_test_harness.dart';

void main() {
  setUp(registerAllChartsForTest);

  testWidgets('JSON render safety example shows default render fallback', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: JsonRenderSafetyExample())),
    );
    await tester.pumpAndSettle();

    expect(find.text('JSON render safety'), findsOneWidget);
    expect(find.text('Unknown type'), findsOneWidget);
    expect(find.textContaining('Chart render error'), findsOneWidget);
    expect(find.textContaining('Render Doctor:'), findsOneWidget);
    expect(find.text('Observed callbacks'), findsOneWidget);
    expect(find.text('Telemetry JSON'), findsOneWidget);
    expect(
      find.textContaining('render.UnregisteredChartTypeException'),
      findsOneWidget,
    );
    expect(find.textContaining('tenun.jsonRenderSafety'), findsOneWidget);
    expect(find.textContaining('render_error'), findsOneWidget);
    expect(find.text('validation.none'), findsOneWidget);
    expect(find.textContaining('linee'), findsWidgets);
    expect(find.text('Payload'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'JSON render safety example can render strict validation fallback',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: JsonRenderSafetyExample(
              scenario: JsonRenderSafetyScenario.invalidSamplingPolicy,
              validatePayload: true,
              strictValidation: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invalid sampling policy'), findsOneWidget);
      expect(find.textContaining('Invalid chart payload'), findsOneWidget);
      expect(find.text('Observed callbacks'), findsOneWidget);
      expect(find.text('Telemetry JSON'), findsOneWidget);
      expect(find.text('render.none'), findsOneWidget);
      expect(find.text('validation.invalid'), findsOneWidget);
      expect(find.textContaining('validation_error'), findsOneWidget);
      expect(find.textContaining('sampling.enabled'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
