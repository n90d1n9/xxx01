import 'package:flutter/material.dart';

import '../models/health.dart';
import 'health_visuals.dart';
import 'metric_pill.dart';

class HealthStatusPill extends StatelessWidget {
  const HealthStatusPill({required this.tone, super.key});

  final HealthTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = healthToneColors(theme.colorScheme, tone);

    return MetricPill(
      icon: Icon(healthStatusIcon(tone)),
      label: healthStatusLabel(tone),
      colors: colors,
    );
  }
}
