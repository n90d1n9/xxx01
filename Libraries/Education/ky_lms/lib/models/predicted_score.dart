import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

class PredictedScore {
  final double predictedSNBT;
  final double confidence;
  final DateTime predictionDate;
  final Map<SubjectCategory, double> subjectPredictions;
  PredictedScore({
    required this.predictedSNBT,
    required this.confidence,
    required this.predictionDate,
    required this.subjectPredictions,
  });
}
