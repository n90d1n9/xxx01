import '../controllers/restaurant_workspace_controller.dart';
import '../controllers/restaurant_workspace_preferences_controller.dart';
import '../controllers/restaurant_workspace_state.dart';
import '../models/restaurant_models.dart';
import '../models/restaurant_workspace_panel_filters.dart';
import '../models/restaurant_workspace_panel_focus.dart';
import '../models/restaurant_workspace_view.dart';
import '../models/restaurant_workspace_view_availability.dart';
import '../models/workspace_ready_view_data.dart';
import '../services/restaurant_operational_insight_builder.dart';
import '../services/attention_signal_builder.dart';
import '../services/attention_signal_target_resolver.dart';
import '../services/workspace_action_coordinator.dart';
import '../services/workspace_preference_coordinator.dart';
import '../services/workspace_reservation_qr_binding.dart';
import '../services/workspace_ready_view_data_builder.dart';
import 'reservation_qr_panel_binding.dart';
import 'workspace_panel_deck.dart';
import 'workspace_ready_view_callbacks.dart';

/// Groups the ready workspace data and interactions needed by the view.
class RestaurantWorkspaceReadyViewComposition {
  const RestaurantWorkspaceReadyViewComposition({
    required this.data,
    required this.controls,
    required this.overviewCallbacks,
    required this.panelActions,
  });

  final RestaurantWorkspaceReadyViewData data;
  final RestaurantWorkspaceControlCallbacks controls;
  final RestaurantWorkspaceOverviewCallbacks overviewCallbacks;
  final RestaurantWorkspacePanelActions panelActions;
}

/// Composes ready workspace presentation data without owning widget layout.
class RestaurantWorkspaceReadyViewComposer {
  RestaurantWorkspaceReadyViewComposer({
    RestaurantOperationalInsightBuilder insightBuilder =
        const RestaurantOperationalInsightBuilder(),
    RestaurantAttentionSignalBuilder attentionSignalBuilder =
        const RestaurantAttentionSignalBuilder(),
    RestaurantAttentionSignalTargetResolver attentionTargetResolver =
        const RestaurantAttentionSignalTargetResolver(),
  }) : this.withDataBuilder(
         dataBuilder: RestaurantWorkspaceReadyViewDataBuilder(
           insightBuilder: insightBuilder,
           attentionSignalBuilder: attentionSignalBuilder,
           attentionTargetResolver: attentionTargetResolver,
         ),
       );

  const RestaurantWorkspaceReadyViewComposer.withDataBuilder({
    required this.dataBuilder,
  });

  final RestaurantWorkspaceReadyViewDataBuilder dataBuilder;

  RestaurantWorkspaceReadyViewComposition compose({
    required RestaurantWorkspaceState state,
    required RestaurantOperatingSnapshot snapshot,
    required RestaurantWorkspaceView selectedView,
    required RestaurantWorkspacePanelFilters filters,
    RestaurantWorkspacePanelFocus? focus,
    required RestaurantWorkspaceViewAvailability viewAvailability,
    required RestaurantWorkspaceController controller,
    required RestaurantWorkspacePreferencesController preferencesController,
    required RestaurantWorkspaceActionCoordinator actionCoordinator,
    required RestaurantWorkspacePreferenceCoordinator preferenceCoordinator,
    RestaurantReservationQrPanelBinding? reservationQrPanelBinding,
  }) {
    final effectiveReservationQrPanelBinding = reservationQrPanelBinding == null
        ? null
        : RestaurantWorkspaceReservationQrBindingFactory(
            actionCoordinator: actionCoordinator,
          ).bind(reservationQrPanelBinding);

    return RestaurantWorkspaceReadyViewComposition(
      data: dataBuilder.build(
        snapshot: snapshot,
        updatedAt: state.updatedAt,
        isRefreshing: state.isRefreshing,
        selectedView: selectedView,
        filters: filters,
        focus: focus,
        viewAvailability: viewAvailability,
        activities: state.activities,
      ),
      controls: RestaurantWorkspaceControlCallbacks(
        onRefresh: controller.refresh,
        onViewChanged: preferenceCoordinator.selectView,
        onReset: preferenceCoordinator.resetFilters,
        onClearLens: preferencesController.clearLens,
        onLensSelected: preferenceCoordinator.selectActiveLens,
        onClearMenuSearch: preferencesController.clearMenuSearch,
        onClearReservationSearch: preferencesController.clearReservationSearch,
        onPresetSelected: preferenceCoordinator.selectPreset,
      ),
      overviewCallbacks: RestaurantWorkspaceOverviewCallbacks(
        onBriefingItemSelected: preferenceCoordinator.selectBriefingItem,
        onInsightSelected: preferenceCoordinator.selectInsight,
        onAttentionSignalSelected: preferenceCoordinator.selectAttentionSignal,
      ),
      panelActions: RestaurantWorkspacePanelActions(
        onBriefingActionSelected: actionCoordinator.applyBriefingAction,
        onCompleteTask: actionCoordinator.completeTask,
        onResolveMenuRisk: actionCoordinator.resolveMenuRisk,
        onReviewCatalogItem: actionCoordinator.reviewCatalogItem,
        onReviewRecipeProduction: actionCoordinator.reviewRecipeProduction,
        onStationStatusChanged: actionCoordinator.updateStationStatus,
        onZoneStatusChanged: actionCoordinator.updateZoneStatus,
        onReservationStatusChanged: actionCoordinator.updateReservationStatus,
        onFloorFilterChanged: preferencesController.selectFloorFilter,
        onKitchenFilterChanged: preferencesController.selectKitchenFilter,
        onReservationFilterChanged:
            preferencesController.selectReservationFilter,
        onMenuFilterChanged: preferencesController.selectMenuFilter,
        onMenuSearchQueryChanged: preferencesController.setMenuSearchQuery,
        onReservationSearchQueryChanged:
            preferencesController.setReservationSearchQuery,
        onMenuSortChanged: preferencesController.selectMenuSort,
        onTaskFilterChanged: preferencesController.selectTaskFilter,
        onActivityFilterChanged: preferencesController.selectActivityFilter,
        reservationQrPanelBinding: effectiveReservationQrPanelBinding,
      ),
    );
  }
}
