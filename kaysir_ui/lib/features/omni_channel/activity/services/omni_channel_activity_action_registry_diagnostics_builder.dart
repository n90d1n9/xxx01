import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_action.dart';
import '../models/omni_channel_activity_registry_diagnostics.dart';
import '../models/omni_channel_activity_registry_issue.dart';
import 'omni_channel_activity_contributor_registration_diagnostics_builder.dart';

/// Action-focused registry diagnostics derived from registered contributors.
class OmniChannelActivityActionRegistryDiagnosticsSnapshot {
  final List<OmniChannelActivityActionContributorDiagnostic> contributors;
  final List<OmniChannelActivityActionContributorRegistrationIssue>
  contributorRegistrationIssues;
  final List<OmniChannelActivityActionDuplicateDiagnostic> duplicateActions;
  final List<OmniChannelActivityActionDiagnostic> actions;

  OmniChannelActivityActionRegistryDiagnosticsSnapshot({
    Iterable<OmniChannelActivityActionContributorDiagnostic> contributors =
        const [],
    Iterable<OmniChannelActivityActionContributorRegistrationIssue>
        contributorRegistrationIssues =
        const [],
    Iterable<OmniChannelActivityActionDuplicateDiagnostic> duplicateActions =
        const [],
    Iterable<OmniChannelActivityActionDiagnostic> actions = const [],
  }) : contributors = List.unmodifiable(contributors),
       contributorRegistrationIssues = List.unmodifiable(
         contributorRegistrationIssues,
       ),
       duplicateActions = List.unmodifiable(duplicateActions),
       actions = List.unmodifiable(actions);
}

/// Builds action contributor diagnostics for the activity registry.
class OmniChannelActivityActionRegistryDiagnosticsBuilder {
  final OmniChannelActivityContributorRegistrationDiagnosticsBuilder
  contributorRegistrationBuilder;

  const OmniChannelActivityActionRegistryDiagnosticsBuilder({
    this.contributorRegistrationBuilder =
        const OmniChannelActivityContributorRegistrationDiagnosticsBuilder(),
  });

