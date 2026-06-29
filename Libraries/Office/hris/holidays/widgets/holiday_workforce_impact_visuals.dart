import 'package:flutter/material.dart';

import '../models/holiday_workforce_impact_models.dart';

Color workforceImpactLevelColor(HolidayWorkforceImpactLevel level) {
  return switch (level) {
    HolidayWorkforceImpactLevel.high => Colors.red.shade700,
    HolidayWorkforceImpactLevel.medium => Colors.orange.shade700,
    HolidayWorkforceImpactLevel.low => Colors.green.shade700,
  };
}

String formatWorkforceImpactDaysUntil(int daysUntil) {
  if (daysUntil == 0) return 'today';
  if (daysUntil == 1) return '1 day';
  return '$daysUntil days';
}

String pluralizeWorkforceLabel(String singular, int count) {
  if (count == 1) return singular;
  return '${singular}s';
}
