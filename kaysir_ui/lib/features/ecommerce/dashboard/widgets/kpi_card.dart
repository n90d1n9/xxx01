import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import 'metric_block.dart';
import 'panel_surface.dart';
import 'tone.dart';
import 'tonal_icon_badge.dart';

enum KpiTone { primary, secondary, success, danger }

class KpiCard extends StatelessWidget {
  const KpiCard({
    required this.width,
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.tone,
    super.key,
  });

  final double width;
  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final KpiTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = toneColors(
      theme.colorScheme,
      _visualTone,
      backgroundAlpha: _backgroundAlpha,
      borderAlpha: 0.2,
    );

    return SizedBox(
      width: width,
      child: PanelSurface(
        padding: const EdgeInsets.all(14),
        color: colors.background,
        border: Border.all(color: colors.border),
        elevated: true,
        child: Row(
          children: [
            TonalIconBadge(icon: icon, colors: colors),
            const SizedBox(width: POSUiTokens.gapLarge),
            Expanded(
              child: MetricBlock(
                label: label,
                value: value,
                detail: detail,
                scale: MetricBlockScale.prominent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  VisualTone get _visualTone {
    return switch (tone) {
      KpiTone.primary => VisualTone.primary,
      KpiTone.secondary => VisualTone.secondary,
      KpiTone.success => VisualTone.success,
      KpiTone.danger => VisualTone.danger,
    };
  }

  double get _backgroundAlpha {
    return switch (tone) {
      KpiTone.primary => 0.24,
      KpiTone.secondary || KpiTone.success => 0.28,
      KpiTone.danger => 0.3,
    };
  }
}
