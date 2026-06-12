import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_filter.dart';
import '../models/omni_channel_activity_registry_diagnostics.dart';
import '../models/omni_channel_activity_triage.dart';

/// Triage-focused registry diagnostics derived from registered dimensions.
class OmniChannelActivityTriageRegistryDiagnosticsSnapshot {
  final List<OmniChannelActivityTriageDimensionDuplicateDiagnostic>
  duplicateDimensions;
  final List<OmniChannelActivityTriageDimensionDiagnostic> dimensions;

  OmniChannelActivityTriageRegistryDiagnosticsSnapshot({
    Iterable<OmniChannelActivityTriageDimensionDuplicateDiagnostic>
        duplicateDimensions =
        const [],
    Iterable<OmniChannelActivityTriageDimensionDiagnostic> dimensions =
        const [],
  }) : duplicateDimensions = List.unmodifiable(duplicateDimensions),
       dimensions = List.unmodifiable(dimensions);
}

/// Builds triage dimension diagnostics for the activity registry.
class OmniChannelActivityTriageRegistryDiagnosticsBuilder {
  const OmniChannelActivityTriageRegistryDiagnosticsBuilder();

  OmniChannelActivityTriageRegistryDiagnosticsSnapshot build({
    required OmniChannelActivityFeed feed,
    required Iterable<OmniChannelActivityTriageDimensionDefinition>
    triageDimensions,
  }) {
    final registeredTriageDimensions = triageDimensions.toList(growable: false);
    final activeTriageDimensions = _uniqueDimensionDefinitions(
      registeredTriageDimensions,
    );
    final dimensionDiagnostics =
        activeTriageDimensions.map((definition) {
            final queue = feed.triageQueueFor(
              const OmniChannelActivityFilter(),
              dimensions: [definition],
              limit: null,
            );

            return OmniChannelActivityTriageDimensionDiagnostic(
              dimension: definition.dimension,
              queueCount: queue.totalGroupCount,
              attentionCount: queue.attentionCount,
              reviewCount: queue.reviewCount,
              topQueueLabel:
                  queue.groups.isEmpty ? null : queue.groups.first.label,
            );
          }).toList()
          ..sort(
            (left, right) =>
                left.dimension.sortOrder.compareTo(right.dimension.sortOrder),
          );

    return OmniChannelActivityTriageRegistryDiagnosticsSnapshot(
      duplicateDimensions: _duplicateDimensionDiagnostics(
        registeredTriageDimensions,
      ),
      dimensions: dimensionDiagnostics,
    );
  }
}

int _compareDuplicateDimensionDiagnostics(
  OmniChannelActivityTriageDimensionDuplicateDiagnostic left,
  OmniChannelActivityTriageDimensionDuplicateDiagnostic right,
) {
  final definitionComparison = right.definitionCount.compareTo(
    left.definitionCount,
  );
  if (definitionComparison != 0) return definitionComparison;

  return left.key.compareTo(right.key);
}

List<OmniChannelActivityTriageDimensionDefinition> _uniqueDimensionDefinitions(
  Iterable<OmniChannelActivityTriageDimensionDefinition> definitions,
) {
  final seenKeys = <String>{};
  final result = <OmniChannelActivityTriageDimensionDefinition>[];

  for (final definition in definitions) {
    final key = definition.dimension.key.trim();
    if (key.isEmpty || !seenKeys.add(key)) continue;

    result.add(definition);
  }

  return List.unmodifiable(result);
}

List<OmniChannelActivityTriageDimensionDuplicateDiagnostic>
_duplicateDimensionDiagnostics(
  Iterable<OmniChannelActivityTriageDimensionDefinition> definitions,
) {
  final definitionsByKey =
      <String, List<OmniChannelActivityTriageDimensionDefinition>>{};

  for (final definition in definitions) {
    final key = definition.dimension.key.trim();
    if (key.isEmpty) continue;

    definitionsByKey.update(
      key,
      (registeredDefinitions) => [...registeredDefinitions, definition],
      ifAbsent: () => [definition],
    );
  }

  final duplicates =
      definitionsByKey.entries
          .where((entry) => entry.value.length > 1)
          .map(
            (entry) => OmniChannelActivityTriageDimensionDuplicateDiagnostic(
              key: entry.key,
              labels: _dimensionLabels(entry.key, entry.value),
              definitionCount: entry.value.length,
            ),
          )
          .toList()
        ..sort(_compareDuplicateDimensionDiagnostics);

  return List.unmodifiable(duplicates);
}

List<String> _dimensionLabels(
  String key,
  Iterable<OmniChannelActivityTriageDimensionDefinition> definitions,
) {
  final labels = _mergeUniqueLabels(
    definitions.map((definition) => definition.dimension.label),
  );
  if (labels.isNotEmpty) return labels;

  return [key];
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
