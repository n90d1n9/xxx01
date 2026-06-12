import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/health.dart';
import 'health_signal_tile.dart';
import 'health_status_pill.dart';
import 'health_visuals.dart';
import 'panel_header.dart';
import 'panel_surface.dart';
import 'responsive_wrap_grid.dart';

class HealthPanel extends StatelessWidget {
  final HealthSummary health;

  const HealthPanel({super.key, required this.health});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = healthToneColors(
      theme.colorScheme,
      health.tone,
      borderAlpha: 0.2,
    );

    return PanelSurface(
      color: colors.background,
      border: Border.all(color: colors.border),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelHeader(
            icon: healthPanelIcon(health.tone),
            title: health.title,
            subtitle: health.message,
            iconBackgroundColor: colors.foregroundTint(),
            iconForegroundColor: colors.foreground,
            subtitleFontWeight: FontWeight.w700,
            trailing: HealthStatusPill(tone: health.tone),
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          ResponsiveWrapGrid(
            itemCount: health.signals.length,
            columnsForWidth: _signalColumnsForWidth,
            itemBuilder: (context, index, width) {
              return HealthSignalTile(
                width: width,
                signal: health.signals[index],
              );
            },
          ),
        ],
      ),
    );
  }
}

int _signalColumnsForWidth(double width) {
  if (width >= 760) return 3;
  if (width >= 520) return 2;
  return 1;
}
