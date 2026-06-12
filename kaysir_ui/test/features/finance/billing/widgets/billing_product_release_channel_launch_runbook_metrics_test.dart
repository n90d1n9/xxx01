import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_dispatch_status.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_runbook.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_runbook_metrics.dart';

void main() {
  test('runbook metrics summarize destinations and readiness', () {
    final metrics =
        BillingProductReleaseChannelLaunchRunbookMetrics.fromRunbook(
          _runbook(),
        );

    expect(metrics.count, 4);
    expect(metrics.metricForLabel('Destinations')?.value, '2');
    expect(metrics.metricForLabel('Steps')?.value, '3');
    expect(metrics.metricForLabel('Ready')?.value, '1');
    expect(metrics.metricForLabel('Needs work')?.value, '2');
    expect(metrics.metricForLabel('Ready')?.icon, Icons.check_circle_outline);
  });

  test('runbook metrics keep empty runbooks measurable', () {
    final metrics =
        BillingProductReleaseChannelLaunchRunbookMetrics.fromRunbook(
          BillingProductReleaseChannelLaunchRunbook(),
        );

    expect(metrics.count, 4);
    expect(metrics.metricForLabel('Destinations')?.value, '0');
    expect(metrics.metricForLabel('Steps')?.value, '0');
    expect(metrics.metricForLabel('Ready')?.value, '0');
    expect(metrics.metricForLabel('Needs work')?.value, '0');
  });
}

BillingProductReleaseChannelLaunchRunbook _runbook() {
  return BillingProductReleaseChannelLaunchRunbook(
    groups: [
      BillingProductReleaseChannelLaunchRunbookGroup(
        destinationId: BillingNavigationDestinationId.invoices,
        destinationLabel: 'Invoices',
        steps: [
          _step(
            id: 'invoice-ready',
            status: BillingProductReleaseChannelLaunchDispatchStatus.route,
            isActionable: true,
          ),
          _step(
            id: 'invoice-routing',
            status: BillingProductReleaseChannelLaunchDispatchStatus.notExposed,
          ),
        ],
      ),
      BillingProductReleaseChannelLaunchRunbookGroup(
        destinationId: BillingNavigationDestinationId.diagnostics,
        destinationLabel: 'Diagnostics',
        steps: [
          _step(
            id: 'diagnostics-blocked',
            status:
                BillingProductReleaseChannelLaunchDispatchStatus
                    .blockedByRelease,
            isBlocked: true,
          ),
        ],
      ),
    ],
  );
}

BillingProductReleaseChannelLaunchRunbookStep _step({
  required String id,
  required BillingProductReleaseChannelLaunchDispatchStatus status,
  bool isActionable = false,
  bool isBlocked = false,
}) {
  return BillingProductReleaseChannelLaunchRunbookStep(
    id: id,
    title: 'Launch $id',
    detail: 'Fixture launch step.',
    destinationLabel: 'Invoices',
    callToActionLabel: 'Open invoices',
    statusLabel: status.label,
    destinationId: BillingNavigationDestinationId.invoices,
    status: status,
    isActionable: isActionable,
    isBlocked: isBlocked,
  );
}
