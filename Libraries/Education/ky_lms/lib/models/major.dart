import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'major_category.dart';
import 'passing_grade.dart';

class Major {
  final String id;
  final String name;
  final String facultyId;
  final MajorCategory category;
  final PassingGrade passingGrade;
  final int capacity;
  final int applicants;
  final String description;
  final List<String> careerProspects;
  Major({
    required this.id,
    required this.name,
    required this.facultyId,
    required this.category,
    required this.passingGrade,
    required this.capacity,
    required this.applicants,
    required this.description,
    required this.careerProspects,
  });
  double get competitionRatio => applicants / capacity;
}
