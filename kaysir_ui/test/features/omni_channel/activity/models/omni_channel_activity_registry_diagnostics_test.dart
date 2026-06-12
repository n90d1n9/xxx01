import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_filter.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_module_manifest.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_registry_diagnostics.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_registry_issue.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_triage.dart';

void main() {
  test(
    'omni-channel registry diagnostics summarizes dimensions and actions',
    () {
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

      expect(diagnostics.entryCount, 2);
      expect(diagnostics.moduleCount, 2);
      expect(diagnostics.moduleSummaryLabel, '2 modules / 2 ready');
      expect(diagnostics.activeModuleCount, 2);
      expect(diagnostics.readyModuleCount, 2);
      expect(diagnostics.hasModuleRegistrationIssues, isFalse);
      expect(diagnostics.moduleRegistrationIssues, isEmpty);
      expect(diagnostics.modules.map((module) => module.id), [
        'ecommerce',
        'point_of_sales',
      ]);
      expect(diagnostics.actionContributorCount, 1);
      expect(diagnostics.summaryLabel, '3 dimensions / 1 action contributor');
      expect(diagnostics.activeDimensionCount, 3);
      expect(diagnostics.activeActionContributorCount, 1);
      expect(diagnostics.activeActionCount, 2);
      expect(diagnostics.duplicateActionCount, 0);
      expect(diagnostics.hasDuplicateActions, isFalse);
      expect(diagnostics.duplicateActions, isEmpty);
      expect(diagnostics.duplicateDimensionCount, 0);
      expect(diagnostics.hasDuplicateDimensions, isFalse);
      expect(diagnostics.duplicateDimensions, isEmpty);
      expect(diagnostics.contributorRegistrationIssueCount, 0);
      expect(diagnostics.hasContributorRegistrationIssues, isFalse);
      expect(diagnostics.contributorRegistrationIssues, isEmpty);
      expect(diagnostics.enabledActionEventCount, 2);
      expect(diagnostics.disabledActionEventCount, 1);
      expect(diagnostics.actionContributors.single.id, 'diagnostic_actions');
      expect(diagnostics.actionContributors.single.label, 'Diagnostic actions');
      expect(diagnostics.actionContributors.single.description, isNotEmpty);
      expect(diagnostics.actionContributors.single.matchedEntryCount, 2);
      expect(diagnostics.actionContributors.single.actionCount, 2);

      final source = diagnostics.triageDimensions.first;
      expect(source.dimension, OmniChannelActivityTriageDimension.source);
      expect(source.queueCount, 2);
      expect(source.attentionCount, 1);
      expect(source.reviewCount, 1);
      expect(source.topQueueLabel, 'Point of sale');

      expect(diagnostics.actions.map((action) => action.identity), [
        'retry-sync',
        'review-order',
      ]);
      expect(diagnostics.actions.first.disabledEventCount, 1);
      expect(diagnostics.actions.first.primaryEventCount, 1);
      expect(diagnostics.actions.last.eventCount, 2);
      expect(diagnostics.actions.last.primaryEventCount, 1);
    },
  );

  test('omni-channel registry diagnostics detects duplicate actions', () {
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

    expect(diagnostics.hasDuplicateActions, isTrue);
    expect(diagnostics.duplicateActionCount, 1);

    final duplicate = diagnostics.duplicateActions.single;
    expect(duplicate.identity, 'shared-resolution');
    expect(duplicate.label, 'Resolve shared issue');
    expect(duplicate.contributorLabels, ['Module A', 'Module B']);
    expect(duplicate.contributorCount, 2);
    expect(duplicate.eventCount, 2);
    expect(duplicate.contributorLabel, 'Module A / Module B');
  });

  test(
    'omni-channel registry diagnostics reports duplicate contributor ids',
    () {
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

      expect(diagnostics.hasContributorRegistrationIssues, isTrue);
      expect(diagnostics.contributorRegistrationIssueCount, 1);

      final issue = diagnostics.contributorRegistrationIssues.single;
      expect(
        issue.type,
        OmniChannelActivityActionContributorRegistrationIssueType.duplicateId,
      );
      expect(issue.id, 'shared_module');
      expect(issue.labels, ['Module A', 'Module B']);
      expect(issue.contributorCount, 2);
      expect(issue.title, 'Duplicate contributor id');
      expect(
        issue.detail,
        'ID "shared_module" is shared by Module A / Module B.',
      );

      expect(diagnostics.hasDuplicateActions, isTrue);
      expect(diagnostics.duplicateActions.single.contributorCount, 2);
    },
  );

  test('omni-channel registry diagnostics detects duplicate dimensions', () {
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

    expect(diagnostics.hasDuplicateDimensions, isTrue);
    expect(diagnostics.duplicateDimensionCount, 1);
    expect(
      diagnostics.triageDimensions
          .where(
            (dimension) =>
                dimension.dimension.key ==
                OmniChannelActivityTriageDimension.sourceKey,
          )
          .length,
      1,
    );

    final duplicate = diagnostics.duplicateDimensions.single;
    expect(duplicate.key, OmniChannelActivityTriageDimension.sourceKey);
    expect(duplicate.labels, ['Source', 'Source copy']);
    expect(duplicate.label, 'Source / Source copy');
    expect(duplicate.definitionCount, 2);
  });
}

OmniChannelActivityModuleManifest _posManifest() {
  return OmniChannelActivityModuleManifest(
    id: 'point_of_sales',
    label: 'Point of sale',
    activitySourceIds: const ['point_of_sales'],
    triageDimensionKeys: const ['source', 'channel'],
  );
}

OmniChannelActivityModuleManifest _ecommerceManifest() {
  return OmniChannelActivityModuleManifest(
    id: 'ecommerce',
    label: 'Ecommerce',
    activitySourceIds: const ['ecommerce'],
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
