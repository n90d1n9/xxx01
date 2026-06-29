import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

class ScoreHistory {
  final DateTime date;
  final double score;
  final String tryOutId;
  ScoreHistory({
    required this.date,
    required this.score,
    required this.tryOutId,
  });
}
