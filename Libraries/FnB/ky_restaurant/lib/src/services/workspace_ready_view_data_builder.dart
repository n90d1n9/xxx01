import '../models/restaurant_models.dart';
import '../models/restaurant_operation_activity.dart';
import '../models/restaurant_operational_insight.dart';
import '../models/restaurant_workspace_panel_filters.dart';
import '../models/restaurant_workspace_panel_focus.dart';
import '../models/restaurant_workspace_preset.dart';
import '../models/restaurant_workspace_view.dart';
import '../models/restaurant_workspace_view_availability.dart';
import '../models/workspace_ready_view_data.dart';
import 'attention_signal_builder.dart';
import 'attention_signal_target_resolver.dart';
import 'restaurant_operational_insight_builder.dart';

/// Builds the immutable presentation data consumed by the ready workspace view.
class RestaurantWorkspaceReadyViewDataBuilder {
  const RestaurantWorkspaceReadyViewDataBuilder({
    this.insightBuilder = const RestaurantOperationalInsightBuilder(),
    this.attentionSignalBuilder = const RestaurantAttentionSignalBuilder(),
    this.attentionTargetResolver =
        const RestaurantAttentionSignalTargetResolver(),
  });

  final RestaurantOperationalInsightBuilder insightBuilder;
  final RestaurantAttentionSignalBuilder attentionSignalBuilder;
  final RestaurantAttentionSignalTargetResolver attentionTargetResolver;

  RestaurantWorkspaceReadyViewData build({
    required RestaurantOperatingSnapshot snapshot,
    required RestaurantWorkspaceView selectedView,
    required RestaurantWorkspacePanelFilters filters,
    RestaurantWorkspacePanelFocus? focus,
    required RestaurantWorkspaceViewAvailability viewAvailability,
    Iterable<RestaurantOperationActivity> activities = const [],
    DateTime? updatedAt,
    bool isRefreshing = false,
  }) {
    final availableViews = viewAvailability.views;
    final availablePresets = RestaurantWorkspacePreset.values
        .where((preset) => viewAvailability.contains(preset.view))
        .toList(growable: false);
    final selectedPreset = RestaurantWorkspacePreset.selectedFor(
      selectedView: selectedView,
      filters: filters,
      presets: availablePresets,
    );
    final insights = insightBuilder
        .build(snapshot)
        .where((insight) => viewAvailability.contains(insight.targetView))
        .toList(growable: false);
    final selectedInsight = RestaurantOperationalInsight.selectedFor(
      selectedView: selectedView,
      filters: filters,
      insights: insights,
    );
    final rawAttentionQueue = attentionSignalBuilder.build(snapshot);
    final attentionQueue = RestaurantAttentionSignalQueue.fromSignals(
      rawAttentionQueue.signals.where(
        (signal) => attentionTargetResolver.canOpen(signal, viewAvailability),
      ),
    );
    final selectedAttentionSignal = attentionTargetResolver.selectedSignalFor(
      selectedView: selectedView,
      selectedFilters: filters,
      signals: attentionQueue.attentionSignals,
      viewAvailability: viewAvailability,
      selectedFocus: focus,
    );

    return RestaurantWorkspaceReadyViewData(
      snapshot: snapshot,
      updatedAt: updatedAt,
      isRefreshing: isRefreshing,
      selectedView: selectedView,
      filters: filters,
      availableViews: availableViews,
      availablePresets: availablePresets,
      selectedPreset: selectedPreset,
      activities: activities,
      insights: insights,
      attentionQueue: attentionQueue,
      panelFocus: focus,
      selectedInsight: selectedInsight,
      selectedAttentionSignal: selectedAttentionSignal,
    );
  }
}