  OmniChannelActivityActionRegistryDiagnosticsSnapshot build({
    required OmniChannelActivityFeed feed,
    required OmniChannelActivityActionRegistry actionRegistry,
  }) {
    final contributorDescriptors =
        actionRegistry.resolvedContributorDescriptors;
    final contributorRegistrationIssues = contributorRegistrationBuilder.build(
      contributorDescriptors,
    );
    final actionCounters = <String, _ActionCounter>{};
    final duplicateActionCounters = <String, _DuplicateActionCounter>{};
    final contributorDiagnostics =
        <OmniChannelActivityActionContributorDiagnostic>[];

    for (
      var contributorIndex = 0;
      contributorIndex < actionRegistry.contributors.length;
      contributorIndex++
    ) {
      final contributor = actionRegistry.contributors[contributorIndex];
      final descriptor = contributorDescriptors[contributorIndex];
      final actionIdentities = <String>{};
      var matchedEntryCount = 0;

      for (final entry in feed.entries) {
        final actions = contributor(entry).toList(growable: false);
        if (actions.isEmpty) continue;

        matchedEntryCount += 1;
        actionIdentities.addAll(actions.map((action) => action.identity));
      }

      contributorDiagnostics.add(
        OmniChannelActivityActionContributorDiagnostic(
          id: descriptor.id,
          label: descriptor.label,
          description: descriptor.description,
          matchedEntryCount: matchedEntryCount,
          actionCount: actionIdentities.length,
        ),
      );
    }

    for (final entry in feed.entries) {
      final emissionsByIdentity = <String, List<_ContributorActionEmission>>{};

      for (
        var contributorIndex = 0;
        contributorIndex < actionRegistry.contributors.length;
        contributorIndex++
      ) {
        final contributor = actionRegistry.contributors[contributorIndex];
        final descriptor = contributorDescriptors[contributorIndex];

        for (final action in contributor(entry)) {
          emissionsByIdentity.update(
            action.identity,
            (emissions) => [
              ...emissions,
              _ContributorActionEmission(
                contributorIndex: contributorIndex,
                descriptor: descriptor,
                action: action,
              ),
            ],
            ifAbsent:
                () => [
                  _ContributorActionEmission(
                    contributorIndex: contributorIndex,
                    descriptor: descriptor,
                    action: action,
                  ),
                ],
          );
        }
      }

      for (final emissionGroup in emissionsByIdentity.entries) {
        if (_uniqueContributorIndexes(emissionGroup.value).length < 2) {
          continue;
        }

        duplicateActionCounters.update(
          emissionGroup.key,
          (counter) => counter.withEntry(emissionGroup.value),
          ifAbsent:
              () => _DuplicateActionCounter.fromEntry(
                identity: emissionGroup.key,
                emissions: emissionGroup.value,
              ),
        );
      }
    }

    for (final entry in feed.entries) {
      final actionSet = actionRegistry.actionSetFor(entry);
      final primaryIdentity = actionSet.primary?.identity;

      for (final action in actionSet.actions) {
        actionCounters.update(
          action.identity,
          (counter) => counter.withAction(
            action,
            isPrimary: action.identity == primaryIdentity,
          ),
          ifAbsent:
              () => _ActionCounter.fromAction(
                action,
                isPrimary: action.identity == primaryIdentity,
              ),
        );
      }
    }

    final actionDiagnostics =
        actionCounters.values.map((counter) => counter.toDiagnostic()).toList()
          ..sort(_compareActionDiagnostics);
    final duplicateActionDiagnostics =
        duplicateActionCounters.values
            .map((counter) => counter.toDiagnostic())
            .toList()
          ..sort(_compareDuplicateActionDiagnostics);

    return OmniChannelActivityActionRegistryDiagnosticsSnapshot(
      contributors: contributorDiagnostics,
      contributorRegistrationIssues: contributorRegistrationIssues,
      duplicateActions: duplicateActionDiagnostics,
      actions: actionDiagnostics,
    );
  }
}

/// One action emitted by one contributor while building diagnostics.
class _ContributorActionEmission {
  final int contributorIndex;
  final OmniChannelActivityActionContributorDescriptor descriptor;
  final OmniChannelActivityAction action;

  const _ContributorActionEmission({
    required this.contributorIndex,
    required this.descriptor,
    required this.action,
  });
}

/// Accumulates duplicate action identity diagnostics across feed entries.
class _DuplicateActionCounter {
  final String identity;
  final String label;
  final List<String> contributorLabels;
  final List<int> contributorIndexes;
  final int eventCount;

  _DuplicateActionCounter({
    required this.identity,
    required this.label,
    Iterable<String> contributorLabels = const [],
    Iterable<int> contributorIndexes = const [],
    required this.eventCount,
  }) : contributorLabels = List.unmodifiable(contributorLabels),
       contributorIndexes = List.unmodifiable(contributorIndexes);

  factory _DuplicateActionCounter.fromEntry({
    required String identity,
    required List<_ContributorActionEmission> emissions,
  }) {
    return _DuplicateActionCounter(
      identity: identity,
      label: emissions.first.action.label,
      contributorLabels: _uniqueContributorLabels(emissions),
      contributorIndexes: _uniqueContributorIndexes(emissions),
      eventCount: 1,
    );
  }

  _DuplicateActionCounter withEntry(
    List<_ContributorActionEmission> emissions,
  ) {
    return _DuplicateActionCounter(
      identity: identity,
      label: label,
      contributorLabels: _mergeUniqueLabels([
        ...contributorLabels,
        ..._uniqueContributorLabels(emissions),
      ]),
      contributorIndexes: _mergeUniqueContributorIndexes([
        ...contributorIndexes,
        ..._uniqueContributorIndexes(emissions),
      ]),
      eventCount: eventCount + 1,
    );
  }

