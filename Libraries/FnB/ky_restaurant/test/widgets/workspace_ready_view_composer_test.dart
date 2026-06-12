import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('workspace ready view composer wires data and interactions', () {
    final controller = RestaurantWorkspaceController(
      repository: const DemoRestaurantSnapshotRepository(),
      initialState: RestaurantWorkspaceState.ready(
        snapshot: restaurantDemoSnapshot,
        updatedAt: DateTime(2026, 1, 1, 18),
      ),
    );
    final preferencesController = RestaurantWorkspacePreferencesController(
      initialPreferences: const RestaurantWorkspacePreferences(
        filters: RestaurantWorkspacePanelFilters(menuSearchQuery: 'rib'),
      ),
    );
    final viewChanges = <RestaurantWorkspaceView>[];
    final undoMessages = <String>[];
    var resetConfirmed = false;
    final viewAvailability = RestaurantWorkspaceViewAvailability.fromViews(
      RestaurantWorkspaceView.values,
    );
    final actionCoordinator = RestaurantWorkspaceActionCoordinator(
      dispatcher: RestaurantWorkspaceActionDispatcher(controller: controller),
      showUndoMessage: (message, VoidCallback _) => undoMessages.add(message),
    );
    final preferenceCoordinator = RestaurantWorkspacePreferenceCoordinator(
      controller: preferencesController,
      viewAvailability: viewAvailability,
      onViewChanged: viewChanges.add,
      onResetConfirmed: () => resetConfirmed = true,
    );
    final qrController = RestaurantReservationQrSessionController();
    final qrPanelBinding = RestaurantReservationQrPanelBinding(
      controller: qrController,
      launchConfig: RestaurantReservationQrIntakeLaunchConfig(
        baseUri: Uri.parse('https://tables.kaysir.test/workspace'),
      ),
    );

    final composition = RestaurantWorkspaceReadyViewComposer().compose(
      state: controller.state,
      snapshot: restaurantDemoSnapshot,
      selectedView: preferencesController.selectedView,
      filters: preferencesController.filters,
      focus: preferencesController.focus,
      viewAvailability: viewAvailability,
      controller: controller,
      preferencesController: preferencesController,
      actionCoordinator: actionCoordinator,
      preferenceCoordinator: preferenceCoordinator,
      reservationQrPanelBinding: qrPanelBinding,
    );

    expect(composition.data.snapshot, restaurantDemoSnapshot);
    expect(composition.data.selectedView, RestaurantWorkspaceView.pulse);
    expect(composition.data.filters.menuSearchQuery, 'rib');
    expect(composition.data.insights, isNotEmpty);
    expect(composition.data.attentionQueue.hasAttention, isTrue);
    final composedQrPanelBinding =
        composition.panelActions.reservationQrPanelBinding;
    expect(composedQrPanelBinding, isNotNull);
    expect(composedQrPanelBinding, isNot(same(qrPanelBinding)));
    expect(composedQrPanelBinding!.controller, same(qrController));
    expect(
      composedQrPanelBinding.launchConfig,
      same(qrPanelBinding.launchConfig),
    );
    expect(composedQrPanelBinding.actionHandler, isNotNull);

    final checkInWorkflow = RestaurantReservationQrScanWorkflow(
      result: RestaurantReservationQrScanResult.valid(
        uri: Uri.parse('https://tables.kaysir.test/workspace?payload=check-in'),
        payload: RestaurantReservationQrPayload(
          token: 'workspace-check-in',
          intent: RestaurantReservationQrIntent.checkIn,
          expiresAt: DateTime(2026, 1, 1, 18, 30),
          reservationId: 'sari-party',
        ),
        scannedAt: DateTime(2026, 1, 1, 18, 5),
      ),
      actionPlan: const RestaurantReservationQrScanActionPlan(
        primaryAction: RestaurantReservationQrScanAction.confirmCheckIn,
      ),
    );
    final qrResult = composedQrPanelBinding.actionHandler!.handle(
      workflow: checkInWorkflow,
      action: RestaurantReservationQrScanAction.confirmCheckIn,
    );

    expect(qrResult.isHandled, isTrue);
    expect(
      controller.state.snapshot!.reservations
          .firstWhere((reservation) => reservation.id == 'sari-party')
          .status,
      RestaurantReservationStatus.arrived,
    );

    composition.overviewCallbacks.onAttentionSignalSelected?.call(
      composition.data.attentionQueue.topSignal!,
    );
    expect(preferencesController.filters.menu, RestaurantMenuFilter.risk);
    expect(preferencesController.filters.menuSort, RestaurantMenuSort.risk);
    expect(
      preferencesController.focus?.kind,
      RestaurantWorkspacePanelFocusKind.menuSignal,
    );
    expect(preferencesController.focus?.targetId, 'short-rib-rendang');

    composition.panelActions.onCompleteTask?.call('rendang-par');
    composition.panelActions.onReviewCatalogItem?.call('nasi-ulam');
    composition.panelActions.onReviewRecipeProduction?.call('burnt-cheesecake');
    composition.controls.onReset?.call();

    expect(preferencesController.selectedView, RestaurantWorkspaceView.menu);
    expect(
      preferencesController.filters,
      const RestaurantWorkspacePanelFilters(),
    );
    expect(viewChanges, [RestaurantWorkspaceView.menu]);
    expect(undoMessages, [
      'Reservation marked Arrived',
      'Task completed',
      'Catalog review saved',
      'Recipe production review saved',
    ]);
    expect(
      controller.state.activities.first.kind,
      RestaurantOperationActivityKind.recipeProductionReviewed,
    );
    expect(resetConfirmed, isTrue);

    controller.dispose();
    preferencesController.dispose();
    qrController.dispose();
  });
}
