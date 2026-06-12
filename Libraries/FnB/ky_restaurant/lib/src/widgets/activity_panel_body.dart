import 'package:flutter/material.dart';

import '../models/activity_panel_data.dart';
import '../models/restaurant_activity_filter.dart';
import '../models/restaurant_operation_activity.dart';
import 'activity_card.dart';
import 'filtered_panel_body.dart';
import 'restaurant_activity_filter_bar.dart';
import 'restaurant_empty_state.dart';
import 'restaurant_spaced_list.dart';

/// Builds the recent activity panel body from filters and visible activities.
class RestaurantActivityPanelBody extends StatelessWidget {
  const RestaurantActivityPanelBody({
    super.key,
    required this.data,
    required this.onFilterChanged,
    required this.onShowAll,
  });

  final RestaurantActivityPanelData data;
  final ValueChanged<RestaurantActivityFilter> onFilterChanged;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return RestaurantFilteredPanelBody(
      hasItems: data.hasActivities,
      hasVisibleItems: data.hasVisibleActivities,
      emptyState: const RestaurantEmptyState(
        icon: Icons.checklist_rtl_rounded,
        message:
            'Actions will appear here after floor, kitchen, task, or menu updates.',
      ),
      controls: RestaurantActivityFilterBar(
        activities: data.activities,
        selectedFilter: data.selectedFilter,
        onFilterChanged: onFilterChanged,
      ),
      emptyResultsState: RestaurantEmptyState(
        icon: Icons.checklist_rtl_rounded,
        message:
            'No ${data.selectedFilter.label.toLowerCase()} actions recorded yet.',
        actionLabel: 'Show all',
        onAction: onShowAll,
      ),
      results: _ActivityList(activities: data.visibleActivities),
    );
  }
}

/// Renders visible activity cards with consistent spacing.
class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.activities});

  final List<RestaurantOperationActivity> activities;

  @override
  Widget build(BuildContext context) {
    return RestaurantSpacedList<RestaurantOperationActivity>(
      items: activities,
      itemBuilder: (context, activity, index) {
        return RestaurantActivityCard(activity: activity);
      },
    );
  }
}
