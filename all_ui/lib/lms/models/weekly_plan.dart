import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'daily_task.dart';
import 'subject_category.dart';

class WeeklyPlan {
  final int weekNumber;
  final List<DailyTask> tasks;
  final List<SubjectCategory> focusSubjects;
  WeeklyPlan({
    required this.weekNumber,
    required this.tasks,
    required this.focusSubjects,
  });
}
