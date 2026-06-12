import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class Shipment {
  final String id;
  final String trackingNumber;
  final String origin;
  final String destination;
  final DateTime estimatedDelivery;
  final ShipmentStatus status;
  final double progress;
  const Shipment({
    required this.id,
    required this.trackingNumber,
    required this.origin,
    required this.destination,
    required this.estimatedDelivery,
    required this.status,
    required this.progress,
  });
}
