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

enum DrawingTool {
  pen,
  eraser,
  highlighter,
  line,
  rectangle,
  circle,
  arrow,
  text,
  select,
  stickyNote,
  image,
  laser,
}
