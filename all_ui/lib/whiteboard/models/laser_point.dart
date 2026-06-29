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

class LaserPoint {
  final Offset point;
  final DateTime timestamp;
  LaserPoint({required this.point, required this.timestamp});
  bool get isExpired =>
      DateTime.now().difference(timestamp).inMilliseconds > 1000;
}