  OmniChannelActivityActionDuplicateDiagnostic toDiagnostic() {
    return OmniChannelActivityActionDuplicateDiagnostic(
      identity: identity,
      label: label,
      contributorLabels: contributorLabels,
      contributorCount: contributorIndexes.length,
      eventCount: eventCount,
    );
  }
}

/// Accumulates resolved action diagnostics before exposing immutable summaries.
class _ActionCounter {
  final String identity;
  final String label;
  final String location;
  final OmniChannelActivityActionIntent intent;
  final int priority;
  final int eventCount;
  final int primaryEventCount;
  final int enabledEventCount;
  final int disabledEventCount;

  const _ActionCounter({
    required this.identity,
    required this.label,
    required this.location,
    required this.intent,
    required this.priority,
    required this.eventCount,
    required this.primaryEventCount,
    required this.enabledEventCount,
    required this.disabledEventCount,
  });

  factory _ActionCounter.fromAction(
    OmniChannelActivityAction action, {
    required bool isPrimary,
  }) {
    return _ActionCounter(
      identity: action.identity,
      label: action.label,
      location: action.location,
      intent: action.intent,
      priority: action.priority,
      eventCount: 1,
      primaryEventCount: isPrimary ? 1 : 0,
      enabledEventCount: action.isEnabled ? 1 : 0,
      disabledEventCount: action.isEnabled ? 0 : 1,
    );
  }

  _ActionCounter withAction(
    OmniChannelActivityAction action, {
    required bool isPrimary,
  }) {
    return _ActionCounter(
      identity: identity,
      label: label,
      location: location,
      intent: intent,
      priority: priority < action.priority ? priority : action.priority,
      eventCount: eventCount + 1,
      primaryEventCount: primaryEventCount + (isPrimary ? 1 : 0),
      enabledEventCount: enabledEventCount + (action.isEnabled ? 1 : 0),
      disabledEventCount: disabledEventCount + (action.isEnabled ? 0 : 1),
    );
  }

  OmniChannelActivityActionDiagnostic toDiagnostic() {
    return OmniChannelActivityActionDiagnostic(
      identity: identity,
      label: label,
      location: location,
      intent: intent,
      priority: priority,
      eventCount: eventCount,
      primaryEventCount: primaryEventCount,
      enabledEventCount: enabledEventCount,
      disabledEventCount: disabledEventCount,
    );
  }
}

int _compareActionDiagnostics(
  OmniChannelActivityActionDiagnostic left,
  OmniChannelActivityActionDiagnostic right,
) {
  final priorityComparison = left.priority.compareTo(right.priority);
  if (priorityComparison != 0) return priorityComparison;

  final eventComparison = right.eventCount.compareTo(left.eventCount);
  if (eventComparison != 0) return eventComparison;

  return left.label.compareTo(right.label);
}

int _compareDuplicateActionDiagnostics(
  OmniChannelActivityActionDuplicateDiagnostic left,
  OmniChannelActivityActionDuplicateDiagnostic right,
) {
  final eventComparison = right.eventCount.compareTo(left.eventCount);
  if (eventComparison != 0) return eventComparison;

  final contributorComparison = right.contributorCount.compareTo(
    left.contributorCount,
  );
  if (contributorComparison != 0) return contributorComparison;

  return left.label.compareTo(right.label);
}

Set<int> _uniqueContributorIndexes(
  Iterable<_ContributorActionEmission> emissions,
) {
  return {for (final emission in emissions) emission.contributorIndex};
}

List<int> _mergeUniqueContributorIndexes(Iterable<int> indexes) {
  final result = indexes.toSet().toList()..sort();

  return result;
}

List<String> _uniqueContributorLabels(
  Iterable<_ContributorActionEmission> emissions,
) {
  return _mergeUniqueLabels(
    emissions.map((emission) => emission.descriptor.label),
  );
}

List<String> _mergeUniqueLabels(Iterable<String> labels) {
  final seen = <String>{};
  final result = <String>[];

  for (final label in labels) {
    final normalized = label.trim();
    if (normalized.isEmpty || !seen.add(normalized)) continue;

    result.add(normalized);
  }

  return result;
}
