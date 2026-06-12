import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_diagnostics_activity.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_diagnostics_handoff.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_diagnostics.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';

void main() {
  test('diagnostics handoff summarizes a ready POS mode', () {
    final summary = POSDiagnosticsHandoffSummary.from(
      diagnostics: _diagnostics(),
      activity: POSDiagnosticsActivitySnapshot(),
    );

    expect(summary.severity, POSDiagnosticsHandoffSeverity.ready);
    expect(summary.statusLabel, 'Ready');
    expect(summary.configurationWarningCount, 0);
    expect(summary.activityCount, 0);
    expect(summary.activityAttentionCount, 0);
    expect(summary.attentionItems, isEmpty);
    expect(summary.headline, contains('ready for operator handoff'));

    final shareText = summary.toShareText();
    expect(shareText, contains('Kaysir POS diagnostics handoff'));
    expect(shareText, contains('Mode: Standard Cashier'));
    expect(shareText, contains('Pack: Kaysir Core POS'));
    expect(shareText, contains('Activity:'));
    expect(shareText, contains('- Attention: clear'));
    expect(shareText, contains('- None'));
  });

  test('diagnostics handoff includes configuration and activity attention', () {
    final summary = POSDiagnosticsHandoffSummary.from(
      diagnostics: _diagnostics(requestedExperienceId: 'missing'),
      activity: POSDiagnosticsActivitySnapshot(
        entries: [
          POSDiagnosticsActivityEntry(
            id: 'sync_1',
            source: POSDiagnosticsActivitySource.orderSync,
            occurredAt: DateTime(2026, 6, 1, 10),
            title: 'Order #123456 failed',
            detail: 'Network down',
            requiresAttention: true,
          ),
        ],
      ),
    );

    expect(summary.severity, POSDiagnosticsHandoffSeverity.attention);
    expect(summary.configurationWarningCount, 1);
    expect(summary.activityAttentionCount, 1);
    expect(summary.headline, contains('configuration warning'));
    expect(summary.headline, contains('activity event'));
    expect(
      summary.attentionItems,
      contains('POS experience "missing" is not registered'),
    );
    expect(
      summary.attentionItems,
      contains('1 recent activity event needs review.'),
    );
    expect(summary.toShareText(), contains('- Attention: 1 event'));
  });

  test('diagnostics handoff reports source-specific activity counts', () {
    final summary = POSDiagnosticsHandoffSummary.from(
      diagnostics: _diagnostics(),
      activity: POSDiagnosticsActivitySnapshot(
        entries: [
          POSDiagnosticsActivityEntry(
            id: 'switch_action_1',
            source: POSDiagnosticsActivitySource.switchAction,
            occurredAt: DateTime(2026, 6, 1, 11),
            title: 'Blocked Runtime pack: No Payment Pack',
            detail: 'Runtime pack switch blocked.',
            requiresAttention: true,
            supportSummary:
                'Blocked Runtime pack: No Payment Pack - Finish current order first.',
          ),
          POSDiagnosticsActivityEntry(
            id: 'channel_switch_1',
            source: POSDiagnosticsActivitySource.channelSwitch,
            occurredAt: DateTime(2026, 6, 1, 10),
            title: 'Switched to Web store',
            detail: 'Checkout layout.',
          ),
          POSDiagnosticsActivityEntry(
            id: 'sync_1',
            source: POSDiagnosticsActivitySource.orderSync,
            occurredAt: DateTime(2026, 6, 1, 9),
            title: 'Order #123456 synced',
            detail: 'Saved upstream.',
          ),
        ],
      ),
    );

    expect(summary.activitySwitchActionCount, 1);
    expect(summary.activityChannelSwitchCount, 1);
    expect(summary.activityOrderSyncCount, 1);
    expect(
      summary.attentionItems,
      contains(
        'Blocked Runtime pack: No Payment Pack - Finish current order first.',
      ),
    );
    expect(
      summary.metrics.singleWhere((metric) => metric.label == 'Switches').value,
      '1 attempt',
    );
    expect(summary.toShareText(), contains('- Switch attempts: 1 attempt'));
    expect(summary.toShareText(), contains('- Channel changes: 1 change'));
    expect(summary.toShareText(), contains('- Order sync: 1 event'));
  });

  test('diagnostics handoff surfaces review-level switch activity', () {
    final summary = POSDiagnosticsHandoffSummary.from(
      diagnostics: _diagnostics(),
      activity: POSDiagnosticsActivitySnapshot(
        entries: [
          POSDiagnosticsActivityEntry(
            id: 'switch_action_1',
            source: POSDiagnosticsActivitySource.switchAction,
            occurredAt: DateTime(2026, 6, 1, 11),
            title: 'Cancelled Commerce channel: Web store',
            detail: 'Commerce channel switch cancelled: Keep current order?',
            severity: POSDiagnosticsActivitySeverity.review,
            supportSummary:
                'Cancelled Commerce channel: Web store - Keep current order?',
          ),
        ],
      ),
    );

    expect(summary.severity, POSDiagnosticsHandoffSeverity.review);
    expect(summary.activityAttentionCount, 0);
    expect(summary.activityReviewCount, 1);
    expect(summary.headline, 'Review 1 activity event before rollout.');
    expect(
      summary.attentionItems,
      contains('1 recent activity review item should be checked.'),
    );
    expect(
      summary.attentionItems,
      contains('Cancelled Commerce channel: Web store - Keep current order?'),
    );
    expect(
      summary.metrics.singleWhere((metric) => metric.label == 'Review').value,
      '1 event',
    );
    expect(summary.toShareText(), contains('- Review: 1 event'));
    expect(summary.toShareText(), contains('- Attention: clear'));
  });
}

POSExperienceDiagnostics _diagnostics({String? requestedExperienceId}) {
  return POSExperienceDiagnostics.from(
    resolution: defaultPOSExperienceRegistry.resolveDetailed(
      requestedExperienceId ?? defaultPOSExperience.id,
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
