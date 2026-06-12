import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_diagnostics_handoff.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_diagnostics.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_history.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_result.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_diagnostics_handoff_panel.dart';

void main() {
  testWidgets('diagnostics handoff card copies the share summary', (
    tester,
  ) async {
    String? copiedText;
    final summary = _summary();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            child: POSDiagnosticsHandoffCard(
              summary: summary,
              onCopy: (text) async {
                copiedText = text;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Handoff summary'), findsOneWidget);
    expect(find.text('Standard Cashier handoff'), findsOneWidget);
    expect(
      find.text('Mode is healthy and ready for operator handoff.'),
      findsOneWidget,
    );
    expect(find.text('Status | Ready'), findsOneWidget);
    expect(find.text('Warnings | Clear'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Copy'));
    await tester.pumpAndSettle();

    expect(copiedText, contains('Kaysir POS diagnostics handoff'));
    expect(copiedText, contains('- Mode: Standard Cashier (standard_cashier)'));
    expect(find.text('Diagnostics handoff copied'), findsOneWidget);
  });

  testWidgets('diagnostics handoff card previews attention items', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            child: POSDiagnosticsHandoffCard(
              summary: _summary(
                severity: POSDiagnosticsHandoffSeverity.attention,
                headline: 'Review 1 activity event before rollout.',
                activityAttentionCount: 1,
                attentionItems: const ['1 recent activity event needs review.'],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Needs review'), findsOneWidget);
    expect(find.text('1 recent activity event needs review.'), findsOneWidget);
    expect(find.text('Attention | 1 event'), findsOneWidget);
  });

  testWidgets('diagnostics handoff card tolerates missing context facts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            child: POSDiagnosticsHandoffCard(
              summary: _summary(title: '', facts: const []),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Diagnostics handoff'), findsOneWidget);
    expect(find.text('Not supplied'), findsNWidgets(4));
  });

  testWidgets('diagnostics handoff panel includes switch action history', (
    tester,
  ) async {
    String? copiedText;
    final historyNotifier = POSSwitchActionHistoryNotifier(
      clock: () => DateTime(2026, 6, 1, 12),
    )..record(
      const POSSwitchActionResult.blocked(
        kind: POSSwitchActionKind.runtimePack,
        targetId: 'no_payment_pack',
        targetLabel: 'No Payment Pack',
        reason: 'Finish current order first',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          posSwitchActionHistoryProvider.overrideWith((ref) => historyNotifier),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 720,
              child: POSDiagnosticsHandoffPanel(
                diagnostics: _diagnostics(),
                onCopy: (text) async {
                  copiedText = text;
                },
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Switches | 1 attempt'), findsOneWidget);
    expect(find.text('Attention | 1 event'), findsOneWidget);
    expect(find.text('1 recent activity event needs review.'), findsOneWidget);
    expect(
      find.text(
        'Blocked Runtime pack: No Payment Pack - Finish current order first.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Copy'));
    await tester.pumpAndSettle();

    expect(copiedText, contains('- Switch attempts: 1 attempt'));
    expect(copiedText, contains('- Attention: 1 event'));
    expect(
      copiedText,
      contains(
        '- Blocked Runtime pack: No Payment Pack - Finish current order first.',
      ),
    );
  });

  testWidgets('diagnostics handoff panel includes switch review activity', (
    tester,
  ) async {
    String? copiedText;
    final historyNotifier = POSSwitchActionHistoryNotifier(
      clock: () => DateTime(2026, 6, 1, 12),
    )..record(
      const POSSwitchActionResult.cancelled(
        kind: POSSwitchActionKind.commerceChannel,
        targetId: 'web_store',
        targetLabel: 'Web store',
        reason: 'Keep current order?',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          posSwitchActionHistoryProvider.overrideWith((ref) => historyNotifier),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 720,
              child: POSDiagnosticsHandoffPanel(
                diagnostics: _diagnostics(),
                onCopy: (text) async {
                  copiedText = text;
                },
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Review | 1 event'), findsOneWidget);
    expect(find.text('Attention | Clear'), findsOneWidget);
    expect(
      find.text('1 recent activity review item should be checked.'),
      findsOneWidget,
    );
    expect(
      find.text('Cancelled Commerce channel: Web store - Keep current order?'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Copy'));
    await tester.pumpAndSettle();

    expect(copiedText, contains('- Review: 1 event'));
    expect(copiedText, contains('- Attention: clear'));
    expect(
      copiedText,
      contains('- Cancelled Commerce channel: Web store - Keep current order?'),
    );
  });
}

POSDiagnosticsHandoffSummary _summary({
  POSDiagnosticsHandoffSeverity severity = POSDiagnosticsHandoffSeverity.ready,
  String title = 'Standard Cashier handoff',
  String headline = 'Mode is healthy and ready for operator handoff.',
  int activityAttentionCount = 0,
  List<POSDiagnosticsHandoffMetric> facts = const [
    POSDiagnosticsHandoffMetric(
      label: 'Mode',
      value: 'Standard Cashier (standard_cashier)',
    ),
    POSDiagnosticsHandoffMetric(label: 'Layout', value: 'Auto / Counter'),
    POSDiagnosticsHandoffMetric(label: 'Channel', value: 'In-store'),
  ],
  List<String> attentionItems = const [],
}) {
  return POSDiagnosticsHandoffSummary(
    severity: severity,
    title: title,
    headline: headline,
    statusLabel: 'Ready',
    configurationWarningCount: 0,
    activityCount: activityAttentionCount,
    activityAttentionCount: activityAttentionCount,
    metrics: [
      const POSDiagnosticsHandoffMetric(label: 'Status', value: 'Ready'),
      const POSDiagnosticsHandoffMetric(label: 'Warnings', value: 'Clear'),
      POSDiagnosticsHandoffMetric(
        label: 'Activity',
        value: activityAttentionCount == 0 ? 'No events' : '1 event',
      ),
      POSDiagnosticsHandoffMetric(
        label: 'Attention',
        value: activityAttentionCount == 0 ? 'Clear' : '1 event',
      ),
    ],
    facts: facts,
    attentionItems: attentionItems,
  );
}

POSExperienceDiagnostics _diagnostics() {
  return POSExperienceDiagnostics.from(
    resolution: defaultPOSExperienceRegistry.resolveDetailed(
      defaultPOSExperience.id,
    ),
    viewportWidth: 1280,
    layoutPreference: POSLayoutPreference.auto,
    resolvedLayout: POSLayoutStrategy.counter,
    registryIssues: const [],
    runtimePackResolution: POSProductRuntimePackResolution(
      requestedId: defaultPOSProductRuntimePack.id,
      pack: defaultPOSProductRuntimePack,
      usedFallback: false,
    ),
    commerceChannel: defaultPOSCommerceChannelRegistry.channelForId('in_store'),
  );
}
