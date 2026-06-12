import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_action.dart';
import '../models/omni_channel_activity_module_manifest.dart';
import '../models/omni_channel_activity_module_registry_diagnostics.dart';
import '../models/omni_channel_activity_triage.dart';

/// Module-focused registry diagnostics derived from installed manifests.
class OmniChannelActivityModuleRegistryDiagnosticsSnapshot {
  final List<OmniChannelActivityModuleDiagnostic> modules;
  final List<OmniChannelActivityModuleRegistrationIssue> registrationIssues;

  OmniChannelActivityModuleRegistryDiagnosticsSnapshot({
    Iterable<OmniChannelActivityModuleDiagnostic> modules = const [],
    Iterable<OmniChannelActivityModuleRegistrationIssue> registrationIssues =
        const [],
  }) : modules = List.unmodifiable(modules),
       registrationIssues = List.unmodifiable(registrationIssues);
}

/// Builds module manifest diagnostics for the activity registry.
class OmniChannelActivityModuleRegistryDiagnosticsBuilder {
  const OmniChannelActivityModuleRegistryDiagnosticsBuilder();

  OmniChannelActivityModuleRegistryDiagnosticsSnapshot build({
    required OmniChannelActivityFeed feed,
    required Iterable<OmniChannelActivityActionContributorDescriptor>
    actionContributorDescriptors,
    required Iterable<OmniChannelActivityTriageDimensionDefinition>
    triageDimensions,
    required Iterable<OmniChannelActivityModuleManifest> moduleManifests,
  }) {
    final manifests = moduleManifests.toList(growable: false);
    final registeredActionContributorIds =
        actionContributorDescriptors
            .map((descriptor) => descriptor.id.trim())
            .where((id) => id.isNotEmpty)
            .toSet();
    final registeredTriageDimensionKeys =
        triageDimensions
            .map((definition) => definition.dimension.key.trim())
            .where((key) => key.isNotEmpty)
            .toSet();
    final activityCountsBySource = _activityCountsBySource(feed);
    final registrationIssues = <OmniChannelActivityModuleRegistrationIssue>[];
    final manifestsById = <String, List<_ModuleManifestEntry>>{};
    final moduleDiagnostics = <OmniChannelActivityModuleDiagnostic>[];

    for (var index = 0; index < manifests.length; index++) {
      final manifest = manifests[index];
      final id = manifest.id.trim();
      final label = manifest.label.trim();

      if (id.isEmpty) {
        registrationIssues.add(
          OmniChannelActivityModuleRegistrationIssue(
            type: OmniChannelActivityModuleRegistrationIssueType.missingId,
            key: 'missing-id-$index',
            moduleIndex: index,
            labels: [_manifestLabel(index, manifest)],
            moduleCount: 1,
          ),
        );
      } else {
        manifestsById.update(
          id,
          (registeredManifests) => [
            ...registeredManifests,
            _ModuleManifestEntry(index: index, manifest: manifest),
          ],
          ifAbsent:
              () => [_ModuleManifestEntry(index: index, manifest: manifest)],
        );
      }

      if (label.isEmpty) {
        registrationIssues.add(
          OmniChannelActivityModuleRegistrationIssue(
            type: OmniChannelActivityModuleRegistrationIssueType.missingLabel,
            key: 'missing-label-$index',
            id: id,
            moduleIndex: index,
            labels: [_manifestLabel(index, manifest)],
            moduleCount: 1,
          ),
        );
      }

      if (!manifest.hasContributions) {
        registrationIssues.add(
          OmniChannelActivityModuleRegistrationIssue(
            type:
                OmniChannelActivityModuleRegistrationIssueType
                    .missingContribution,
            key: 'missing-contribution-$index',
            id: id,
            moduleIndex: index,
            labels: [_manifestLabel(index, manifest)],
            moduleCount: 1,
          ),
        );
      }

      final missingActionContributorIds = [
        for (final contributorId in manifest.actionContributorIds)
          if (!registeredActionContributorIds.contains(contributorId))
            contributorId,
      ];
      final missingTriageDimensionKeys = [
        for (final dimensionKey in manifest.triageDimensionKeys)
          if (!registeredTriageDimensionKeys.contains(dimensionKey))
            dimensionKey,
      ];

      for (final contributorId in missingActionContributorIds) {
        registrationIssues.add(
          OmniChannelActivityModuleRegistrationIssue(
            type:
                OmniChannelActivityModuleRegistrationIssueType
                    .missingActionContributor,
            key: 'missing-action-$index-$contributorId',
            id: id,
            moduleIndex: index,
            labels: [_manifestLabel(index, manifest)],
            moduleCount: 1,
            missingKey: contributorId,
          ),
        );
      }

      for (final dimensionKey in missingTriageDimensionKeys) {
        registrationIssues.add(
          OmniChannelActivityModuleRegistrationIssue(
            type:
                OmniChannelActivityModuleRegistrationIssueType
                    .missingTriageDimension,
            key: 'missing-dimension-$index-$dimensionKey',
            id: id,
            moduleIndex: index,
            labels: [_manifestLabel(index, manifest)],
            moduleCount: 1,
            missingKey: dimensionKey,
          ),
        );
      }

      moduleDiagnostics.add(
        OmniChannelActivityModuleDiagnostic(
          manifest: manifest,
          activityEventCount: _moduleActivityEventCount(
            manifest,
            activityCountsBySource,
          ),
          registeredActionContributorCount:
              manifest.actionContributorIds
                  .where(registeredActionContributorIds.contains)
                  .length,
          registeredTriageDimensionCount:
              manifest.triageDimensionKeys
                  .where(registeredTriageDimensionKeys.contains)
                  .length,
          missingActionContributorIds: missingActionContributorIds,
          missingTriageDimensionKeys: missingTriageDimensionKeys,
        ),
      );
    }

    for (final entry in manifestsById.entries) {
      if (entry.value.length < 2) continue;

      registrationIssues.add(
        OmniChannelActivityModuleRegistrationIssue(
          type: OmniChannelActivityModuleRegistrationIssueType.duplicateId,
          key: 'duplicate-id-${entry.key}',
          id: entry.key,
          labels: entry.value.map(
            (entry) => _manifestLabel(entry.index, entry.manifest),
          ),
          moduleCount: entry.value.length,
        ),
      );
    }

    moduleDiagnostics.sort(_compareModuleDiagnostics);
    registrationIssues.sort(_compareModuleRegistrationIssues);

    return OmniChannelActivityModuleRegistryDiagnosticsSnapshot(
      modules: moduleDiagnostics,
      registrationIssues: registrationIssues,
    );
  }
}

