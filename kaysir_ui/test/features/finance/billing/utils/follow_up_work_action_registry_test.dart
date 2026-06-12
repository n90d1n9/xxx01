import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/models/follow_up_work_item.dart';
import 'package:kaysir/features/finance/billing/utils/follow_up_work_action_registry.dart';

void main() {
  test('standard registry resolves core work-center actions', () {
    final registry = BillingFollowUpWorkActionRegistry.standard();

    final action = registry.resolve(
      _item(
        source: BillingFollowUpWorkSource.collections,
        status: BillingFollowUpWorkStatus.ready,
      ),
    );

    expect(action.destination, BillingNavigationDestinationId.invoices);
    expect(action.label, 'Open invoices');
    expect(action.canOpen, isTrue);
  });

  test('standard registry can vary labels by item status', () {
    final registry = BillingFollowUpWorkActionRegistry.standard();

    final action = registry.resolve(
      _item(
        source: BillingFollowUpWorkSource.reliefMonitoring,
        status: BillingFollowUpWorkStatus.blocked,
      ),
    );

    expect(action.destination, BillingNavigationDestinationId.policyCenter);
    expect(action.label, 'Resolve policy blocker');
  });

  test('registry supports explicit source overrides', () {
    final registry = BillingFollowUpWorkActionRegistry.standard()
        .withOverrides([
          BillingFollowUpWorkActionDefinition(
            source: BillingFollowUpWorkSource.collections,
            destination: BillingNavigationDestinationId.workCenter,
            label: 'Open receivables desk',
          ),
        ]);

    final action = registry.resolve(
      _item(source: BillingFollowUpWorkSource.collections),
    );

    expect(action.destination, BillingNavigationDestinationId.workCenter);
    expect(action.label, 'Open receivables desk');
  });

  test('registry rejects duplicate source definitions', () {
    expect(
      () => BillingFollowUpWorkActionRegistry(
        definitions: [
          BillingFollowUpWorkActionDefinition(
            source: BillingFollowUpWorkSource.collections,
            destination: BillingNavigationDestinationId.invoices,
            label: 'Open invoices',
          ),
          BillingFollowUpWorkActionDefinition(
            source: BillingFollowUpWorkSource.collections,
            destination: BillingNavigationDestinationId.diagnostics,
            label: 'Open diagnostics',
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('resolved action reports disabled states', () {
    final registry = BillingFollowUpWorkActionRegistry(
      definitions: [
        BillingFollowUpWorkActionDefinition(
          source: BillingFollowUpWorkSource.external,
          destination: BillingNavigationDestinationId.diagnostics,
          label: 'Open integration',
          enabledStatuses: {BillingFollowUpWorkStatus.ready},
          disabledReason: 'Wait for integration review.',
        ),
      ],
    );

    final action = registry.resolve(
      _item(
        source: BillingFollowUpWorkSource.external,
        status: BillingFollowUpWorkStatus.scheduled,
      ),
    );

    expect(action.canOpen, isFalse);
    expect(action.disabledReason, 'Wait for integration review.');
  });
}

BillingFollowUpWorkItem _item({
  BillingFollowUpWorkSource source = BillingFollowUpWorkSource.collections,
  BillingFollowUpWorkStatus status = BillingFollowUpWorkStatus.ready,
}) {
  return BillingFollowUpWorkItem(
    id: 'task-1',
    source: source,
    priority: BillingFollowUpWorkPriority.normal,
    status: status,
    title: 'Follow up billing work',
    description: 'Coordinate the next billing action.',
    ownerRole: 'Finance owner',
    dueInDays: 0,
  );
}
