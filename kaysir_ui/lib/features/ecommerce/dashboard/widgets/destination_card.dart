import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/destination.dart';
import 'action_button.dart';
import 'detail_row.dart';
import 'metric_block.dart';
import 'panel_surface.dart';
import 'tone.dart';

class DestinationCard extends StatelessWidget {
  const DestinationCard({
    required this.width,
    required this.destination,
    required this.onPressed,
    super.key,
  });

  final double width;
  final Destination destination;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = toneColors(
      theme.colorScheme,
      _visualToneForDestination(destination.tone),
      backgroundAlpha: _backgroundAlphaForDestination(destination.tone),
    );

    return SizedBox(
      key: ValueKey('destination_${destination.id}'),
      width: width,
      child: PanelSurface(
        padding: const EdgeInsets.all(14),
        color: colors.background,
        border: Border.all(color: colors.border),
        elevated: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DetailRow(
              icon: destination.icon,
              title: destination.title,
              description: destination.subtitle,
              titleScale: DetailRowTitleScale.standard,
              iconColors: colors,
            ),
            const SizedBox(height: POSUiTokens.gapLarge),
            Row(
              children: [
                Expanded(
                  child: MetricBlock(
                    label: destination.metricLabel,
                    value: destination.metricValue,
                  ),
                ),
                const SizedBox(width: POSUiTokens.gap),
                ActionButton(
                  onPressed: onPressed,
                  icon: Icons.arrow_forward,
                  label: destination.actionLabel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

VisualTone _visualToneForDestination(DestinationTone tone) {
  return switch (tone) {
    DestinationTone.primary => VisualTone.primary,
    DestinationTone.secondary => VisualTone.secondary,
    DestinationTone.success => VisualTone.success,
    DestinationTone.warning => VisualTone.danger,
  };
}

double _backgroundAlphaForDestination(DestinationTone tone) {
  return switch (tone) {
    DestinationTone.primary => 0.22,
    DestinationTone.secondary => 0.24,
    DestinationTone.success || DestinationTone.warning => 0.26,
  };
}
