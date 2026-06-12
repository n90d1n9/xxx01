import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import '../services/restaurant_priority_selector.dart';
import '../services/service_pulse_builder.dart';
import 'panel_header_badges.dart';
import 'restaurant_panel.dart';
import 'service_panel_body.dart';

/// Shows cross-functional service pulse signals for the current restaurant snapshot.
class RestaurantServicePanel extends StatelessWidget {
  const RestaurantServicePanel({
    super.key,
    required this.snapshot,
    this.prioritySelector = const RestaurantPrioritySelector(),
  });

  final RestaurantOperatingSnapshot snapshot;
  final RestaurantPrioritySelector prioritySelector;

  @override
  Widget build(BuildContext context) {
    final metrics = RestaurantServicePulseBuilder(
      prioritySelector: prioritySelector,
    ).build(snapshot);

    return RestaurantPanel(
      title: 'Service pulse',
      subtitle: 'Priority signals across floor, menu, and kitchen.',
      leading: const Icon(Icons.monitor_heart_outlined),
      headerBadges: RestaurantPanelHeaderBadges.service(snapshot),
      child: RestaurantServicePanelBody(metrics: metrics),
    );
  }
}
