import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

class UniversityChoice {
  final int priority;
  final String universityId;
  final String majorId;
  final double requiredScore;
  final double gapFromCurrent;
  final double admissionProbability;
  UniversityChoice({
    required this.priority,
    required this.universityId,
    required this.majorId,
    required this.requiredScore,
    required this.gapFromCurrent,
    required this.admissionProbability,
  });
}
