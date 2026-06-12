import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

class WeeklyStudyTime {
  final int weekNumber;
  final Map<SubjectCategory, int> minutesPerSubject;
  final int totalMinutes;
  WeeklyStudyTime({
    required this.weekNumber,
    required this.minutesPerSubject,
    required this.totalMinutes,
  });
}
