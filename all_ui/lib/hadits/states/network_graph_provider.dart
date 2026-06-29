import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

final is3DModeProvider = StateProvider<bool>((ref) => false);
final rotationXProvider = StateProvider<double>((ref) => 0.0);
final rotationYProvider = StateProvider<double>((ref) => 0.0);
final hoveredNodeProvider = StateProvider<String?>((ref) => null);
final nodePositionsProvider = StateProvider<Map<String, Offset>>((ref) => {});
