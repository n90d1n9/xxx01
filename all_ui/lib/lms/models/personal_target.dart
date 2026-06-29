import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'university_choice.dart';
import 'study_plan.dart';

class PersonalTarget {
  final String studentId;
  final List<UniversityChoice> choices;
  final double currentScore;
  final DateTime targetExamDate;
  final Map<SubjectCategory, double> subjectGaps;
  final StudyPlan studyPlan;
  PersonalTarget({
    required this.studentId,
    required this.choices,
    required this.currentScore,
    required this.targetExamDate,
    required this.subjectGaps,
    required this.studyPlan,
  });
  int get daysUntilExam => targetExamDate.difference(DateTime.now()).inDays;
}
