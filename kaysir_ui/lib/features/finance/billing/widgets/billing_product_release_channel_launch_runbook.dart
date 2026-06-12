import 'billing_navigation_destination.dart';
import 'billing_product_release_channel_launch_dispatch_plan.dart';
import 'billing_product_release_channel_launch_dispatch_status.dart';

class BillingProductReleaseChannelLaunchRunbookStep {
  final String id;
  final String title;
  final String detail;
  final String destinationLabel;
  final String callToActionLabel;
  final String statusLabel;
  final BillingNavigationDestinationId destinationId;
  final BillingProductReleaseChannelLaunchDispatchStatus status;
  final bool isActionable;
  final bool isBlocked;
  final List<String> checklistItems;

  BillingProductReleaseChannelLaunchRunbookStep({
    required this.id,
    required this.title,
    required this.detail,
    required this.destinationLabel,
    required this.callToActionLabel,
    required this.statusLabel,
    required this.destinationId,
    BillingProductReleaseChannelLaunchDispatchStatus? status,
    required this.isActionable,
    required this.isBlocked,
    Iterable<String> checklistItems = const [],
  }) : status =
           status ??
           _statusForLegacyStepFlags(
             isActionable: isActionable,
             isBlocked: isBlocked,
           ),
       checklistItems = List.unmodifiable(checklistItems);

  factory BillingProductReleaseChannelLaunchRunbookStep.fromDispatchEntry(
    BillingProductReleaseChannelLaunchDispatchEntry entry,
  ) {
    return BillingProductReleaseChannelLaunchRunbookStep(
      id: entry.launchAction.id,
      title: entry.launchAction.label,
      detail: entry.disabledReason ?? entry.operatorStepLabel,
      destinationLabel: entry.destinationLabel,
      callToActionLabel: entry.callToActionLabel,
      statusLabel: entry.statusLabel,
      destinationId: entry.destinationId,
      status: entry.status,
      isActionable: entry.isActionable,
      isBlocked: entry.isBlockedByRelease,
      checklistItems: entry.routeTarget.checklistItems,
    );
  }

  Map<String, Object?> get payload {
    return {
      'id': id,
      'title': title,
      'detail': detail,
      'destinationId': destinationId.name,
      'destinationLabel': destinationLabel,
      'callToActionLabel': callToActionLabel,
      'statusLabel': statusLabel,
      'status': status.name,
      'isActionable': isActionable,
      'isBlocked': isBlocked,
      'checklistItems': checklistItems,
    };
  }
}

class BillingProductReleaseChannelLaunchRunbookGroup {
  final BillingNavigationDestinationId destinationId;
  final String destinationLabel;
  final List<BillingProductReleaseChannelLaunchRunbookStep> steps;

  BillingProductReleaseChannelLaunchRunbookGroup({
    required this.destinationId,
    required this.destinationLabel,
    Iterable<BillingProductReleaseChannelLaunchRunbookStep> steps = const [],
  }) : steps = List.unmodifiable(steps);

  int get stepCount => steps.length;

  int get actionableStepCount {
    return steps.where((step) => step.isActionable).length;
  }

  int get blockedStepCount {
    return steps.where((step) => step.isBlocked).length;
  }

  int get needsWorkStepCount => stepCount - actionableStepCount;

  bool get hasActionableSteps => actionableStepCount > 0;

  Map<String, Object?> get payload {
    return {
      'destinationId': destinationId.name,
      'destinationLabel': destinationLabel,
      'stepCount': stepCount,
      'actionableStepCount': actionableStepCount,
      'blockedStepCount': blockedStepCount,
      'needsWorkStepCount': needsWorkStepCount,
      'steps': steps.map((step) => step.payload).toList(growable: false),
    };
  }

  String get summaryLabel {
    if (stepCount == 0) return 'No launch steps.';
    if (actionableStepCount == stepCount) {
      return '$stepCount ${_plural(stepCount, 'step')} ready.';
    }
    if (actionableStepCount > 0) {
      return '$actionableStepCount ready; $needsWorkStepCount need work.';
    }

    return '$needsWorkStepCount ${_plural(needsWorkStepCount, 'step')} need '
        'work.';
  }
}

