import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import '../models/restaurant_operational_briefing.dart';
import '../models/restaurant_operational_insight.dart';
import 'restaurant_attention_signal_strip.dart';
import 'restaurant_metric_grid.dart';
import 'restaurant_operational_insight_grid.dart';
import 'restaurant_shift_focus_strip.dart';

/// Displays shift focus, pulse metrics, and optional operating insights.
class RestaurantWorkspaceOverviewSection extends StatelessWidget {
  const RestaurantWorkspaceOverviewSection({
    super.key,
    required this.snapshot,
    required this.attentionQueue,
    this.insights = const [],
    this.selectedInsight,
    this.selectedAttentionSignal,
    this.onBriefingItemSelected,
    this.onInsightSelected,
    this.onAttentionSignalSelected,
  });

  final RestaurantOperatingSnapshot snapshot;
  final RestaurantAttentionSignalQueue attentionQueue;
  final List<RestaurantOperationalInsight> insights;
  final RestaurantOperationalInsight? selectedInsight;
  final RestaurantAttentionSignal? selectedAttentionSignal;
  final ValueChanged<RestaurantBriefingItem>? onBriefingItemSelected;
  final ValueChanged<RestaurantOperationalInsight>? onInsightSelected;
  final ValueChanged<RestaurantAttentionSignal>? onAttentionSignalSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RestaurantShiftFocusStrip(
          snapshot: snapshot,
          onItemSelected: onBriefingItemSelected,
        ),
        if (attentionQueue.hasAttention) ...[
          const SizedBox(height: 16),
          RestaurantAttentionSignalStrip(
            queue: attentionQueue,
            selectedSignal: selectedAttentionSignal,
            onSignalSelected: onAttentionSignalSelected,
          ),
        ],
        const SizedBox(height: 16),
        RestaurantMetricGrid(metrics: snapshot.metrics),
        if (insights.isNotEmpty) ...[
          const SizedBox(height: 16),
          RestaurantOperationalInsightGrid(
            insights: insights,
            selectedInsight: selectedInsight,
            onInsightSelected: onInsightSelected,
          ),
        ],
      ],
    );
  }
}
