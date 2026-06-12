import 'restaurant_reservation.dart';

/// Identifies how one reservation status should appear in the lifecycle path.
enum RestaurantReservationStatusTimelineStepState {
  completed,
  current,
  pending,
}

/// Describes one visible stop in a reservation lifecycle timeline.
class RestaurantReservationStatusTimelineStep {
  const RestaurantReservationStatusTimelineStep({
    required this.status,
    required this.state,
  });

  final RestaurantReservationStatus status;
  final RestaurantReservationStatusTimelineStepState state;

  String get label => status.label;
}

/// Provides presentation-ready reservation lifecycle progress.
class RestaurantReservationStatusTimelineData {
  const RestaurantReservationStatusTimelineData({
    required this.currentStatus,
    required this.steps,
  });

  factory RestaurantReservationStatusTimelineData.fromReservation(
    RestaurantReservation reservation,
  ) {
    final statuses = _statusesFor(reservation.status);
    final currentIndex = statuses.indexOf(reservation.status);

    return RestaurantReservationStatusTimelineData(
      currentStatus: reservation.status,
      steps: [
        for (var index = 0; index < statuses.length; index++)
          RestaurantReservationStatusTimelineStep(
            status: statuses[index],
            state: _stateFor(index, currentIndex),
          ),
      ],
    );
  }

  final RestaurantReservationStatus currentStatus;
  final List<RestaurantReservationStatusTimelineStep> steps;

  RestaurantReservationStatusTimelineStep? get currentStep {
    for (final step in steps) {
      if (step.state == RestaurantReservationStatusTimelineStepState.current) {
        return step;
      }
    }
    return null;
  }

  double get progress {
    if (steps.length <= 1) return 1;
    final index = steps.indexWhere(
      (step) =>
          step.state == RestaurantReservationStatusTimelineStepState.current,
    );
    if (index < 0) return 0;
    return index / (steps.length - 1);
  }

  String get semanticLabel {
    return 'Reservation status ${currentStatus.label}, '
        '${(progress * 100).round()}% through lifecycle';
  }
}

List<RestaurantReservationStatus> _statusesFor(
  RestaurantReservationStatus status,
) {
  return switch (status) {
    RestaurantReservationStatus.cancelled ||
    RestaurantReservationStatus.noShow => [
      RestaurantReservationStatus.requested,
      status,
    ],
    RestaurantReservationStatus.late => const [
      RestaurantReservationStatus.requested,
      RestaurantReservationStatus.late,
      RestaurantReservationStatus.arrived,
      RestaurantReservationStatus.seated,
      RestaurantReservationStatus.completed,
    ],
    RestaurantReservationStatus.requested ||
    RestaurantReservationStatus.confirmed ||
    RestaurantReservationStatus.arrived ||
    RestaurantReservationStatus.seated ||
    RestaurantReservationStatus.completed => const [
      RestaurantReservationStatus.requested,
      RestaurantReservationStatus.confirmed,
      RestaurantReservationStatus.arrived,
      RestaurantReservationStatus.seated,
      RestaurantReservationStatus.completed,
    ],
  };
}

RestaurantReservationStatusTimelineStepState _stateFor(
  int index,
  int currentIndex,
) {
  if (index < currentIndex) {
    return RestaurantReservationStatusTimelineStepState.completed;
  }
  if (index == currentIndex) {
    return RestaurantReservationStatusTimelineStepState.current;
  }
  return RestaurantReservationStatusTimelineStepState.pending;
}
