import 'recipe_ingredient.dart';

class Recipe {
  final String id;
  final String name;
  final String description;
  final List<RecipeIngredient> ingredients;
  final String instructions;
  final int preparationTime; // in minutes
  final int cookingTime; // in minutes
  final String category;
  final double cost;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.preparationTime,
    required this.cookingTime,
    required this.category,
    required this.cost,
  });
}
