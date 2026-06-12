import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

class PassingGrade {
  final String majorId;
  final Map<int, double> historicalScores;
  final double predictedScore;
  final double lowestScore;
  final double averageScore;
  final double highestScore;
  PassingGrade({
    required this.majorId,
    required this.historicalScores,
    required this.predictedScore,
    required this.lowestScore,
    required this.averageScore,
    required this.highestScore,
  });
}
