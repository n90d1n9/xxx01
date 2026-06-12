import 'package:flutter/material.dart';

import '../models/restaurant_operational_briefing.dart';
import '../models/restaurant_models.dart';
import '../services/restaurant_briefing_builder.dart';
import 'briefing_panel_body.dart';
import 'panel_header_badges.dart';
import 'restaurant_panel.dart';

/// Shows ranked operational briefing recommendations for the active snapshot.
class RestaurantBriefingPanel extends StatelessWidget {
  const RestaurantBriefingPanel({
    super.key,
    required this.snapshot,
    this.builder = const RestaurantBriefingBuilder(),
    this.onActionSelected,
  });

  final RestaurantOperatingSnapshot snapshot;
  final RestaurantBriefingBuilder builder;
  final ValueChanged<RestaurantBriefingAction>? onActionSelected;

  @override
  Widget build(BuildContext context) {
    final items = builder.build(snapshot);

    return RestaurantPanel(
      title: 'Operational briefing',
      subtitle: 'Next moves from the live service snapshot.',
      leading: const Icon(Icons.auto_awesome_motion_outlined),
      headerBadges: RestaurantPanelHeaderBadges.briefing(items),
      child: RestaurantBriefingPanelBody(
        items: items,
        onActionSelected: onActionSelected,
      ),
    );
  }
}
