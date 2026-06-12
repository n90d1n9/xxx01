import 'package:flutter/material.dart';

import '../models/restaurant_reservation_priority_queue.dart';
import 'priority_reservation_card.dart';
import 'restaurant_empty_state.dart';
import 'restaurant_section_header.dart';
import 'restaurant_section_surface.dart';
import 'restaurant_spaced_list.dart';

/// Shows ranked reservation actions that need the host team's next focus.
class RestaurantReservationNextUpList extends StatelessWidget {
  const RestaurantReservationNextUpList({
    super.key,
    required this.queue,
    this.title = 'Next up',
  });

  final RestaurantReservationPriorityQueue queue;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (!queue.hasItems) {
      return const RestaurantEmptyState(
        icon: Icons.task_alt_rounded,
        message: 'No priority reservation actions in this lens.',
      );
    }

    return Semantics(
      container: true,
      label: _semanticLabel(title, queue),
      child: RestaurantSectionSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantSectionHeader(
              icon: Icons.low_priority_rounded,
              title: title,
              trailingLabel: queue.itemLabel,
            ),
            const SizedBox(height: 12),
            RestaurantSpacedList(
              items: queue.items,
              spacing: 10,
              itemBuilder: (context, item, index) {
                return RestaurantPriorityReservationCard(item: item);
              },
            ),
          ],
        ),
      ),
    );
  }
}

String _semanticLabel(String title, RestaurantReservationPriorityQueue queue) {
  final itemLabels = queue.items.map(
    (item) =>
        '${item.guestLabel}: ${item.urgencyLabel}, ${item.actionLabel}, '
        '${item.reservation.partyLabel}',
  );
  return '$title. ${queue.itemLabel}. ${itemLabels.join('. ')}.';
}
