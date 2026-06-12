import '../models/omni_channel_activity_action.dart';
import '../models/omni_channel_activity_registry_issue.dart';

/// Builds diagnostics for action contributor registration metadata.
class OmniChannelActivityContributorRegistrationDiagnosticsBuilder {
  const OmniChannelActivityContributorRegistrationDiagnosticsBuilder();

  List<OmniChannelActivityActionContributorRegistrationIssue> build(
    Iterable<OmniChannelActivityActionContributorDescriptor> descriptors,
  ) {
    final resolvedDescriptors = descriptors.toList(growable: false);
    final issues = <OmniChannelActivityActionContributorRegistrationIssue>[];
    final descriptorsById = <String, List<_ContributorDescriptorEntry>>{};

    for (var index = 0; index < resolvedDescriptors.length; index++) {
      final descriptor = resolvedDescriptors[index];
      final id = descriptor.id.trim();
      final label = descriptor.label.trim();

      if (id.isEmpty) {
        issues.add(
          OmniChannelActivityActionContributorRegistrationIssue(
            type:
                OmniChannelActivityActionContributorRegistrationIssueType
                    .missingId,
            key: 'missing-id-$index',
            contributorIndex: index,
            labels: [_descriptorLabel(index, descriptor)],
            contributorCount: 1,
          ),
        );
      } else {
        descriptorsById.update(
          id,
          (registeredDescriptors) => [
            ...registeredDescriptors,
            _ContributorDescriptorEntry(index: index, descriptor: descriptor),
          ],
          ifAbsent:
              () => [
                _ContributorDescriptorEntry(
                  index: index,
                  descriptor: descriptor,
                ),
              ],
        );
      }

      if (label.isEmpty) {
        issues.add(
          OmniChannelActivityActionContributorRegistrationIssue(
            type:
                OmniChannelActivityActionContributorRegistrationIssueType
                    .missingLabel,
            key: 'missing-label-$index',
            id: id,
            contributorIndex: index,
            labels: [_descriptorLabel(index, descriptor)],
            contributorCount: 1,
          ),
        );
      }
    }

    for (final entry in descriptorsById.entries) {
      if (entry.value.length < 2) continue;

      issues.add(
        OmniChannelActivityActionContributorRegistrationIssue(
          type:
              OmniChannelActivityActionContributorRegistrationIssueType
                  .duplicateId,
          key: 'duplicate-id-${entry.key}',
          id: entry.key,
          labels: entry.value.map(
            (entry) => _descriptorLabel(entry.index, entry.descriptor),
          ),
          contributorCount: entry.value.length,
        ),
      );
    }

    issues.sort(_compareContributorRegistrationIssues);
    return List.unmodifiable(issues);
  }
}

int _compareContributorRegistrationIssues(
  OmniChannelActivityActionContributorRegistrationIssue left,
  OmniChannelActivityActionContributorRegistrationIssue right,
) {
  final typeComparison = left.type.index.compareTo(right.type.index);
  if (typeComparison != 0) return typeComparison;

  return left.key.compareTo(right.key);
}

String _descriptorLabel(
  int index,
  OmniChannelActivityActionContributorDescriptor descriptor,
) {
  final label = descriptor.label.trim();
  if (label.isNotEmpty) return label;

  final id = descriptor.id.trim();
  if (id.isNotEmpty) return id;

  return 'Contributor ${index + 1}';
}

/// Indexed contributor metadata used while validating registry contracts.
class _ContributorDescriptorEntry {
  final int index;
  final OmniChannelActivityActionContributorDescriptor descriptor;

  const _ContributorDescriptorEntry({
    required this.index,
    required this.descriptor,
  });
}
