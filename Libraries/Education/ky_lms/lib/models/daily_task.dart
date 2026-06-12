import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'subject_category.dart';

class DailyTask {
  final String id;
  final String title;
  final SubjectCategory subject;
  final DateTime dueDate;
  final bool isCompleted;
  final int estimatedMinutes;
  DailyTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.isCompleted,
    required this.estimatedMinutes,
  });
}
