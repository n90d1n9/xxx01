import 'package:flutter/material.dart';

import '../models/recipe_production_entry.dart';
import 'attention_banner.dart';
import 'recipe_production_status_visuals.dart';

/// Attention banner for the top recipe production review item.
class FnbRecipeProductionAttentionBanner extends StatelessWidget {
  const FnbRecipeProductionAttentionBanner({
    super.key,
    required this.entry,
    this.icon = Icons.priority_high_rounded,
    this.maxLines = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  }) : assert(maxLines > 0, 'maxLines must be greater than zero.');

  final FnbRecipeProductionEntry entry;
  final IconData icon;
  final int maxLines;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final status = fnbRecipeProductionStatusVisuals(
      colors: Theme.of(context).colorScheme,
      entry: entry,
    );

    return FnbAttentionBanner(
      message: '${entry.name}: ${entry.attentionLabel}',
      color: status.color,
      icon: icon,
      maxLines: maxLines,
      padding: padding,
    );
  }
}
