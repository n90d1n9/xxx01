import '../widgets/reservation_qr_panel_binding.dart';
import 'reservation_qr_action_handler.dart';
import 'workspace_action_coordinator.dart';

/// Enriches reservation QR panel bindings with workspace-aware mutations.
class RestaurantWorkspaceReservationQrBindingFactory {
  const RestaurantWorkspaceReservationQrBindingFactory({
    required this.actionCoordinator,
  });

  final RestaurantWorkspaceActionCoordinator actionCoordinator;

  RestaurantReservationQrPanelBinding bind(
    RestaurantReservationQrPanelBinding binding,
  ) {
    final workspaceHandler = RestaurantReservationQrActionHandler(
      onReservationStatusChanged: actionCoordinator.updateReservationStatus,
    );
    final actionHandler =
        binding.actionHandler?.withFallbacks(workspaceHandler) ??
        workspaceHandler;

    return binding.copyWith(actionHandler: actionHandler);
  }
}
