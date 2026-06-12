import 'pos_switch_action_history.dart';
import 'pos_switch_action_result.dart';

enum POSSwitchActionHistoryFilterStatus {
  all,
  attention,
  applied,
  blocked,
  cancelled,
  modes,
  runtimePacks,
  commerceChannels,
}

class POSSwitchActionHistoryFilter {
  final String query;
  final POSSwitchActionHistoryFilterStatus status;

  const POSSwitchActionHistoryFilter({
    this.query = '',
    this.status = POSSwitchActionHistoryFilterStatus.all,
  });

  bool matches(POSSwitchActionHistoryEntry entry) {
    return _matchesQuery(entry) && _matchesStatus(entry);
  }

  List<POSSwitchActionHistoryEntry> apply(
    Iterable<POSSwitchActionHistoryEntry> entries,
  ) {
    return entries.where(matches).toList(growable: false);
  }

  POSSwitchActionHistoryFilter copyWith({
    String? query,
    POSSwitchActionHistoryFilterStatus? status,
  }) {
    return POSSwitchActionHistoryFilter(
      query: query ?? this.query,
      status: status ?? this.status,
    );
  }

  bool _matchesQuery(POSSwitchActionHistoryEntry entry) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    return entry.searchTerms.any(
      (term) => term.toLowerCase().contains(normalized),
    );
  }

  bool _matchesStatus(POSSwitchActionHistoryEntry entry) {
    final result = entry.result;

    switch (status) {
      case POSSwitchActionHistoryFilterStatus.all:
        return true;
      case POSSwitchActionHistoryFilterStatus.attention:
        return entry.requiresAttention;
      case POSSwitchActionHistoryFilterStatus.applied:
        return result.outcome == POSSwitchActionOutcome.applied;
      case POSSwitchActionHistoryFilterStatus.blocked:
        return result.outcome == POSSwitchActionOutcome.blocked;
      case POSSwitchActionHistoryFilterStatus.cancelled:
        return result.outcome == POSSwitchActionOutcome.cancelled;
      case POSSwitchActionHistoryFilterStatus.modes:
        return result.kind == POSSwitchActionKind.mode;
      case POSSwitchActionHistoryFilterStatus.runtimePacks:
        return result.kind == POSSwitchActionKind.runtimePack;
      case POSSwitchActionHistoryFilterStatus.commerceChannels:
        return result.kind == POSSwitchActionKind.commerceChannel;
    }
  }
}

class POSSwitchActionHistoryFilterCounts {
  final int all;
  final int attention;
  final int applied;
  final int blocked;
  final int cancelled;
  final int modes;
  final int runtimePacks;
  final int commerceChannels;

  const POSSwitchActionHistoryFilterCounts({
    required this.all,
    required this.attention,
    required this.applied,
    required this.blocked,
    required this.cancelled,
    required this.modes,
    required this.runtimePacks,
    required this.commerceChannels,
  });

  factory POSSwitchActionHistoryFilterCounts.fromEntries(
    Iterable<POSSwitchActionHistoryEntry> entries,
  ) {
    var all = 0;
    var attention = 0;
    var applied = 0;
    var blocked = 0;
    var cancelled = 0;
    var modes = 0;
    var runtimePacks = 0;
    var commerceChannels = 0;

    for (final entry in entries) {
      all += 1;
      if (entry.requiresAttention) attention += 1;

      switch (entry.result.outcome) {
        case POSSwitchActionOutcome.applied:
          applied += 1;
        case POSSwitchActionOutcome.blocked:
          blocked += 1;
        case POSSwitchActionOutcome.cancelled:
          cancelled += 1;
      }

      switch (entry.result.kind) {
        case POSSwitchActionKind.mode:
          modes += 1;
        case POSSwitchActionKind.runtimePack:
          runtimePacks += 1;
        case POSSwitchActionKind.commerceChannel:
          commerceChannels += 1;
      }
    }

    return POSSwitchActionHistoryFilterCounts(
      all: all,
      attention: attention,
      applied: applied,
      blocked: blocked,
      cancelled: cancelled,
      modes: modes,
      runtimePacks: runtimePacks,
      commerceChannels: commerceChannels,
    );
  }

  int countFor(POSSwitchActionHistoryFilterStatus status) {
    switch (status) {
      case POSSwitchActionHistoryFilterStatus.all:
        return all;
      case POSSwitchActionHistoryFilterStatus.attention:
        return attention;
      case POSSwitchActionHistoryFilterStatus.applied:
        return applied;
      case POSSwitchActionHistoryFilterStatus.blocked:
        return blocked;
      case POSSwitchActionHistoryFilterStatus.cancelled:
        return cancelled;
      case POSSwitchActionHistoryFilterStatus.modes:
        return modes;
      case POSSwitchActionHistoryFilterStatus.runtimePacks:
        return runtimePacks;
      case POSSwitchActionHistoryFilterStatus.commerceChannels:
        return commerceChannels;
    }
  }
}

extension POSSwitchActionHistoryFilterStatusLabel
    on POSSwitchActionHistoryFilterStatus {
  String get label {
    switch (this) {
      case POSSwitchActionHistoryFilterStatus.all:
        return 'All';
      case POSSwitchActionHistoryFilterStatus.attention:
        return 'Attention';
      case POSSwitchActionHistoryFilterStatus.applied:
        return 'Applied';
      case POSSwitchActionHistoryFilterStatus.blocked:
        return 'Blocked';
      case POSSwitchActionHistoryFilterStatus.cancelled:
        return 'Cancelled';
      case POSSwitchActionHistoryFilterStatus.modes:
        return 'Modes';
      case POSSwitchActionHistoryFilterStatus.runtimePacks:
        return 'Packs';
      case POSSwitchActionHistoryFilterStatus.commerceChannels:
        return 'Channels';
    }
  }
}
