import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../experiences/default_pos_touch_layout_profiles.dart';
import '../models/pos_touch_layout_profile.dart';
import 'pos_ui.dart';

/// Reusable selector for operator-level POS touch target density.
class POSTouchDensitySelector extends StatelessWidget {
  final POSTouchLayoutDensity profileDensity;
  final POSTouchLayoutDensity selectedDensity;
  final ValueChanged<POSTouchLayoutDensity?> onDensityChanged;
  final bool compact;

  const POSTouchDensitySelector({
    super.key,
    required this.profileDensity,
    required this.selectedDensity,
    required this.onDensityChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usesProfileDefault = selectedDensity == profileDensity;

    return POSSurface(
      padding: EdgeInsets.all(compact ? 10 : 12),
      color: theme.colorScheme.surfaceContainerLowest,
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.72),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const POSIconBadge(icon: Icons.touch_app_outlined, size: 30),
              const SizedBox(width: POSUiTokens.gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Touch density',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      usesProfileDefault
                          ? 'Using profile default: ${profileDensity.label}'
                          : 'Override: ${selectedDensity.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (!usesProfileDefault)
                TextButton.icon(
                  onPressed: () => onDensityChanged(null),
                  icon: const Icon(Icons.undo),
                  label: const Text('Use profile'),
                ),
            ],
          ),
          const SizedBox(height: POSUiTokens.gap),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<POSTouchLayoutDensity>(
              showSelectedIcon: false,
              segments: [
                for (final density in POSTouchLayoutDensity.values)
                  ButtonSegment<POSTouchLayoutDensity>(
                    value: density,
                    icon: Icon(_iconForDensity(density)),
                    label: Text(density.label),
                  ),
              ],
              selected: {selectedDensity},
              onSelectionChanged: (selection) {
                final density = selection.first;
                onDensityChanged(density == profileDensity ? null : density);
              },
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconForDensity(POSTouchLayoutDensity density) {
  switch (density) {
    case POSTouchLayoutDensity.compact:
      return Icons.compress;
    case POSTouchLayoutDensity.comfortable:
      return Icons.grid_view;
    case POSTouchLayoutDensity.spacious:
      return Icons.open_in_full;
    case POSTouchLayoutDensity.kiosk:
      return Icons.fullscreen;
  }
}

@Preview(name: 'POS touch density selector')
Widget posTouchDensitySelectorPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: POSTouchDensitySelector(
          profileDensity: coreCounterTouchLayoutProfile.density,
          selectedDensity: POSTouchLayoutDensity.spacious,
          onDensityChanged: (_) {},
        ),
      ),
    ),
  );
}
