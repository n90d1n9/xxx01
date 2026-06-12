import 'package:flutter/material.dart';

import '../models/reservation_qr_scan_action_plan.dart';
import '../models/reservation_qr_scan_action_presentation.dart';
import '../services/reservation_qr_scan_action_presenter.dart';
import 'reservation_qr_scan_action_icon_resolver.dart';

/// Displays selectable host actions for a resolved reservation QR scan.
class RestaurantReservationQrScanActionBar extends StatelessWidget {
  const RestaurantReservationQrScanActionBar({
    super.key,
    required this.plan,
    this.onActionSelected,
    this.onContinue,
    this.onRefresh,
    this.onDismiss,
    this.presenter = const RestaurantReservationQrScanActionPresenter(),
    this.iconResolver = const RestaurantReservationQrScanActionIconResolver(),
  });

  final RestaurantReservationQrScanActionPlan plan;
  final ValueChanged<RestaurantReservationQrScanAction>? onActionSelected;
  final VoidCallback? onContinue;
  final VoidCallback? onRefresh;
  final VoidCallback? onDismiss;
  final RestaurantReservationQrScanActionPresenter presenter;
  final RestaurantReservationQrScanActionIconResolver iconResolver;

  List<RestaurantReservationQrScanAction> get selectableActions {
    return plan.actions.where(_canSelectAction).toList(growable: false);
  }

  bool get hasSelectableActions => selectableActions.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final actions = selectableActions;
    if (actions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final action in actions)
          RestaurantReservationQrScanActionButton(
            action: action,
            emphasis: action == plan.primaryAction
                ? RestaurantReservationQrScanActionButtonEmphasis.primary
                : RestaurantReservationQrScanActionButtonEmphasis.secondary,
            presenter: presenter,
            iconResolver: iconResolver,
            onPressed: () => _selectAction(action),
          ),
      ],
    );
  }

  void _selectAction(RestaurantReservationQrScanAction action) {
    onActionSelected?.call(action);
    switch (action) {
      case RestaurantReservationQrScanAction.createBooking:
      case RestaurantReservationQrScanAction.joinWaitlist:
      case RestaurantReservationQrScanAction.confirmCheckIn:
        onContinue?.call();
        break;
      case RestaurantReservationQrScanAction.refreshLink:
        onRefresh?.call();
        break;
      case RestaurantReservationQrScanAction.dismiss:
        onDismiss?.call();
        break;
    }
  }

  bool _canSelectAction(RestaurantReservationQrScanAction action) {
    if (onActionSelected != null) return true;
    return switch (action) {
      RestaurantReservationQrScanAction.createBooking ||
      RestaurantReservationQrScanAction.joinWaitlist ||
      RestaurantReservationQrScanAction.confirmCheckIn => onContinue != null,
      RestaurantReservationQrScanAction.refreshLink => onRefresh != null,
      RestaurantReservationQrScanAction.dismiss => onDismiss != null,
    };
  }
}

/// Identifies how prominently a QR scan action should render.
enum RestaurantReservationQrScanActionButtonEmphasis { primary, secondary }

/// Displays one QR scan action with accessible tooltip copy.
class RestaurantReservationQrScanActionButton extends StatelessWidget {
  const RestaurantReservationQrScanActionButton({
    super.key,
    required this.action,
    required this.onPressed,
    this.emphasis = RestaurantReservationQrScanActionButtonEmphasis.secondary,
    this.presenter = const RestaurantReservationQrScanActionPresenter(),
    this.iconResolver = const RestaurantReservationQrScanActionIconResolver(),
  });

  final RestaurantReservationQrScanAction action;
  final VoidCallback onPressed;
  final RestaurantReservationQrScanActionButtonEmphasis emphasis;
  final RestaurantReservationQrScanActionPresenter presenter;
  final RestaurantReservationQrScanActionIconResolver iconResolver;

  @override
  Widget build(BuildContext context) {
    final presentation = presenter.build(action);
    final child = _ActionButtonContent(
      action: action,
      presentation: presentation,
      iconResolver: iconResolver,
    );

    return Tooltip(
      message: presentation.tooltipLabel,
      child: emphasis == RestaurantReservationQrScanActionButtonEmphasis.primary
          ? FilledButton(onPressed: onPressed, child: child)
          : OutlinedButton(onPressed: onPressed, child: child),
    );
  }
}

/// Arranges the QR scan action icon, command, and supporting detail text.
class _ActionButtonContent extends StatelessWidget {
  const _ActionButtonContent({
    required this.action,
    required this.presentation,
    required this.iconResolver,
  });

  final RestaurantReservationQrScanAction action;
  final RestaurantReservationQrScanActionPresentation presentation;
  final RestaurantReservationQrScanActionIconResolver iconResolver;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 172, maxWidth: 260),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconResolver.iconFor(action), size: 17),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  presentation.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  presentation.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    inherit: true,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
