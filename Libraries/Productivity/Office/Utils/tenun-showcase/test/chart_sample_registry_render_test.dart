import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/chart_sample_panels.dart';
import 'package:tenun_showcase/example/chart_samples_registry.dart';

import 'support/showcase_widget_test_harness.dart';

const _smokeRenderOptions = ChartSampleShowcaseOptions(
  showSampleJson: false,
  showSampleCode: false,
);

void main() {
  setUp(registerAllChartsForTest);

  group('focused registry sample render smoke', () {
    for (final family in ChartSamplesRegistry.focusedFamilies) {
      group(family.id, () {
        for (final sample in family.samples) {
          testWidgets('${sample.title} renders from registry JSON', (
            WidgetTester tester,
          ) async {
            await pumpShowcaseBody(
              tester,
              width: 820,
              height: sample.height + 96,
              child: ChartSamplePanel(
                sample: sample,
                options: _smokeRenderOptions,
              ),
            );

            expect(find.text(sample.title), findsAtLeastNWidgets(1));
            expect(
              tester.takeException(),
              isNull,
              reason: _renderFailureReason(family, sample),
            );
          });
        }
      });
    }
  });
}

String _renderFailureReason(
  ChartShowcaseFamily family,
  ChartShowcaseSample sample,
) {
  final type = sample.json['type'];
  final chartType = type is String ? type : '<missing type>';
  return '${family.id} / ${sample.title} ($chartType) failed to render';
}
