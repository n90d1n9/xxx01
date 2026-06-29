import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'university_type.dart';
import 'faculty.dart';

class University {
  final String id;
  final String name;
  final String shortName;
  final String location;
  final String logo;
  final String description;
  final UniversityType type;
  final List<Faculty> faculties;
  final String? imageUrl;
  final double ranking;
  final int totalStudents;
  final String accreditation;
  University({
    required this.id,
    required this.name,
    required this.shortName,
    required this.location,
    required this.logo,
    required this.description,
    required this.type,
    required this.faculties,
    this.imageUrl,
    required this.ranking,
    required this.totalStudents,
    required this.accreditation,
  });
}
