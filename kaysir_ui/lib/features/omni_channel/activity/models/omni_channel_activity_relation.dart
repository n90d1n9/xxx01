import 'omni_channel_activity.dart';

enum OmniChannelActivityRelationKind { sameOrder, sameChannel, sameSource }

/// Related activity entries for the selected omni-channel event.
class OmniChannelRelatedActivity {
  final List<OmniChannelRelatedActivityEntry> entries;

  const OmniChannelRelatedActivity({required this.entries});

  bool get isEmpty => entries.isEmpty;

  bool get isNotEmpty => entries.isNotEmpty;

  factory OmniChannelRelatedActivity.fromEntries({
    required OmniChannelActivityEntry selectedEntry,
    required Iterable<OmniChannelActivityEntry> entries,
    int limit = 6,
  }) {
    final related = <OmniChannelRelatedActivityEntry>[];

    for (final entry in entries) {
      if (entry.id == selectedEntry.id) continue;

      final relation = _relationFor(selectedEntry, entry);
      if (relation == null) continue;

      related.add(
        OmniChannelRelatedActivityEntry(entry: entry, relation: relation),
      );
    }

    related.sort(_compareRelatedEntries);
    return OmniChannelRelatedActivity(
      entries: List.unmodifiable(related.take(limit)),
    );
  }
}

/// One related activity event and the reason it is related.
class OmniChannelRelatedActivityEntry {
  final OmniChannelActivityEntry entry;
  final OmniChannelActivityRelationKind relation;

  const OmniChannelRelatedActivityEntry({
    required this.entry,
    required this.relation,
  });
}

extension OmniChannelActivityRelationKindLabel
    on OmniChannelActivityRelationKind {
  String get label {
    switch (this) {
      case OmniChannelActivityRelationKind.sameOrder:
        return 'Same order';
      case OmniChannelActivityRelationKind.sameChannel:
        return 'Same channel';
      case OmniChannelActivityRelationKind.sameSource:
        return 'Same source';
    }
  }
}

OmniChannelActivityRelationKind? _relationFor(
  OmniChannelActivityEntry selectedEntry,
  OmniChannelActivityEntry entry,
) {
  if (_sameValue(selectedEntry.orderId, entry.orderId)) {
    return OmniChannelActivityRelationKind.sameOrder;
  }
  if (_sameValue(selectedEntry.channelId, entry.channelId)) {
    return OmniChannelActivityRelationKind.sameChannel;
  }
  if (_sameValue(selectedEntry.sourceId, entry.sourceId)) {
    return OmniChannelActivityRelationKind.sameSource;
  }

  return null;
}

int _compareRelatedEntries(
  OmniChannelRelatedActivityEntry left,
  OmniChannelRelatedActivityEntry right,
) {
  final priorityComparison = _priority(
    left.relation,
  ).compareTo(_priority(right.relation));
  if (priorityComparison != 0) return priorityComparison;

  final timeComparison = right.entry.occurredAt.compareTo(
    left.entry.occurredAt,
  );
  if (timeComparison != 0) return timeComparison;

  return right.entry.id.compareTo(left.entry.id);
}

int _priority(OmniChannelActivityRelationKind relation) {
  switch (relation) {
    case OmniChannelActivityRelationKind.sameOrder:
      return 0;
    case OmniChannelActivityRelationKind.sameChannel:
      return 1;
    case OmniChannelActivityRelationKind.sameSource:
      return 2;
  }
}

bool _sameValue(String? left, String? right) {
  final normalizedLeft = left?.trim();
  final normalizedRight = right?.trim();
  if (normalizedLeft == null || normalizedLeft.isEmpty) return false;
  if (normalizedRight == null || normalizedRight.isEmpty) return false;

  return normalizedLeft == normalizedRight;
}
