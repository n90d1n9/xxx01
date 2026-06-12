import 'package:flutter_riverpod/legacy.dart';

import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';

class RecipeNotifier extends StateNotifier<List<Recipe>> {
  RecipeNotifier()
    : super([
        // Some initial dummy data
        Recipe(
          id: '1',
          name: 'Tomato Soup',
          description: 'Classic tomato soup',
          ingredients: [
            RecipeIngredient(
              inventoryItemId: '1',
              name: 'Tomatoes',
              quantity: 1.5,
              unit: 'kg',
            ),
          ],
          instructions: 'Chop tomatoes, simmer for 30 minutes, blend, season.',
          preparationTime: 15,
          cookingTime: 30,
          category: 'Soup',
          cost: 5.0,
        ),
      ]);

  void addRecipe(Recipe recipe) {
    state = [...state, recipe];
  }

  void updateRecipe(Recipe updatedRecipe) {
    state = state
        .map((recipe) => recipe.id == updatedRecipe.id ? updatedRecipe : recipe)
        .toList();
  }

  void deleteRecipe(String id) {
    state = state.where((recipe) => recipe.id != id).toList();
  }

  List<Recipe> getRecipesByCategory(String category) {
    return state.where((recipe) => recipe.category == category).toList();
  }
}

final recipeProvider = StateNotifierProvider<RecipeNotifier, List<Recipe>>(
  (ref) => RecipeNotifier(),
);
