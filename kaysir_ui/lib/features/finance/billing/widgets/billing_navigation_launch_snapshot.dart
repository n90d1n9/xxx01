import '../models/billing_business_domain_screen_registry.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_launch_state.dart';

class BillingNavigationLaunchSnapshot {
  final List<BillingNavigationLaunchState> states;
  final BillingNavigationDestinationId defaultDestinationId;

  BillingNavigationLaunchSnapshot({
    required Iterable<BillingNavigationLaunchState> states,
    required this.defaultDestinationId,
  }) : states = List.unmodifiable(states);

  bool get isEmpty => states.isEmpty;

  List<BillingNavigationDestinationId> get destinationIds {
    return List.unmodifiable(states.map((state) => state.destinationId));
  }

  List<BillingNavigationLaunchState> get enabledStates {
    return List.unmodifiable(states.where((state) => state.isEnabled));
  }

  List<BillingNavigationLaunchState> get disabledStates {
    return List.unmodifiable(states.where((state) => !state.isEnabled));
  }

  List<BillingNavigationLaunchSection> get sections {
    return _buildLaunchSections(states);
  }

  BillingNavigationLaunchState? stateFor(
    BillingNavigationDestinationId destinationId,
  ) {
    for (final state in states) {
      if (state.destinationId == destinationId) return state;
    }

    return null;
  }

  BillingNavigationLaunchState? firstEnabledState({
    Iterable<BillingNavigationDestinationId>? destinationIds,
  }) {
    if (destinationIds == null) {
      for (final state in states) {
        if (state.isEnabled) return state;
      }

      return null;
    }

    for (final destinationId in destinationIds) {
      final state = stateFor(destinationId);
      if (state?.isEnabled ?? false) return state;
    }

    return null;
  }

  BillingNavigationDestinationId selectedDestinationIdFor(
    BillingNavigationDestinationId preferredDestinationId, {
    Iterable<BillingNavigationDestinationId>? fallbackDestinationIds,
  }) {
    final preferredState = stateFor(preferredDestinationId);
    if (preferredState?.isEnabled ?? false) return preferredDestinationId;

    final fallbackState = firstEnabledState(
      destinationIds:
          fallbackDestinationIds ?? [defaultDestinationId, ...destinationIds],
    );

    return fallbackState?.destinationId ?? preferredDestinationId;
  }

  List<BillingNavigationLaunchState> statesForSurface(
    BillingNavigationSurface surface,
  ) {
    return List.unmodifiable(states.where((state) => state.surface == surface));
  }

  List<BillingNavigationLaunchState> statesForPresentation(
    BillingBusinessDomainScreenPresentation presentation,
  ) {
    return List.unmodifiable(
      states.where((state) => state.presentation == presentation),
    );
  }
}

class BillingNavigationLaunchSection {
  final String? label;
  final List<BillingNavigationLaunchState> states;

  BillingNavigationLaunchSection({
    required Iterable<BillingNavigationLaunchState> states,
    this.label,
  }) : states = List.unmodifiable(states);

  bool get hasLabel => label?.trim().isNotEmpty == true;

  List<BillingNavigationDestinationId> get destinationIds {
    return List.unmodifiable(states.map((state) => state.destinationId));
  }

  List<BillingNavigationLaunchState> get enabledStates {
    return List.unmodifiable(states.where((state) => state.isEnabled));
  }

  List<BillingNavigationLaunchState> get disabledStates {
    return List.unmodifiable(states.where((state) => !state.isEnabled));
  }
}

List<BillingNavigationLaunchSection> _buildLaunchSections(
  List<BillingNavigationLaunchState> states,
) {
  final sections = <BillingNavigationLaunchSection>[];
  final currentStates = <BillingNavigationLaunchState>[];
  String? currentLabel;

  void flushSection() {
    if (currentStates.isEmpty) return;

    sections.add(
      BillingNavigationLaunchSection(
        label: currentLabel,
        states: currentStates,
      ),
    );
    currentStates.clear();
  }

  for (final state in states) {
    final sectionLabel = state.destination.sectionLabel;
    if (sectionLabel != null) {
      flushSection();
      currentLabel = sectionLabel;
    }

    currentStates.add(state);
  }

  flushSection();

  return List.unmodifiable(sections);
}
