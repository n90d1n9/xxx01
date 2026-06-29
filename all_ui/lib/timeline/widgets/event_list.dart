import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/filtered_event_provider.dart';
import 'empty_state.dart';
import 'event_card.dart';

class EventsList extends ConsumerWidget {
  const EventsList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(filteredEventsProvider);
    if (events.isEmpty) return const SliverFillRemaining(child: EmptyState());
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => EventCard(event: events[index]),
        childCount: events.length,
      ),
    );
  }
}
