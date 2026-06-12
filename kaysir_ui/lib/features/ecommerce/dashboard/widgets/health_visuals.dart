import 'package:flutter/material.dart';

import '../models/health.dart';
import 'tone.dart';

IconData healthPanelIcon(HealthTone tone) {
  return switch (tone) {
    HealthTone.success => Icons.verified_outlined,
    HealthTone.warning => Icons.crisis_alert_outlined,
    HealthTone.danger => Icons.report_gmailerrorred_outlined,
  };
}

IconData healthStatusIcon(HealthTone tone) {
  return switch (tone) {
    HealthTone.success => Icons.check_circle_outline,
    HealthTone.warning => Icons.manage_search_outlined,
    HealthTone.danger => Icons.priority_high_outlined,
  };
}

String healthStatusLabel(HealthTone tone) {
  return switch (tone) {
    HealthTone.success => 'Ready',
    HealthTone.warning => 'Review',
    HealthTone.danger => 'Critical',
  };
}

IconData healthSignalIcon(String id) {
  return switch (id) {
    'profiles' => Icons.view_quilt_outlined,
    'modules' => Icons.extension_outlined,
    'actions' => Icons.bolt_outlined,
    'channel_coverage' => Icons.route_outlined,
    'promise_policy' => Icons.rule_folder_outlined,
    'order_attention' => Icons.receipt_long_outlined,
    _ => Icons.insights_outlined,
  };
}

ToneColors healthToneColors(
  ColorScheme scheme,
  HealthTone tone, {
  double borderAlpha = 0.18,
}) {
  return toneColors(
    scheme,
    healthVisualTone(tone),
    backgroundAlpha: healthBackgroundAlpha(tone),
    borderAlpha: borderAlpha,
  );
}

VisualTone healthVisualTone(HealthTone tone) {
  return switch (tone) {
    HealthTone.success => VisualTone.success,
    HealthTone.warning => VisualTone.warning,
    HealthTone.danger => VisualTone.danger,
  };
}

double healthBackgroundAlpha(HealthTone tone) {
  return switch (tone) {
    HealthTone.success => 0.18,
    HealthTone.warning => 0.22,
    HealthTone.danger => 0.24,
  };
}
