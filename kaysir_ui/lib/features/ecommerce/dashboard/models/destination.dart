import 'package:flutter/material.dart';

enum DestinationTone { primary, secondary, success, warning }

class Destination {
  final String id;
  final String title;
  final String subtitle;
  final String routePath;
  final String metricLabel;
  final String metricValue;
  final String actionLabel;
  final IconData icon;
  final DestinationTone tone;

  const Destination({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.routePath,
    required this.metricLabel,
    required this.metricValue,
    required this.actionLabel,
    required this.icon,
    required this.tone,
  });
}
