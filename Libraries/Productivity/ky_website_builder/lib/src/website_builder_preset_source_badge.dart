import 'package:flutter/material.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_component_presets.dart';

/// Shows whether a website builder content preset is built-in or saved.
class WebsiteBuilderPresetSourceBadge extends StatelessWidget {
  final WebsiteBuilderComponentPreset preset;
  final bool dense;
  final bool shortLabel;

  const WebsiteBuilderPresetSourceBadge({
    super.key,
    required this.preset,
    this.dense = false,
    this.shortLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCustom = preset.isCustom;
    final label = isCustom ? 'Saved' : (shortLabel ? 'Core' : 'Built-in');
    final foreground =
        isCustom
            ? colorScheme.onTertiaryContainer
            : colorScheme.onSurfaceVariant;
    final background =
        isCustom
            ? colorScheme.tertiaryContainer.withValues(alpha: 0.72)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.76);
    final border =
        isCustom
            ? colorScheme.tertiary.withValues(alpha: 0.28)
            : colorScheme.outlineVariant;

    return KyBuilderBadge(
      key: ValueKey(
        'website-builder-preset-source-${preset.kindKey}-${preset.id}',
      ),
      label: label,
      tooltip: isCustom ? 'Saved preset' : 'Built-in preset',
      backgroundColor: background,
      borderColor: border,
      foregroundColor: foreground,
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 5 : 7,
        vertical: dense ? 1 : 2,
      ),
    );
  }
}
