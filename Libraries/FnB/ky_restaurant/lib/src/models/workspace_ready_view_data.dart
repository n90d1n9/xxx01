import 'restaurant_models.dart';
import 'restaurant_operation_activity.dart';
import 'restaurant_operational_insight.dart';
import 'restaurant_workspace_panel_filters.dart';
import 'restaurant_workspace_panel_focus.dart';
import 'restaurant_workspace_preset.dart';
import 'restaurant_workspace_view.dart';

/// Carries immutable presentation data for the loaded workspace view.
class RestaurantWorkspaceReadyViewData {
  RestaurantWorkspaceReadyViewData({
    required this.snapshot,
    required this.selectedView,
    required this.filters,
    required Iterable<RestaurantWorkspaceView> availableViews,
    required Iterable<RestaurantWorkspacePreset> availablePresets,
    required Iterable<RestaurantOperationActivity> activities,
    required Iterable<RestaurantOperationalInsight> insights,
    RestaurantAttentionSignalQueue? attentionQueue,
    this.updatedAt,
    this.isRefreshing = false,
    this.selectedPreset,
    this.selectedInsight,
    this.selectedAttentionSignal,
    this.panelFocus,
  }) : availableViews = List<RestaurantWorkspaceView>.unmodifiable(
         availableViews,
       ),
       availablePresets = List<RestaurantWorkspacePreset>.unmodifiable(
         availablePresets,
       ),
       activities = List<RestaurantOperationActivity>.unmodifiable(activities),
       insights = List<RestaurantOperationalInsight>.unmodifiable(insights),
       attentionQueue =
           attentionQueue ??
           RestaurantAttentionSignalQueue.fromSignals(const []);

  final RestaurantOperatingSnapshot snapshot;
  final RestaurantWorkspaceView selectedView;
  final RestaurantWorkspacePanelFilters filters;
  final List<RestaurantWorkspaceView> availableViews;
  final List<RestaurantWorkspacePreset> availablePresets;
  final List<RestaurantOperationActivity> activities;
  final List<RestaurantOperationalInsight> insights;
  final RestaurantAttentionSignalQueue attentionQueue;
  final DateTime? updatedAt;
  final bool isRefreshing;
  final RestaurantWorkspacePreset? selectedPreset;
  final RestaurantOperationalInsight? selectedInsight;
  final RestaurantAttentionSignal? selectedAttentionSignal;
  final RestaurantWorkspacePanelFocus? panelFocus;

  bool get hasPresets => availablePresets.isNotEmpty;

  bool get hasInsights => insights.isNotEmpty;

  bool get hasAttentionSignals => attentionQueue.hasAttention;

  bool get hasSelectedAttentionSignal => selectedAttentionSignal != null;

  bool get hasPanelFocus => panelFocus != null;
}
