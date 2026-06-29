import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'major.dart';

class Faculty {
  final String id;
  final String name;
  final List<Major> majors;
  Faculty({required this.id, required this.name, required this.majors});
}
