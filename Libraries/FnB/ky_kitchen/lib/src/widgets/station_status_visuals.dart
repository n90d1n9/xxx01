import 'package:flutter/material.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

/// Resolves kitchen status colors used by station board widgets.
Color kitchenStatusColor(ColorScheme colors, FnbServiceStatus status) {
  return switch (status) {
    FnbServiceStatus.calm => colors.primary,
    FnbServiceStatus.busy => colors.tertiary,
    FnbServiceStatus.critical => colors.error,
    FnbServiceStatus.blocked => colors.error,
  };
}

/// Resolves kitchen status icons used by station board widgets.
IconData kitchenStatusIcon(FnbServiceStatus status) {
  return switch (status) {
    FnbServiceStatus.calm => Icons.check_circle_outline_rounded,
    FnbServiceStatus.busy => Icons.local_fire_department_outlined,
    FnbServiceStatus.critical => Icons.priority_high_rounded,
    FnbServiceStatus.blocked => Icons.block_rounded,
  };
}
