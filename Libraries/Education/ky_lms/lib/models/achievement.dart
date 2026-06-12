import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'achievement_type.dart';
import 'achievement_tier.dart';

class Achievement {
  final String id;
  final AchievementType type;
  final String title;
  final String description;
  final String icon;
  final DateTime? unlockedAt;
  final int points;
  final AchievementTier tier;
  final double progress;
  Achievement({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
    required this.points,
    required this.tier,
    this.progress = 0.0,
  });
  bool get isUnlocked => unlockedAt != null;
}
