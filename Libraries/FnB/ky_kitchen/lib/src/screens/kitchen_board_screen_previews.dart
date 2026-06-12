import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../controllers/kitchen_board_controller.dart';
import '../models/kitchen_operator_context.dart';
import '../widgets/recipe_production_preview_data.dart';
import '../widgets/station_board_preview_data.dart';
import 'kitchen_board_screen.dart';

/// Preview entry for the composed kitchen board screen.
@Preview(name: 'Kitchen Board Screen', group: 'Kitchen')
Widget kitchenBoardScreenPreview() {
  return MaterialApp(
    home: Scaffold(
      body: KitchenBoardScreen(
        controller: KitchenBoardController(
          stations: kitchenStationPreviewData(),
          queue: kitchenTicketQueuePreviewData(),
          recipes: kitchenRecipeProductionRecipesPreviewData(),
          menu: kitchenRecipeProductionMenuPreviewData(),
        ),
        operatorContext: const KitchenOperatorContext(
          id: 'expo-lead',
          displayName: 'Dimas',
          roleLabel: 'Expo lead',
        ),
      ),
    ),
  );
}
