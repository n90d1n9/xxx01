import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/legacy.dart';

import 'drawing_path.dart';

class Template {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<DrawingPath> paths;
  Template({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.paths,
  });
}
