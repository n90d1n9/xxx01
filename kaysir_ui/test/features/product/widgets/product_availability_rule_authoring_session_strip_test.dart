import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_availability_rule_authoring.dart';
import 'package:kaysir/features/product/models/product_availability_rule_authoring_session.dart';
import 'package:kaysir/features/product/widgets/product_availability_rule_authoring_session_strip.dart';

void main() {
  testWidgets('availability authoring session strip renders custom session', (
    tester,
  ) async {
    var resetCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductAvailabilityRuleAuthoringSessionStrip(
            summary: _customSummary,
            persistence:
                const ProductAvailabilityRuleAuthoringSessionPersistenceState(
                  phase:
                      ProductAvailabilityRuleAuthoringSessionPersistencePhase
                          .saving,
                ),
            onReset: () => resetCount += 1,
          ),
        ),
      ),
    );

    expect(find.text('Authoring session'), findsOneWidget);
    expect(find.text('Fresh shelf | Stock attention'), findsOneWidget);
    expect(find.text('Saving session'), findsOneWidget);
    expect(find.text('Custom session'), findsOneWidget);
    expect(
      find.text('Source: Freshness availability templates'),
      findsOneWidget,
    );
    expect(find.text('Template: Fresh shelf'), findsOneWidget);
    expect(find.text('Target: Stock attention'), findsOneWidget);
    expect(find.text('2 templates available'), findsOneWidget);
    expect(find.text('8 templates total'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Reset'));
    await tester.pump();

    expect(resetCount, 1);
  });

  testWidgets('availability authoring session strip disables default reset', (
    tester,
  ) async {
    var resetCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductAvailabilityRuleAuthoringSessionStrip(
            summary: _defaultSummary,
            onReset: () => resetCount += 1,
          ),
        ),
      ),
    );

    expect(find.text('Default session'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Counter service | Missing rules'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Reset'));
    await tester.pump();

    expect(resetCount, 0);
  });
}

const _freshShelfEntry = ProductAvailabilityRuleTemplateEntry(
  sourceId: 'freshness_availability_templates',
  sourceTitle: 'Freshness availability templates',
  template: ProductAvailabilityRuleTemplate(
    id: ProductAvailabilityRuleTemplateId.freshShelf,
    title: 'Fresh shelf',
    subtitle: 'Fresh goods selling with expiry-aware stock gates.',
    attributes: {
      'available_channels': 'POS, Online Store',
      'stock_policy': 'in_stock_only',
    },
  ),
);

final _counterServiceEntry = ProductAvailabilityRuleTemplateEntry(
  template: productAvailabilityRuleTemplateFor(
    ProductAvailabilityRuleTemplateId.counterService,
  ),
);

const _customSummary = ProductAvailabilityRuleAuthoringSessionSummary(
  sourceId: 'freshness_availability_templates',
  sourceLabel: 'Freshness availability templates',
  sourceTemplateCount: 2,
  totalTemplateCount: 8,
  templateEntry: _freshShelfEntry,
  target: ProductAvailabilityRuleAuthoringTarget.stockAttention,
);

final _defaultSummary = ProductAvailabilityRuleAuthoringSessionSummary(
  sourceId: productAvailabilityRuleTemplateAllSourceId,
  sourceLabel: 'All templates',
  sourceTemplateCount: 6,
  totalTemplateCount: 6,
  templateEntry: _counterServiceEntry,
  target: ProductAvailabilityRuleAuthoringTarget.unconfigured,
);
