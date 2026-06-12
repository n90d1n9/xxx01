import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_diagnostics_activity.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_diagnostics_activity_insight.dart';

void main() {
  test('diagnostics activity insight prioritizes attention events', () {
    final insight = POSDiagnosticsActivityInsight.fromSnapshot(
      POSDiagnosticsActivitySnapshot(
        entries: [
          POSDiagnosticsActivityEntry(
            id: 'review_1',
            source: POSDiagnosticsActivitySource.switchAction,
            occurredAt: DateTime(2026, 6, 1, 12),
            title: 'Cancelled Commerce channel: Web store',
            detail: 'Commerce channel switch cancelled.',
            severity: POSDiagnosticsActivitySeverity.review,
            supportSummary:
                'Cancelled Commerce channel: Web store - Keep current order?',
          ),
          POSDiagnosticsActivityEntry(
            id: 'attention_1',
            source: POSDiagnosticsActivitySource.orderSync,
            occurredAt: DateTime(2026, 6, 1, 11),
            title: 'Order #123456 failed',
            detail: 'Network down',
            requiresAttention: true,
            supportSummary: 'Order #123456 failed - Network down.',
          ),
        ],
      ),
    );

    expect(insight.severity, POSDiagnosticsActivitySeverity.attention);
    expect(insight.eventCount, 2);
    expect(insight.attentionCount, 1);
    expect(insight.reviewCount, 1);
    expect(insight.summaryLabel, '2 events, 1 attention, 1 review');
    expect(insight.headline, 'Activity needs attention');
    expect(insight.detail, 'Order #123456 failed - Network down.');
    expect(insight.nextStep, 'Resolve attention events before rollout.');
    expect(insight.referenceEntry?.id, 'attention_1');
  });

  test('diagnostics activity insight surfaces review-only activity', () {
    final insight = POSDiagnosticsActivityInsight.fromSnapshot(
      POSDiagnosticsActivitySnapshot(
        entries: [
          POSDiagnosticsActivityEntry(
            id: 'review_1',
            source: POSDiagnosticsActivitySource.switchAction,
            occurredAt: DateTime(2026, 6, 1, 12),
            title: 'Cancelled Commerce channel: Web store',
            detail: 'Commerce channel switch cancelled.',
            severity: POSDiagnosticsActivitySeverity.review,
            supportSummary:
                'Cancelled Commerce channel: Web store - Keep current order?',
          ),
        ],
      ),
    );

    expect(insight.severity, POSDiagnosticsActivitySeverity.review);
    expect(insight.summaryLabel, '1 event, 1 review');
    expect(insight.headline, 'Activity review recommended');
    expect(
      insight.detail,
      'Cancelled Commerce channel: Web store - Keep current order?',
    );
    expect(insight.nextStep, 'Confirm review events before rollout.');
  });

  test('diagnostics activity insight reports healthy activity', () {
    final insight = POSDiagnosticsActivityInsight.fromSnapshot(
      POSDiagnosticsActivitySnapshot(
        entries: [
          POSDiagnosticsActivityEntry(
            id: 'ready_1',
            source: POSDiagnosticsActivitySource.channelSwitch,
            occurredAt: DateTime(2026, 6, 1, 12),
            title: 'Switched to Delivery app',
            detail: 'Checkout layout.',
          ),
        ],
      ),
    );

    expect(insight.severity, POSDiagnosticsActivitySeverity.ready);
    expect(insight.summaryLabel, '1 event');
    expect(insight.headline, 'Activity is healthy');
    expect(insight.detail, 'All recorded POS activity is clear.');
    expect(insight.nextStep, 'Continue monitoring POS activity.');
  });
}
