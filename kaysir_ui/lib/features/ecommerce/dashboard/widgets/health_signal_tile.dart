import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/health.dart';
import 'health_visuals.dart';
import 'inset_surface.dart';
import 'metric_block.dart';
import 'tonal_icon_badge.dart';

class HealthSignalTile extends StatelessWidget {
  const HealthSignalTile({
    required this.width,
    required this.signal,
    super.key,
  });

  final double width;
  final HealthSignal signal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = healthToneColors(
      theme.colorScheme,
      signal.tone,
      borderAlpha: 0.16,
    );

    return SizedBox(
      width: width,
      child: InsetSurface(
        color: theme.colorScheme.surface.withValues(alpha: 0.68),
        border: Border.all(color: colors.border),
        child: Row(
          children: [
            TonalIconBadge(
              icon: healthSignalIcon(signal.id),
              size: 30,
              iconSize: 17,
              colors: colors,
              backgroundAlpha: 0.1,
            ),
            const SizedBox(width: POSUiTokens.gapLarge),
            Expanded(
              child: MetricBlock(
                label: signal.label,
                value: signal.value,
                detail: signal.detail,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
