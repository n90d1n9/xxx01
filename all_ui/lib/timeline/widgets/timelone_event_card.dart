import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/historical_event.dart';
import '../states/user_profile_provider.dart';
import 'event_detail_sheet.dart';

class TimelineEventCard extends ConsumerWidget {
  final HistoricalEvent event;
  final bool isLeft;
  final bool isFirst;
  final bool isLast;

  const TimelineEventCard({
    Key? key,
    required this.event,
    required this.isLeft,
    required this.isFirst,
    required this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLeft) ...[
            Expanded(child: _buildCard(context, ref)),
            const SizedBox(width: 16),
            _buildTimeline(),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()),
          ] else ...[
            const Expanded(child: SizedBox()),
            const SizedBox(width: 16),
            _buildTimeline(),
            const SizedBox(width: 16),
            Expanded(child: _buildCard(context, ref)),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        if (!isFirst)
          Container(
            width: 2,
            height: 20,
            color: const Color(0xFF6C63FF).withOpacity(0.3),
          ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Text(
              DateFormat('MMM').format(event.date),
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (!isLast)
          Container(
            width: 2,
            height: 100,
            color: const Color(0xFF6C63FF).withOpacity(0.3),
          ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(userProfileProvider.notifier).addRecentlyViewed(event.id);
        _showEventDetail(context, ref, event);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM d, y').format(event.date),
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetail(
    BuildContext context,
    WidgetRef ref,
    HistoricalEvent event,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EventDetailSheet(event: event),
    );
  }
}
