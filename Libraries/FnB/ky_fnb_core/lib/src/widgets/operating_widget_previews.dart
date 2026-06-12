import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/recipe.dart';
import '../models/recipe_production_entry.dart';
import 'attention_banner.dart';
import 'metric_chip.dart';
import 'recipe_production_attention_banner.dart';
import 'status_badge.dart';
import 'status_pill.dart';

/// Preview entry for the shared FnB metric chip.
@Preview(name: 'Metric Chip', group: 'FnB Core')
Widget fnbMetricChipPreview() {
  return const _PreviewShell(
    child: FnbMetricChip(icon: Icons.schedule_outlined, label: '14m average'),
  );
}

/// Preview entry for the shared FnB status badge.
@Preview(name: 'Status Badge', group: 'FnB Core')
Widget fnbStatusBadgePreview() {
  return const _PreviewShell(
    child: FnbStatusBadge(
      icon: Icons.check_circle_outline,
      color: Colors.teal,
      tooltip: 'Review complete',
    ),
  );
}

/// Preview entry for the shared FnB status pill.
@Preview(name: 'Status Pill', group: 'FnB Core')
Widget fnbStatusPillPreview() {
  return const _PreviewShell(
    child: FnbStatusPill(label: 'Review complete', color: Colors.teal),
  );
}

/// Preview entry for the shared FnB attention banner.
@Preview(name: 'Attention Banner', group: 'FnB Core')
Widget fnbAttentionBannerPreview() {
  return const _PreviewShell(
    child: FnbAttentionBanner(
      message: 'Batch Sambal: Link to a menu item',
      color: Colors.redAccent,
    ),
  );
}

/// Preview entry for the shared FnB recipe production attention banner.
@Preview(name: 'Recipe Production Attention Banner', group: 'FnB Core')
Widget fnbRecipeProductionAttentionBannerPreview() {
  return const _PreviewShell(
    child: FnbRecipeProductionAttentionBanner(
      entry: FnbRecipeProductionEntry(
        recipe: FnbRecipe(
          id: 'sambal',
          name: 'Batch Sambal',
          categoryId: 'mains',
          stationId: 'wok',
          prepMinutes: 6,
          fireMinutes: 0,
          yieldQuantity: 12,
          yieldUnit: 'portions',
        ),
        menuItem: null,
      ),
    ),
  );
}

/// Material wrapper for rendering shared FnB widget previews.
class _PreviewShell extends StatelessWidget {
  const _PreviewShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}
