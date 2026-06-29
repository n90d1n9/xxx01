import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/filtered_event_provider.dart';
import 'empty_state.dart';
import 'timelone_event_card.dart';

class VerticalTimeline extends ConsumerWidget {
  const VerticalTimeline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(filteredEventsProvider);

    if (events.isEmpty) {
      return const SliverFillRemaining(child: EmptyState());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final event = events[index];
        final isLeft = index % 2 == 0;

        return TimelineEventCard(
          event: event,
          isLeft: isLeft,
          isFirst: index == 0,
          isLast: index == events.length - 1,
        );
      }, childCount: events.length),
    );
  }
}
