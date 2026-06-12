import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ShipmentStatus {
  final String id;
  final String name;
  final Color color;
  const ShipmentStatus({
    required this.id,
    required this.name,
    required this.color,
  });
}
