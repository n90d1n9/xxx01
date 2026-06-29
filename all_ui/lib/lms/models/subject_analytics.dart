import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'subject_category.dart';

class SubjectAnalytics {
  final SubjectCategory subject;
  final double averageScore;
  final double trend;
  final List<String> strongTopics;
  final List<String> weakTopics;
  final int questionsAttempted;
  final double accuracy;
  SubjectAnalytics({
    required this.subject,
    required this.averageScore,
    required this.trend,
    required this.strongTopics,
    required this.weakTopics,
    required this.questionsAttempted,
    required this.accuracy,
  });
}
