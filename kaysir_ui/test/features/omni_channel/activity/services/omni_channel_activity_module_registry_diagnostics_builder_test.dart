import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_module_manifest.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_module_registry_diagnostics.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_triage.dart';
import 'package:kaysir/features/omni_channel/activity/services/omni_channel_activity_module_registry_diagnostics_builder.dart';

void main() {
  test('module registry diagnostics summarize manifest coverage', () {
    final diagnostics =
        const OmniChannelActivityModuleRegistryDiagnosticsBuilder().build(
          feed: _feed(),
          actionContributorDescriptors: const [
            OmniChannelActivityActionContributorDescriptor(
              id: 'point_of_sales',
              label: 'Point of sale actions',
            ),
            OmniChannelActivityActionContributorDescriptor(
              id: 'ecommerce',
              label: 'Ecommerce actions',
            ),
          ],
          triageDimensions:
              defaultOmniChannelActivityTriageDimensionDefinitions,
          moduleManifests: [_posManifest(), _ecommerceManifest()],
        );

    expect(diagnostics.registrationIssues, isEmpty);
    expect(diagnostics.modules.map((module) => module.id), [
      'ecommerce',
      'point_of_sales',
    ]);
    expect(diagnostics.modules.first.activityEventCount, 1);
    expect(diagnostics.modules.first.registeredActionContributorCount, 1);
    expect(diagnostics.modules.first.registeredTriageDimensionCount, 2);
    expect(diagnostics.modules.first.statusLabel, 'Active');
    expect(diagnostics.modules.first.isHealthy, isTrue);
  });

  test('module registry diagnostics detect missing contracts', () {
    final diagnostics =
        const OmniChannelActivityModuleRegistryDiagnosticsBuilder().build(
          feed: _feed(),
          actionContributorDescriptors: const [
            OmniChannelActivityActionContributorDescriptor(
              id: 'ecommerce',
              label: 'Ecommerce actions',
            ),
          ],
          triageDimensions:
              defaultOmniChannelActivityTriageDimensionDefinitions,
          moduleManifests: [
            OmniChannelActivityModuleManifest(
              id: 'marketplace',
              label: 'Marketplace',
              actionContributorIds: ['marketplace'],
              triageDimensionKeys: ['marketplace_status'],
            ),
          ],
        );

    expect(diagnostics.modules.single.statusLabel, 'Incomplete');
    expect(diagnostics.modules.single.missingActionContributorIds, [
      'marketplace',
    ]);
    expect(diagnostics.modules.single.missingTriageDimensionKeys, [
      'marketplace_status',
    ]);
    expect(diagnostics.registrationIssues.map((issue) => issue.type), [
      OmniChannelActivityModuleRegistrationIssueType.missingActionContributor,
      OmniChannelActivityModuleRegistrationIssueType.missingTriageDimension,
    ]);
    expect(
      diagnostics.registrationIssues.first.detail,
      'Marketplace declares action contributor "marketplace" but it is not '
      'registered.',
    );
  });

  test('module registry diagnostics detect duplicate and missing metadata', () {
    final diagnostics =
        const OmniChannelActivityModuleRegistryDiagnosticsBuilder().build(
          feed: OmniChannelActivityFeed(),
          actionContributorDescriptors: const [],
          triageDimensions: const [],
          moduleManifests: [
            OmniChannelActivityModuleManifest(id: '', label: ''),
            OmniChannelActivityModuleManifest(
              id: 'commerce',
              label: 'Commerce',
            ),
            OmniChannelActivityModuleManifest(id: 'commerce', label: ''),
          ],
        );

    expect(diagnostics.registrationIssues.map((issue) => issue.type), [
      OmniChannelActivityModuleRegistrationIssueType.duplicateId,
      OmniChannelActivityModuleRegistrationIssueType.missingId,
      OmniChannelActivityModuleRegistrationIssueType.missingLabel,
      OmniChannelActivityModuleRegistrationIssueType.missingLabel,
      OmniChannelActivityModuleRegistrationIssueType.missingContribution,
      OmniChannelActivityModuleRegistrationIssueType.missingContribution,
      OmniChannelActivityModuleRegistrationIssueType.missingContribution,
    ]);
    expect(diagnostics.registrationIssues.first.detail, contains('Commerce'));
    expect(diagnostics.registrationIssues[1].label, 'Module 1');
    expect(diagnostics.registrationIssues[3].label, 'commerce');
  });
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
      ),
      OmniChannelActivityEntry(
        id: 'ecommerce-review',
        kind: OmniChannelActivityKind.order,
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 9, 11),
        title: 'Web order review',
        detail: 'Courier handoff needs review.',
        severity: OmniChannelActivitySeverity.review,
      ),
    ],
  );
}

OmniChannelActivityModuleManifest _posManifest() {
  return OmniChannelActivityModuleManifest(
    id: 'point_of_sales',
    label: 'Point of sale',
    activitySourceIds: const ['point_of_sales'],
    actionContributorIds: const ['point_of_sales'],
    triageDimensionKeys: const ['source', 'channel'],
    businessModelKeys: const ['point_of_sales', 'kiosk'],
  );
}

OmniChannelActivityModuleManifest _ecommerceManifest() {
  return OmniChannelActivityModuleManifest(
    id: 'ecommerce',
    label: 'Ecommerce',
    activitySourceIds: const ['ecommerce'],
    actionContributorIds: const ['ecommerce'],
    triageDimensionKeys: const ['source', 'channel'],
    businessModelKeys: const ['ecommerce', 'marketplace'],
  );
}
