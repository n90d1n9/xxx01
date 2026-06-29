import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../states/events_provider.dart';
import '../states/timeline_provider.dart';
import '../states/user_profile_provider.dart';

class RecentlyViewedDialog extends ConsumerWidget {
  const RecentlyViewedDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final allEvents = ref.watch(eventsProvider);
    final recentEvents =
        userProfile.recentlyViewed
            .map(
              (id) => allEvents.firstWhere(
                (e) => e.id == id,
                orElse: () => allEvents.first,
              ),
            )
            .take(10)
            .toList();

    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recently Viewed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child:
                  recentEvents.isEmpty
                      ? Center(
                        child: Text(
                          'No recently viewed events',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: recentEvents.length,
                        itemBuilder: (context, index) {
                          final event = recentEvents[index];
                          return ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6C63FF).withOpacity(0.3),
                                    const Color(0xFFFF6B9D).withOpacity(0.3),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.history,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              event.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat('MMM d, y').format(event.date),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              ref
                                  .read(timelineProvider.notifier)
                                  .toggleEventExpansion(event.id);
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
