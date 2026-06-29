import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/user_profile_provider.dart';

class AchievementsDialog extends ConsumerWidget {
  const AchievementsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    final allAchievements = [
      {
        'id': 'first_view',
        'title': 'Time Traveler',
        'description': 'View your first event',
        'icon': Icons.visibility,
      },
      {
        'id': 'favorite_10',
        'title': 'Collector',
        'description': 'Favorite 10 events',
        'icon': Icons.favorite,
      },
      {
        'id': 'streak_7',
        'title': 'Week Warrior',
        'description': '7 day streak',
        'icon': Icons.local_fire_department,
      },
      {
        'id': 'quiz_master',
        'title': 'Quiz Master',
        'description': 'Perfect score on quiz',
        'icon': Icons.school,
      },
      {
        'id': 'explorer',
        'title': 'Explorer',
        'description': 'View 50 events',
        'icon': Icons.explore,
      },
      {
        'id': 'scholar',
        'title': 'Scholar',
        'description': 'Earn 1000 points',
        'icon': Icons.stars,
      },
    ];

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
                  'Achievements',
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
            const SizedBox(height: 8),
            Text(
              '${userProfile.achievements.length}/${allAchievements.length} unlocked',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: allAchievements.length,
                itemBuilder: (context, index) {
                  final achievement = allAchievements[index];
                  final isUnlocked = userProfile.achievements.contains(
                    achievement['id'],
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          isUnlocked
                              ? const Color(0xFF6C63FF).withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isUnlocked
                                ? const Color(0xFF6C63FF)
                                : Colors.white24,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isUnlocked
                                    ? const Color(0xFF6C63FF)
                                    : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            achievement['icon'] as IconData,
                            color: isUnlocked ? Colors.white : Colors.white38,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                achievement['title'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isUnlocked
                                          ? Colors.white
                                          : Colors.white54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                achievement['description'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isUnlocked
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isUnlocked)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF6C63FF),
                          ),
                      ],
                    ),
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