Map<String, int> _activityCountsBySource(OmniChannelActivityFeed feed) {
  final counts = <String, int>{};

  for (final entry in feed.entries) {
    final sourceId = entry.sourceId.trim();
    if (sourceId.isEmpty) continue;

    counts.update(sourceId, (count) => count + 1, ifAbsent: () => 1);
  }

  return counts;
}

int _moduleActivityEventCount(
  OmniChannelActivityModuleManifest manifest,
  Map<String, int> activityCountsBySource,
) {
  return manifest.activitySourceIds.fold(
    0,
    (total, sourceId) => total + (activityCountsBySource[sourceId] ?? 0),
  );
}

int _compareModuleDiagnostics(
  OmniChannelActivityModuleDiagnostic left,
  OmniChannelActivityModuleDiagnostic right,
) {
  final statusComparison = left.statusLabel.compareTo(right.statusLabel);
  if (statusComparison != 0) return statusComparison;

  final activityComparison = right.activityEventCount.compareTo(
    left.activityEventCount,
  );
  if (activityComparison != 0) return activityComparison;

  return left.label.compareTo(right.label);
}

int _compareModuleRegistrationIssues(
  OmniChannelActivityModuleRegistrationIssue left,
  OmniChannelActivityModuleRegistrationIssue right,
) {
  final typeComparison = left.type.index.compareTo(right.type.index);
  if (typeComparison != 0) return typeComparison;

  return left.key.compareTo(right.key);
}

String _manifestLabel(int index, OmniChannelActivityModuleManifest manifest) {
  final label = manifest.label.trim();
  if (label.isNotEmpty) return label;

  final id = manifest.id.trim();
  if (id.isNotEmpty) return id;

  return 'Module ${index + 1}';
}

/// Indexed module metadata used while validating registry contracts.
class _ModuleManifestEntry {
  final int index;
  final OmniChannelActivityModuleManifest manifest;

  const _ModuleManifestEntry({required this.index, required this.manifest});
}
