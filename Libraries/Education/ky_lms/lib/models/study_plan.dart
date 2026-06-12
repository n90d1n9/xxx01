import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'weekly_plan.dart';

class StudyPlan {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final List<WeeklyPlan> weeklyPlans;
  final Map<SubjectCategory, int> hoursPerSubject;
  StudyPlan({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.weeklyPlans,
    required this.hoursPerSubject,
  });
}
