import 'package:flutter/material.dart';

import '../models/restaurant_operational_briefing.dart';
import 'briefing_card.dart';
import 'restaurant_spaced_list.dart';

/// Renders operational briefing recommendations as a consistent card stack.
class RestaurantBriefingPanelBody extends StatelessWidget {
  const RestaurantBriefingPanelBody({
    super.key,
    required this.items,
    this.onActionSelected,
  });

  final List<RestaurantBriefingItem> items;
  final ValueChanged<RestaurantBriefingAction>? onActionSelected;

  @override
  Widget build(BuildContext context) {
    return RestaurantSpacedList<RestaurantBriefingItem>(
      items: items,
      itemBuilder: (context, item, index) {
        return RestaurantBriefingCard(
          item: item,
          onActionSelected: onActionSelected,
        );
      },
    );
  }
}
