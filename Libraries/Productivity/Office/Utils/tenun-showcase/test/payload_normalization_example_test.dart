import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun/tenun_core.dart';
import 'package:tenun_showcase/example/payload_normalization_diagnostics.dart';
import 'package:tenun_showcase/example/payload_normalization_example.dart';
import 'package:tenun_showcase/example/payload_normalization_fixtures.dart';

import 'support/showcase_widget_test_harness.dart';

void main() {
  setUp(registerAllChartsForTest);

  Future<void> pumpExample(
    WidgetTester tester, {
    required bool sanitizeTradingPayload,
    bool highlightDiff = true,
  }) async {
    await pumpShowcaseBody(
      tester,
      physicalSize: const Size(1400, 1200),
      width: 1200,
      height: 900,
      settle: true,
      child: PayloadNormalizationExample(
        targetType: 'renko',
        autoNormalizePayload: true,
        strictValidation: true,
        dropUnsupportedSampling: true,
        sanitizeTradingPayload: sanitizeTradingPayload,
        highlightDiff: highlightDiff,
        normalizeDefaultThreshold: 1200,
        normalizeDefaultMode: 'auto',
      ),
    );
  }

  Text effectiveSummary(WidgetTester tester) {
    final finder = find.byWidgetPredicate(
      (w) =>
          w is Text &&
          w.data != null &&
          w.data!.startsWith('Effective payload:'),
    );
    expect(finder, findsOneWidget);
    return tester.widget<Text>(finder);
  }

  testWidgets('shows normalized trading payload details and controls', (
    WidgetTester tester,
  ) async {
    await pumpExample(tester, sanitizeTradingPayload: true);

    expect(find.textContaining('Target: renko'), findsOneWidget);
    expect(find.textContaining('Sanitize Trading: true'), findsOneWidget);
    expect(find.textContaining('Highlight Diff: true'), findsOneWidget);
    expect(find.text('Copy Raw JSON'), findsOneWidget);
    expect(find.text('Copy Normalized JSON'), findsOneWidget);
    expect(find.text('Copy Effective JSON'), findsOneWidget);
    expect(find.text('Copy Diagnostics JSON'), findsOneWidget);
    expect(find.text('Copy Doctor JSON'), findsOneWidget);
    expect(find.text('Diagnostics JSON'), findsOneWidget);
    expect(
      find.textContaining('Doctor: raw repairable, normalized warning'),
      findsOneWidget,
    );
    expect(find.text('Diff (Raw -> Normalized)'), findsOneWidget);
    expect(find.text(r'$.brickSize'), findsOneWidget);
    expect(find.textContaining('added:'), findsOneWidget);
    expect(find.textContaining('removed:'), findsOneWidget);
    expect(find.textContaining('changed:'), findsOneWidget);
    expect(find.text('CHANGED'), findsWidgets);

    final summary = effectiveSummary(tester).data!;
    expect(summary.contains('Effective payload: normalized'), isTrue);
    expect(summary.contains('errors: 0'), isTrue);

    expect(tester.takeException(), isNull);
  });

  testWidgets('can disable trading sanitation in normalized preview', (
    WidgetTester tester,
  ) async {
    await pumpExample(tester, sanitizeTradingPayload: false);

    expect(find.textContaining('Sanitize Trading: false'), findsOneWidget);
    expect(find.text('No changed paths.'), findsOneWidget);
    expect(
      find.textContaining('Doctor: raw invalid, normalized invalid'),
      findsOneWidget,
    );

    final summary = effectiveSummary(tester).data!;
    expect(summary.contains('Effective payload: normalized'), isTrue);
    expect(summary.contains('errors: 0'), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports plain diff mode when highlight is disabled', (
    WidgetTester tester,
  ) async {
    await pumpExample(
      tester,
      sanitizeTradingPayload: true,
      highlightDiff: false,
    );

    expect(find.textContaining('Highlight Diff: false'), findsOneWidget);
    expect(find.textContaining(r'$.brickSize: -2 -> 1.0'), findsOneWidget);
    expect(find.text('CHANGED'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('fixtures expose target-specific broken payloads and mode parsing', () {
    final renko = buildPayloadNormalizationBrokenPayload('renko');
    final fallback = buildPayloadNormalizationBrokenPayload('unknown');

    expect(renko['type'], 'renko');
    expect(renko['brickSize'], -2);
    expect(fallback['type'], 'line');
    expect(fallback['dataMode'], 'turbo');
    expect(parsePayloadNormalizationMode('regular'), ChartDataMode.regular);
    expect(parsePayloadNormalizationMode('large'), ChartDataMode.large);
    expect(parsePayloadNormalizationMode('turbo'), ChartDataMode.auto);
  });

  test('diagnostics helper captures options and validation snapshots', () {
    final raw = buildPayloadNormalizationBrokenPayload('renko');
    final options = PayloadNormalizationOptions(
      dropUnsupportedSampling: true,
      defaultThreshold: 1200,
      defaultMode: ChartDataMode.auto,
      sanitizeTradingPayload: true,
    );
    final report = ChartConfigValidator.normalizePayloadWithReport(
      raw,
      options: options,
    );
    final normalized = report.normalizedPayload;
    final rawValidation = ChartConfigValidator.validateJsonPayload(
      raw,
      deep: false,
    );
    final normalizedValidation = ChartConfigValidator.validateJsonPayload(
      normalized,
      deep: false,
    );
    final rawDoctor = ChartPayloadDoctor.inspect(
      raw,
      normalizationOptions: options,
    );
    final normalizedDoctor = ChartPayloadDoctor.inspect(
      normalized,
      normalizationOptions: options,
    );

    final diagnostics = buildPayloadNormalizationDiagnostics(
      targetType: 'renko',
      autoNormalizePayload: true,
      strictValidation: true,
      dropUnsupportedSampling: true,
      sanitizeTradingPayload: true,
      normalizeDefaultThreshold: 1200,
      normalizeDefaultMode: 'auto',
      effectivePayloadSource: 'normalized',
      rawValidation: rawValidation,
      normalizedValidation: normalizedValidation,
      effectiveValidation: normalizedValidation,
      normalizationReport: report,
      rawDoctor: rawDoctor,
      normalizedDoctor: normalizedDoctor,
      effectiveDoctor: normalizedDoctor,
    );
    final optionPayload = diagnostics['options'] as Map<String, dynamic>;
    final validationPayload = diagnostics['validation'] as Map<String, dynamic>;
    final doctorPayload = diagnostics['doctor'] as Map<String, dynamic>;

    expect(diagnostics['targetType'], 'renko');
    expect(diagnostics['effectivePayloadSource'], 'normalized');
    expect(optionPayload['sanitizeTradingPayload'], isTrue);
    expect(optionPayload['normalizeDefaultThreshold'], 1200);
    expect(
      validationPayload.keys,
      containsAll(['raw', 'normalized', 'effective']),
    );
    expect(doctorPayload.keys, containsAll(['raw', 'normalized', 'effective']));
    expect(
      (doctorPayload['raw'] as Map<String, dynamic>)['status'],
      'repairable',
    );
    expect(
      (doctorPayload['effective'] as Map<String, dynamic>)['status'],
      'warning',
    );
    expect(diagnostics['normalization'], isA<Map<String, dynamic>>());
  });
}
