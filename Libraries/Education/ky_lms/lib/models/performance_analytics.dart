import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'score_history.dart';
import 'subject_analytics.dart';
import 'weekly_study_time.dart';
import 'predicted_score.dart';

class PerformanceAnalytics {
  final String studentId;
  final List<ScoreHistory> scoreHistory;
  final Map<SubjectCategory, SubjectAnalytics> subjectAnalytics;
  final List<WeeklyStudyTime> weeklyStudyTime;
  final PredictedScore prediction;
  PerformanceAnalytics({
    required this.studentId,
    required this.scoreHistory,
    required this.subjectAnalytics,
    required this.weeklyStudyTime,
    required this.prediction,
  });
}
