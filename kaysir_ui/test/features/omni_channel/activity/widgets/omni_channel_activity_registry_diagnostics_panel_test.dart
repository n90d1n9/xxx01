import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_filter.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_module_manifest.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_registry_diagnostics.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_triage.dart';
import 'package:kaysir/features/omni_channel/activity/widgets/omni_channel_activity_registry_diagnostics_panel.dart';

void main() {
  testWidgets('omni-channel registry diagnostics panel renders coverage', (
    tester,
  ) async {
    final diagnostics = OmniChannelActivityRegistryDiagnostics.fromFeed(
      feed: _feed(),
      actionRegistry: OmniChannelActivityActionRegistry(
        contributors: [_diagnosticActionContributor],
        contributorDescriptors: const [
          OmniChannelActivityActionContributorDescriptor(
            id: 'diagnostic_actions',
            label: 'Diagnostic actions',
            description: 'Synthetic diagnostics test actions',
          ),
        ],
      ),
      triageDimensions: defaultOmniChannelActivityTriageDimensionDefinitions,
      moduleManifests: [_posManifest(), _ecommerceManifest()],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OmniChannelActivityRegistryDiagnosticsPanel(
              diagnostics: diagnostics,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Registry diagnostics'), findsOneWidget);
    expect(find.text('3 dimensions / 1 action contributor'), findsOneWidget);
    expect(find.text('Business modules'), findsOneWidget);
    expect(find.text('Point of sale'), findsOneWidget);
    expect(find.text('Ecommerce'), findsOneWidget);
    expect(find.text('Triage dimensions'), findsOneWidget);
    expect(find.text('Action contributors'), findsOneWidget);
    expect(find.text('Action coverage'), findsOneWidget);
    expect(find.text('Source'), findsOneWidget);
    expect(find.text('Channel'), findsOneWidget);
    expect(find.text('Fulfillment'), findsOneWidget);
    expect(find.text('Diagnostic actions'), findsOneWidget);
    expect(find.text('Synthetic diagnostics test actions'), findsOneWidget);
    expect(find.text('Retry sync'), findsOneWidget);
    expect(find.text('Review order'), findsOneWidget);
    expect(find.text('1 disabled'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('omni-channel-registry-dimension-source')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('omni-channel-registry-contributor-diagnostic_actions'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('omni-channel-registry-action-review-order')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel registry diagnostics panel shows duplicates', (
    tester,
  ) async {
    final diagnostics = OmniChannelActivityRegistryDiagnostics.fromFeed(
      feed: _feed(),
      actionRegistry: OmniChannelActivityActionRegistry(
        contributors: [
          _duplicateActionContributorA,
          _duplicateActionContributorB,
        ],
        contributorDescriptors: const [
          OmniChannelActivityActionContributorDescriptor(
            id: 'module_a',
            label: 'Module A',
            description: 'First duplicate source',
          ),
          OmniChannelActivityActionContributorDescriptor(
            id: 'module_b',
            label: 'Module B',
            description: 'Second duplicate source',
          ),
        ],
      ),
      triageDimensions: defaultOmniChannelActivityTriageDimensionDefinitions,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OmniChannelActivityRegistryDiagnosticsPanel(
              diagnostics: diagnostics,
            ),
          ),
        ),
      ),
    );

    final duplicateTile = find.byKey(
      const ValueKey('omni-channel-registry-duplicate-shared-resolution'),
    );

    expect(find.text('Duplicate action identities'), findsOneWidget);
    expect(
      find.descendant(
        of: duplicateTile,
        matching: find.text('Resolve shared issue'),
      ),
      findsOneWidget,
    );
    expect(find.text('Module A / Module B'), findsOneWidget);
    expect(find.text('2 contributors'), findsOneWidget);
    expect(find.text('2 events'), findsWidgets);
    expect(duplicateTile, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'omni-channel registry diagnostics panel shows registration issues',
    (tester) async {
      final diagnostics = OmniChannelActivityRegistryDiagnostics.fromFeed(
        feed: _feed(),
        actionRegistry: OmniChannelActivityActionRegistry(
          contributors: [
            _duplicateActionContributorA,
            _duplicateActionContributorB,
          ],
          contributorDescriptors: const [
            OmniChannelActivityActionContributorDescriptor(
              id: 'shared_module',
              label: 'Module A',
              description: 'First duplicate source',
            ),
            OmniChannelActivityActionContributorDescriptor(
              id: 'shared_module',
              label: 'Module B',
              description: 'Second duplicate source',
            ),
          ],
        ),
        triageDimensions: defaultOmniChannelActivityTriageDimensionDefinitions,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OmniChannelActivityRegistryDiagnosticsPanel(
                diagnostics: diagnostics,
              ),
            ),
          ),
        ),
      );

      final issueSection = find.byKey(
        const ValueKey('omni-channel-registry-registration-issues'),
      );

      expect(find.text('Contributor registration issues'), findsOneWidget);
      expect(
        find.descendant(
          of: issueSection,
          matching: find.text('Duplicate contributor id'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: issueSection,
          matching: find.text(
            'ID "shared_module" is shared by Module A / Module B.',
          ),
        ),
        findsOneWidget,
      );
      expect(issueSection, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'omni-channel registry diagnostics panel shows duplicate dimensions',
    (tester) async {
      final diagnostics = OmniChannelActivityRegistryDiagnostics.fromFeed(
        feed: _feed(),
        actionRegistry: OmniChannelActivityActionRegistry(
          contributors: [_diagnosticActionContributor],
          contributorDescriptors: const [
            OmniChannelActivityActionContributorDescriptor(
              id: 'diagnostic_actions',
              label: 'Diagnostic actions',
              description: 'Synthetic diagnostics test actions',
            ),
          ],
        ),
        triageDimensions: [
          ...defaultOmniChannelActivityTriageDimensionDefinitions,
          _duplicateSourceTriageDefinition,
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OmniChannelActivityRegistryDiagnosticsPanel(
                diagnostics: diagnostics,
              ),
            ),
          ),
        ),
      );

      final duplicateTile = find.byKey(
        const ValueKey('omni-channel-registry-duplicate-dimension-source'),
      );

      expect(find.text('Duplicate triage dimensions'), findsOneWidget);
      expect(
        find.descendant(
          of: duplicateTile,
          matching: find.text('Source / Source copy'),
        ),
        findsOneWidget,
      );
      expect(find.text('Key: source'), findsOneWidget);
      expect(find.text('2 definitions'), findsWidgets);
      expect(duplicateTile, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

OmniChannelActivityModuleManifest _posManifest() {
  return OmniChannelActivityModuleManifest(
    id: 'point_of_sales',
    label: 'Point of sale',
    description: 'Cashier and counter events',
    activitySourceIds: const ['point_of_sales'],
    actionContributorIds: const ['diagnostic_actions'],
    triageDimensionKeys: const ['source', 'channel'],
  );
}

OmniChannelActivityModuleManifest _ecommerceManifest() {
  return OmniChannelActivityModuleManifest(
    id: 'ecommerce',
    label: 'Ecommerce',
    description: 'Online order events',
    activitySourceIds: const ['ecommerce'],
    actionContributorIds: const ['diagnostic_actions'],
    triageDimensionKeys: const ['source', 'channel'],
  );
}

OmniChannelActivityFeed _feed() {
  return OmniChannelActivityFeed(
    entries: [
      OmniChannelActivityEntry(
        id: 'pos-sync',
        kind: OmniChannelActivityKind.orderSync,
        sourceId: 'point_of_sales',
        sourceLabel: 'Point of sale',
        occurredAt: DateTime(2026, 6, 9, 12),
        title: 'POS sync failed',
        detail: 'Marketplace order failed to sync.',
        severity: OmniChannelActivitySeverity.attention,
        channelId: 'marketplace',
        channelLabel: 'Marketplace',
        orderId: 'POS-1',
      ),
      OmniChannelActivityEntry(
        id: 'ecommerce-review',
        kind: OmniChannelActivityKind.order,
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 9, 11),
        title: 'Web handoff review',
        detail: 'Courier handoff needs review.',
        severity: OmniChannelActivitySeverity.review,
        channelId: 'web_store',
        channelLabel: 'Web store',
        orderId: 'ECOM-1',
        fulfillmentModeKey: 'delivery',
        fulfillmentModeLabel: 'Delivery',
      ),
    ],
  );
}

Iterable<OmniChannelActivityAction> _diagnosticActionContributor(
  OmniChannelActivityEntry entry,
) sync* {
  if (entry.requiresAttention) {
    yield const OmniChannelActivityAction(
      id: 'retry-sync',
      label: 'Retry sync',
      location: '/cashier',
      tooltip: 'Retry failed sync',
      intent: OmniChannelActivityActionIntent.retry,
      enabled: false,
      disabledReason: 'Sync is already running.',
    );
  }

  yield const OmniChannelActivityAction(
    id: 'review-order',
    label: 'Review order',
    location: '/commerce/orders',
    tooltip: 'Review order workspace',
    intent: OmniChannelActivityActionIntent.review,
    priority: 20,
  );
}

Iterable<OmniChannelActivityAction> _duplicateActionContributorA(
  OmniChannelActivityEntry entry,
) sync* {
  yield const OmniChannelActivityAction(
    id: 'shared-resolution',
    label: 'Resolve shared issue',
    location: '/module-a/resolve',
    tooltip: 'Resolve from module A',
    intent: OmniChannelActivityActionIntent.review,
  );
}

Iterable<OmniChannelActivityAction> _duplicateActionContributorB(
  OmniChannelActivityEntry entry,
) sync* {
  yield const OmniChannelActivityAction(
    id: 'shared-resolution',
    label: 'Resolve shared issue',
    location: '/module-b/resolve',
    tooltip: 'Resolve from module B',
    intent: OmniChannelActivityActionIntent.review,
    priority: 10,
  );
}

final _duplicateSourceTriageDefinition =
    OmniChannelActivityTriageDimensionDefinition(
      dimension: const OmniChannelActivityTriageDimension(
        key: OmniChannelActivityTriageDimension.sourceKey,
        label: 'Source copy',
        sortOrder: 99,
      ),
      resolve:
          (entry) => OmniChannelActivityTriageValue(
            id: entry.sourceId,
            label: entry.sourceLabel,
          ),
      applyFilter:
          ({
            required OmniChannelActivityFilter baseFilter,
            required String id,
            required OmniChannelActivityFilterStatus status,
          }) => baseFilter.copyWith(status: status, sourceId: id),
      isSelected:
          ({
            required OmniChannelActivityFilter filter,
            required String id,
            required OmniChannelActivityFilterStatus status,
          }) => filter.status == status && filter.sourceId == id,
    );
