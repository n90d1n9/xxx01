import '../utils/billing_release_gate.dart';

/// Maps a release gate lane to a diagnostics section target.
class BillingReleaseGateLaneTarget {
  final String laneId;
  final String sectionId;

  const BillingReleaseGateLaneTarget({
    required this.laneId,
    required this.sectionId,
  });
}

/// Validated lookup registry for release gate lane navigation targets.
class BillingReleaseGateLaneTargetRegistry {
  static const empty = BillingReleaseGateLaneTargetRegistry._([]);

  final List<BillingReleaseGateLaneTarget> targets;

  factory BillingReleaseGateLaneTargetRegistry({
    required Iterable<BillingReleaseGateLaneTarget> targets,
  }) {
    return BillingReleaseGateLaneTargetRegistry._(
      List.unmodifiable(_validatedLaneTargets(targets)),
    );
  }

  const BillingReleaseGateLaneTargetRegistry._(this.targets);

  BillingReleaseGateLaneTarget? targetForLane(BillingReleaseGateLane lane) {
    return targetForLaneId(lane.id);
  }

  BillingReleaseGateLaneTarget? targetForLaneId(String laneId) {
    final normalizedLaneId = laneId.trim();
    if (normalizedLaneId.isEmpty) return null;

    for (final target in targets) {
      if (target.laneId == normalizedLaneId) return target;
    }

    return null;
  }

  BillingReleaseGateLaneTargetRegistry extend({
    Iterable<BillingReleaseGateLaneTarget> targets = const [],
  }) {
    if (targets.isEmpty) return this;

    return BillingReleaseGateLaneTargetRegistry(
      targets: [...this.targets, ...targets],
    );
  }
}

List<BillingReleaseGateLaneTarget> _validatedLaneTargets(
  Iterable<BillingReleaseGateLaneTarget> targets,
) {
  final targetList = targets.toList();
  final laneIds = <String>{};

  for (final target in targetList) {
    final laneId = target.laneId.trim();
    if (laneId.isEmpty) {
      throw ArgumentError.value(target.laneId, 'laneId', 'must not be blank');
    }
    if (laneId != target.laneId) {
      throw ArgumentError.value(
        target.laneId,
        'laneId',
        'must not contain leading or trailing whitespace',
      );
    }
    if (!laneIds.add(laneId)) {
      throw ArgumentError.value(
        target.laneId,
        'laneId',
        'must be unique in a release gate lane target registry',
      );
    }

    final sectionId = target.sectionId.trim();
    if (sectionId.isEmpty) {
      throw ArgumentError.value(
        target.sectionId,
        'sectionId',
        'must not be blank',
      );
    }
    if (sectionId != target.sectionId) {
      throw ArgumentError.value(
        target.sectionId,
        'sectionId',
        'must not contain leading or trailing whitespace',
      );
    }
  }

  return targetList;
}
