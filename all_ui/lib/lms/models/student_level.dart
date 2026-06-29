import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'achievement_tier.dart';

class StudentLevel {
  final int level;
  final int currentXP;
  final int xpForNextLevel;
  final AchievementTier tier;
  final List<String> unlockedPerks;
  StudentLevel({
    required this.level,
    required this.currentXP,
    required this.xpForNextLevel,
    required this.tier,
    required this.unlockedPerks,
  });
  double get progressToNextLevel => currentXP / xpForNextLevel;
}
