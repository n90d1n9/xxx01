import 'package:flutter/widgets.dart';

import '../controllers/reservation_qr_session_controller.dart';
import '../models/reservation_intake_action.dart';
import '../models/reservation_qr_intake_launch_config.dart';
import '../models/reservation_qr_link.dart';
import '../services/reservation_qr_action_handler.dart';
import 'reservation_qr_intake_launcher_options.dart';
import 'reservation_qr_scan_entry_binding.dart';
import 'reservation_qr_session_callbacks.dart';

const Object _notProvided = Object();

/// Collects QR launch, scan, and session behavior for a reservation panel.
@immutable
class RestaurantReservationQrPanelBinding {
  const RestaurantReservationQrPanelBinding({
    required this.controller,
    required this.launchConfig,
    this.actions = RestaurantReservationIntakeAction.values,
    this.launchConfigForAction,
    this.onLinkLaunched,
    this.onFallbackActionSelected,
    this.scanEntryBinding = const RestaurantReservationQrScanEntryBinding(),
    this.actionHandler,
    this.sessionCallbacks = RestaurantReservationQrSessionCallbacks.empty,
  });

  final RestaurantReservationQrSessionController controller;
  final RestaurantReservationQrIntakeLaunchConfig launchConfig;
  final List<RestaurantReservationIntakeAction> actions;
  final RestaurantReservationQrLaunchConfigResolver? launchConfigForAction;
  final ValueChanged<RestaurantReservationQrLink>? onLinkLaunched;
  final ValueChanged<RestaurantReservationIntakeAction>?
  onFallbackActionSelected;
  final RestaurantReservationQrScanEntryBinding scanEntryBinding;
  final RestaurantReservationQrActionHandler? actionHandler;
  final RestaurantReservationQrSessionCallbacks sessionCallbacks;

  RestaurantReservationQrPanelBinding copyWith({
    RestaurantReservationQrSessionController? controller,
    RestaurantReservationQrIntakeLaunchConfig? launchConfig,
    List<RestaurantReservationIntakeAction>? actions,
    Object? launchConfigForAction = _notProvided,
    Object? onLinkLaunched = _notProvided,
    Object? onFallbackActionSelected = _notProvided,
    RestaurantReservationQrScanEntryBinding? scanEntryBinding,
    Object? actionHandler = _notProvided,
    RestaurantReservationQrSessionCallbacks? sessionCallbacks,
  }) {
    return RestaurantReservationQrPanelBinding(
      controller: controller ?? this.controller,
      launchConfig: launchConfig ?? this.launchConfig,
      actions: actions ?? this.actions,
      launchConfigForAction: identical(launchConfigForAction, _notProvided)
          ? this.launchConfigForAction
          : launchConfigForAction
                as RestaurantReservationQrLaunchConfigResolver?,
      onLinkLaunched: identical(onLinkLaunched, _notProvided)
          ? this.onLinkLaunched
          : onLinkLaunched as ValueChanged<RestaurantReservationQrLink>?,
      onFallbackActionSelected:
          identical(onFallbackActionSelected, _notProvided)
          ? this.onFallbackActionSelected
          : onFallbackActionSelected
                as ValueChanged<RestaurantReservationIntakeAction>?,
      scanEntryBinding: scanEntryBinding ?? this.scanEntryBinding,
      actionHandler: identical(actionHandler, _notProvided)
          ? this.actionHandler
          : actionHandler as RestaurantReservationQrActionHandler?,
      sessionCallbacks: sessionCallbacks ?? this.sessionCallbacks,
    );
  }
}
