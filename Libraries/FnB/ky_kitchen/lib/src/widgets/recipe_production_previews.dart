import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'recipe_production_panel.dart';
import 'recipe_production_preview_data.dart';
import 'recipe_production_tile.dart';

/// Preview entry for kitchen recipe production management.
@Preview(name: 'Recipe Production Panel', group: 'Kitchen')
Widget recipeProductionPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: KitchenRecipeProductionPanel(
          summary: kitchenRecipeProductionSummaryPreviewData(),
          selectedRecipeId: 'rendang',
          onRecipeSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Preview entry for one recipe production row.
@Preview(name: 'Recipe Production Tile', group: 'Kitchen')
Widget recipeProductionTilePreview() {
  final summary = kitchenRecipeProductionSummaryPreviewData();

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: KitchenRecipeProductionTile(
          entry: summary.entries.first,
          selected: true,
          onPressed: () {},
        ),
      ),
    ),
  );
}
