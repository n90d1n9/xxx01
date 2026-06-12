import 'billing_navigation_destination.dart';
import 'billing_navigation_dispatch_plan.dart';
import 'billing_navigation_dispatch_summary.dart';
import 'billing_navigation_launch_snapshot.dart';

class BillingNavigationDispatchSnapshot {
  final BillingNavigationSurface currentSurface;
  final BillingNavigationDestinationId defaultDestinationId;
  final List<BillingNavigationDispatchPlan> plans;

  BillingNavigationDispatchSnapshot({
    required this.currentSurface,
    required this.defaultDestinationId,
    required Iterable<BillingNavigationDispatchPlan> plans,
  }) : plans = List.unmodifiable(plans);

  factory BillingNavigationDispatchSnapshot.fromLaunchSnapshot({
    required BillingNavigationLaunchSnapshot launchSnapshot,
    required BillingNavigationSurface currentSurface,
  }) {
    return BillingNavigationDispatchSnapshot(
      currentSurface: currentSurface,
      defaultDestinationId: launchSnapshot.defaultDestinationId,
      plans: launchSnapshot.states.map(
        (state) => resolveBillingNavigationDispatchPlan(
          launchState: state,
          currentSurface: currentSurface,
        ),
      ),
    );
  }

  bool get isEmpty => plans.isEmpty;

  List<BillingNavigationDestinationId> get destinationIds {
    return List.unmodifiable(plans.map((plan) => plan.destinationId));
  }

  List<BillingNavigationDispatchPlan> get actionablePlans {
    return List.unmodifiable(plans.where((plan) => plan.isActionable));
  }

  List<BillingNavigationDispatchPlan> get localPlans {
    return plansForKind(BillingNavigationDispatchKind.local);
  }

  List<BillingNavigationDispatchPlan> get routePlans {
    return plansForKind(BillingNavigationDispatchKind.route);
  }

  List<BillingNavigationDispatchPlan> get unavailablePlans {
    return plansForKind(BillingNavigationDispatchKind.unavailable);
  }

  List<BillingNavigationDispatchPlan> get ignoredPlans {
    return plansForKind(BillingNavigationDispatchKind.ignored);
  }

  List<BillingNavigationDispatchSection> get sections {
    return _buildDispatchSections(plans);
  }

  BillingNavigationDispatchSummary get summary {
    return BillingNavigationDispatchSummary.fromPlans(plans);
  }

  List<BillingNavigationDispatchPlan> plansForKind(
    BillingNavigationDispatchKind kind,
  ) {
    return List.unmodifiable(plans.where((plan) => plan.kind == kind));
  }

  List<BillingNavigationDispatchPlan> plansForTargetSurface(
    BillingNavigationSurface surface,
  ) {
    return List.unmodifiable(
      plans.where((plan) => plan.targetSurface == surface),
    );
  }

  BillingNavigationDispatchPlan? planFor(
    BillingNavigationDestinationId destinationId,
  ) {
    for (final plan in plans) {
      if (plan.destinationId == destinationId) return plan;
    }

    return null;
  }

  BillingNavigationDispatchPlan? planForScreenKey(String screenKey) {
    for (final plan in plans) {
      if (plan.screenKey == screenKey) return plan;
    }

    return null;
  }

  BillingNavigationDispatchPlan? firstActionablePlan({
    Iterable<BillingNavigationDestinationId>? destinationIds,
  }) {
    if (destinationIds == null) {
      for (final plan in plans) {
        if (plan.isActionable) return plan;
      }

      return null;
    }

    for (final destinationId in destinationIds) {
      final plan = planFor(destinationId);
      if (plan?.isActionable ?? false) return plan;
    }

    return null;
  }

  BillingNavigationDestinationId selectedDestinationIdFor(
    BillingNavigationDestinationId preferredDestinationId, {
    Iterable<BillingNavigationDestinationId>? fallbackDestinationIds,
  }) {
    final preferredPlan = planFor(preferredDestinationId);
    if (preferredPlan?.isActionable ?? false) return preferredDestinationId;

    final fallbackPlan = firstActionablePlan(
      destinationIds:
          fallbackDestinationIds ?? [defaultDestinationId, ...destinationIds],
    );

    return fallbackPlan?.destinationId ?? preferredDestinationId;
  }
}

class BillingNavigationDispatchSection {
  final String? label;
  final List<BillingNavigationDispatchPlan> plans;

  BillingNavigationDispatchSection({
    required Iterable<BillingNavigationDispatchPlan> plans,
    this.label,
  }) : plans = List.unmodifiable(plans);

  bool get hasLabel => label?.trim().isNotEmpty == true;

  List<BillingNavigationDestinationId> get destinationIds {
    return List.unmodifiable(plans.map((plan) => plan.destinationId));
  }

  List<BillingNavigationDispatchPlan> get actionablePlans {
    return List.unmodifiable(plans.where((plan) => plan.isActionable));
  }

  List<BillingNavigationDispatchPlan> get unavailablePlans {
    return List.unmodifiable(plans.where((plan) => plan.isUnavailable));
  }
}

List<BillingNavigationDispatchSection> _buildDispatchSections(
  List<BillingNavigationDispatchPlan> plans,
) {
  final sections = <BillingNavigationDispatchSection>[];
  final currentPlans = <BillingNavigationDispatchPlan>[];
  String? currentLabel;

  void flushSection() {
    if (currentPlans.isEmpty) return;

    sections.add(
      BillingNavigationDispatchSection(
        label: currentLabel,
        plans: currentPlans,
      ),
    );
    currentPlans.clear();
  }

  for (final plan in plans) {
    final sectionLabel = plan.destination.sectionLabel;
    if (sectionLabel != null) {
      flushSection();
      currentLabel = sectionLabel;
    }

    currentPlans.add(plan);
  }

  flushSection();

  return List.unmodifiable(sections);
}