class BillingProductReleaseChannelLaunchRunbook {
  final List<BillingProductReleaseChannelLaunchRunbookGroup> groups;

  BillingProductReleaseChannelLaunchRunbook({
    Iterable<BillingProductReleaseChannelLaunchRunbookGroup> groups = const [],
  }) : groups = List.unmodifiable(groups);

  factory BillingProductReleaseChannelLaunchRunbook.fromDispatchPlan(
    BillingProductReleaseChannelLaunchDispatchPlan dispatchPlan,
  ) {
    final groupedSteps =
        <
          BillingNavigationDestinationId,
          List<BillingProductReleaseChannelLaunchRunbookStep>
        >{};

    for (final entry in dispatchPlan.entries) {
      groupedSteps
          .putIfAbsent(entry.destinationId, () => [])
          .add(
            BillingProductReleaseChannelLaunchRunbookStep.fromDispatchEntry(
              entry,
            ),
          );
    }

    return BillingProductReleaseChannelLaunchRunbook(
      groups: groupedSteps.entries.map((entry) {
        return BillingProductReleaseChannelLaunchRunbookGroup(
          destinationId: entry.key,
          destinationLabel: billingNavigationDestinationFor(entry.key).label,
          steps: entry.value,
        );
      }),
    );
  }

  bool get isEmpty => groups.isEmpty;

  int get destinationCount => groups.length;

  int get stepCount {
    return groups.fold(0, (total, group) => total + group.stepCount);
  }

  int get actionableStepCount {
    return groups.fold(0, (total, group) => total + group.actionableStepCount);
  }

  int get blockedStepCount {
    return groups.fold(0, (total, group) => total + group.blockedStepCount);
  }

  int get needsWorkStepCount => stepCount - actionableStepCount;

  List<BillingProductReleaseChannelLaunchRunbookStep> get steps {
    return List.unmodifiable(groups.expand((group) => group.steps));
  }

  BillingProductReleaseChannelLaunchRunbookGroup? groupForDestination(
    BillingNavigationDestinationId destinationId,
  ) {
    for (final group in groups) {
      if (group.destinationId == destinationId) return group;
    }

    return null;
  }

  BillingProductReleaseChannelLaunchRunbookGroup requireGroupForDestination(
    BillingNavigationDestinationId destinationId,
  ) {
    final group = groupForDestination(destinationId);
    if (group == null) {
      throw StateError(
        'No billing channel launch runbook group exists for '
        '${destinationId.name}.',
      );
    }

    return group;
  }

  Map<String, Object?> get payload {
    return {
      'destinationCount': destinationCount,
      'stepCount': stepCount,
      'actionableStepCount': actionableStepCount,
      'blockedStepCount': blockedStepCount,
      'needsWorkStepCount': needsWorkStepCount,
      'groups': groups.map((group) => group.payload).toList(growable: false),
    };
  }

  String get summaryLabel {
    if (isEmpty) {
      return 'No channel launch runbook steps are available.';
    }
    if (actionableStepCount == 0) {
      return '$needsWorkStepCount '
          '${_plural(needsWorkStepCount, 'launch step')} need routing or '
          'readiness work.';
    }
    if (needsWorkStepCount > 0) {
      return '$actionableStepCount '
          '${_plural(actionableStepCount, 'launch step')} ready; '
          '$needsWorkStepCount need work.';
    }

    return '$actionableStepCount '
        '${_plural(actionableStepCount, 'launch step')} ready to execute.';
  }
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}

BillingProductReleaseChannelLaunchDispatchStatus _statusForLegacyStepFlags({
  required bool isActionable,
  required bool isBlocked,
}) {
  if (isBlocked) {
    return BillingProductReleaseChannelLaunchDispatchStatus.blockedByRelease;
  }
  if (isActionable) {
    return BillingProductReleaseChannelLaunchDispatchStatus.route;
  }

  return BillingProductReleaseChannelLaunchDispatchStatus.unavailable;
}
