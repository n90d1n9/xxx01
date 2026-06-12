import 'package:flutter/foundation.dart';

import '../models/restaurant_models.dart';
import '../models/restaurant_operational_briefing.dart';
import '../models/restaurant_operational_insight.dart';
import '../models/restaurant_workspace_panel_filters.dart';
import '../models/restaurant_workspace_preset.dart';
import '../models/restaurant_workspace_view.dart';

/// Groups callbacks for the loaded workspace control surface.
class RestaurantWorkspaceControlCallbacks {
  const RestaurantWorkspaceControlCallbacks({
    required this.onRefresh,
    required this.onViewChanged,
    required this.onPresetSelected,
    this.onReset,
    this.onClearLens,
    this.onLensSelected,
    this.onClearMenuSearch,
    this.onClearReservationSearch,
  });

  final VoidCallback onRefresh;
  final ValueChanged<RestaurantWorkspaceView> onViewChanged;
  final ValueChanged<RestaurantWorkspacePreset> onPresetSelected;
  final VoidCallback? onReset;
  final ValueChanged<RestaurantWorkspaceActiveLens>? onClearLens;
  final ValueChanged<RestaurantWorkspaceActiveLens>? onLensSelected;
  final VoidCallback? onClearMenuSearch;
  final VoidCallback? onClearReservationSearch;
}

/// Groups callbacks for the loaded workspace overview section.
class RestaurantWorkspaceOverviewCallbacks {
  const RestaurantWorkspaceOverviewCallbacks({
    this.onBriefingItemSelected,
    this.onInsightSelected,
    this.onAttentionSignalSelected,
  });

  final ValueChanged<RestaurantBriefingItem>? onBriefingItemSelected;
  final ValueChanged<RestaurantOperationalInsight>? onInsightSelected;
  final ValueChanged<RestaurantAttentionSignal>? onAttentionSignalSelected;
}
