import 'package:flutter/material.dart';

import '../models/reservation_status_action_plan.dart';
import '../models/restaurant_reservation_status_action.dart';

/// Displays the available status actions for a reservation.
class RestaurantReservationActionBar extends StatelessWidget {
  const RestaurantReservationActionBar({
    super.key,
    required this.actions,
    required this.onActionSelected,
    this.plan,
  });

  final List<RestaurantReservationStatusAction> actions;
  final ValueChanged<RestaurantReservationStatusAction> onActionSelected;
  final RestaurantReservationStatusActionPlan? plan;

  @override
  Widget build(BuildContext context) {
    final effectivePlan =
        plan ?? RestaurantReservationStatusActionPlan.fromActions(actions);
    if (!effectivePlan.hasActions) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (effectivePlan.primaryAction case final primaryAction?)
          RestaurantReservationActionButton(
            action: primaryAction,
            emphasis: RestaurantReservationActionButtonEmphasis.primary,
            onPressed: () => onActionSelected(primaryAction),
          ),
        for (final action in effectivePlan.secondaryActions)
          RestaurantReservationActionButton(
            action: action,
            emphasis: RestaurantReservationActionButtonEmphasis.secondary,
            onPressed: () => onActionSelected(action),
          ),
      ],
    );
  }
}

/// Identifies how prominently a reservation status action should render.
enum RestaurantReservationActionButtonEmphasis { primary, secondary }

/// Displays one compact reservation status action button.
class RestaurantReservationActionButton extends StatelessWidget {
  const RestaurantReservationActionButton({
    super.key,
    required this.action,
    required this.onPressed,
    this.emphasis = RestaurantReservationActionButtonEmphasis.secondary,
  });

  final RestaurantReservationStatusAction action;
  final VoidCallback onPressed;
  final RestaurantReservationActionButtonEmphasis emphasis;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(_iconForAction(action), size: 16);
    final label = Text(action.label);
    if (emphasis == RestaurantReservationActionButtonEmphasis.primary) {
      return FilledButton.icon(onPressed: onPressed, icon: icon, label: label);
    }

    final colors = Theme.of(context).colorScheme;
    final foregroundColor = action.isCautionary ? colors.error : null;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: foregroundColor == null
          ? null
          : OutlinedButton.styleFrom(
              foregroundColor: foregroundColor,
              side: BorderSide(color: foregroundColor.withValues(alpha: .46)),
            ),
    );
  }
}

IconData _iconForAction(RestaurantReservationStatusAction action) {
  return switch (action) {
    RestaurantReservationStatusAction.confirm => Icons.check_circle_outline,
    RestaurantReservationStatusAction.cancel => Icons.event_busy_outlined,
    RestaurantReservationStatusAction.markArrived => Icons.login_rounded,
    RestaurantReservationStatusAction.markNoShow => Icons.person_off_outlined,
    RestaurantReservationStatusAction.seat => Icons.event_seat_outlined,
    RestaurantReservationStatusAction.complete => Icons.done_all_rounded,
  };
}
