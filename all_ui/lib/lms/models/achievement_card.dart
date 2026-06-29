import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'achievement.dart';
import 'achievement_tier.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  const AchievementCard({super.key, required this.achievement});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.isUnlocked ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              achievement.isUnlocked
                  ? _getTierColor(achievement.tier)
                  : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color:
                  achievement.isUnlocked
                      ? _getTierColor(achievement.tier).withOpacity(0.1)
                      : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(achievement.icon, style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            achievement.isUnlocked ? Colors.black : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (achievement.isUnlocked)
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: _getTierColor(achievement.tier),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        achievement.isUnlocked
                            ? Colors.grey[600]
                            : Colors.grey[400],
                  ),
                ),
                if (!achievement.isUnlocked && achievement.progress > 0) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: achievement.progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(
                        _getTierColor(achievement.tier),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(achievement.progress * 100).toInt()}% selesai',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '+${achievement.points}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      achievement.isUnlocked
                          ? _getTierColor(achievement.tier)
                          : Colors.grey,
                ),
              ),
              const Text(
                'XP',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFF94A3B8);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFF6366F1);
      case AchievementTier.diamond:
        return const Color(0xFF06B6D4);
    }
  }
}
