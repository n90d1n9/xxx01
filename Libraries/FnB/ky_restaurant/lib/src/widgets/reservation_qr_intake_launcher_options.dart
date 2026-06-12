import 'package:flutter/material.dart';

import '../controllers/reservation_qr_session_controller.dart';
import '../models/reservation_intake_action.dart';
import '../models/reservation_qr_intake_launch_config.dart';
import '../models/reservation_qr_link.dart';
import '../services/reservation_qr_intake_launcher.dart';
import 'reservation_intake_options.dart';

/// Resolves per-action QR launch context before a QR intake link is created.
typedef RestaurantReservationQrLaunchConfigResolver =
    RestaurantReservationQrIntakeLaunchConfig? Function(
      RestaurantReservationIntakeAction action,
    );

/// Binds reservation intake choices to a QR launcher and fallback actions.
class RestaurantReservationQrIntakeLauncherOptions extends StatelessWidget {
  const RestaurantReservationQrIntakeLauncherOptions({
    super.key,
    required this.launcher,
    this.actions = RestaurantReservationIntakeAction.values,
    this.launchConfigForAction,
    this.onActionSelected,
    this.onLinkLaunched,
    this.onFallbackActionSelected,
  });

  final RestaurantReservationQrIntakeLauncher launcher;
  final List<RestaurantReservationIntakeAction> actions;
  final RestaurantReservationQrLaunchConfigResolver? launchConfigForAction;
  final ValueChanged<RestaurantReservationIntakeAction>? onActionSelected;
  final ValueChanged<RestaurantReservationQrLink>? onLinkLaunched;
  final ValueChanged<RestaurantReservationIntakeAction>?
  onFallbackActionSelected;

  @override
  Widget build(BuildContext context) {
    return RestaurantReservationIntakeOptions(
      actions: actions,
      onActionSelected: _handleActionSelected,
    );
  }

  void _handleActionSelected(RestaurantReservationIntakeAction action) {
    onActionSelected?.call(action);

    if (!launcher.canLaunch(action)) {
      onFallbackActionSelected?.call(action);
      return;
    }

    final link = launcher.launch(
      action,
      config: launchConfigForAction?.call(action),
    );
    onLinkLaunched?.call(link);
  }
}

/// Creates a QR intake launcher from a controller and renders intake choices.
class RestaurantReservationQrIntakeControllerOptions extends StatelessWidget {
  const RestaurantReservationQrIntakeControllerOptions({
    super.key,
    required this.controller,
    required this.config,
    this.actions = RestaurantReservationIntakeAction.values,
    this.launchConfigForAction,
    this.onActionSelected,
    this.onLinkLaunched,
    this.onFallbackActionSelected,
  });

  final RestaurantReservationQrSessionController controller;
  final RestaurantReservationQrIntakeLaunchConfig config;
  final List<RestaurantReservationIntakeAction> actions;
  final RestaurantReservationQrLaunchConfigResolver? launchConfigForAction;
  final ValueChanged<RestaurantReservationIntakeAction>? onActionSelected;
  final ValueChanged<RestaurantReservationQrLink>? onLinkLaunched;
  final ValueChanged<RestaurantReservationIntakeAction>?
  onFallbackActionSelected;

  @override
  Widget build(BuildContext context) {
    return RestaurantReservationQrIntakeLauncherOptions(
      launcher: RestaurantReservationQrIntakeLauncher(
        controller: controller,
        config: config,
      ),
      actions: actions,
      launchConfigForAction: launchConfigForAction,
      onActionSelected: onActionSelected,
      onLinkLaunched: onLinkLaunched,
      onFallbackActionSelected: onFallbackActionSelected,
    );
  }
}
