import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_movement_record.dart';
import 'movement_direction_visuals.dart';

/// Status pill that presents the type of a timeline movement record.
class InventoryMovementTimelineTypePill extends StatelessWidget {
  const InventoryMovementTimelineTypePill({super.key, required this.record});

  final InventoryMovementRecord record;

  @override
  Widget build(BuildContext context) {
    final style = movementDirectionVisuals(context, record.direction);
    return AppStatusPill(
      label: record.typeLabel,
      icon: style.icon,
      color: style.color,
      maxWidth: 140,
    );
  }
}
