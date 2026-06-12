import 'dietary_tag.dart';
import 'money_format.dart';
import 'recipe_ingredient.dart';

/// Defines production guidance, costing, and timing for one menu recipe.
class FnbRecipe {
  const FnbRecipe({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.stationId,
    required this.prepMinutes,
    required this.fireMinutes,
    required this.yieldQuantity,
    required this.yieldUnit,
    this.description = '',
    this.ingredients = const [],
    this.steps = const [],
    this.dietaryTags = const {},
    this.costCents = 0,
  }) : assert(prepMinutes >= 0, 'prepMinutes must not be negative.'),
       assert(fireMinutes >= 0, 'fireMinutes must not be negative.'),
       assert(yieldQuantity > 0, 'yieldQuantity must be greater than zero.'),
       assert(costCents >= 0, 'costCents must not be negative.');

  final String id;
  final String name;
  final String categoryId;
  final String stationId;
  final int prepMinutes;
  final int fireMinutes;
  final double yieldQuantity;
  final String yieldUnit;
  final String description;
  final List<FnbRecipeIngredient> ingredients;
  final List<String> steps;
  final Set<FnbDietaryTag> dietaryTags;
  final int costCents;

  int get totalMinutes => prepMinutes + fireMinutes;

  int get ingredientCount => ingredients.length;

  bool get hasAllergens => dietaryTags.any((tag) => tag.isAllergen);

  String get totalTimeLabel => '${totalMinutes}m total';

  String get fireTimeLabel => '${fireMinutes}m fire';

  String get prepTimeLabel => '${prepMinutes}m prep';

  String get costLabel => formatFnbMoney(costCents);

  String get ingredientCountLabel {
    return ingredientCount == 1
        ? '1 ingredient'
        : '$ingredientCount ingredients';
  }

  String get yieldLabel {
    final normalized = yieldQuantity % 1 == 0
        ? yieldQuantity.toStringAsFixed(0)
        : yieldQuantity.toStringAsFixed(2);
    return '$normalized $yieldUnit';
  }

  String get dietaryLabel {
    if (dietaryTags.isEmpty) return 'No dietary tags';
    return dietaryTags.map((tag) => tag.label).join(', ');
  }

  FnbRecipe copyWith({
    String? name,
    String? categoryId,
    String? stationId,
    int? prepMinutes,
    int? fireMinutes,
    double? yieldQuantity,
    String? yieldUnit,
    String? description,
    List<FnbRecipeIngredient>? ingredients,
    List<String>? steps,
    Set<FnbDietaryTag>? dietaryTags,
    int? costCents,
  }) {
    return FnbRecipe(
      id: id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      stationId: stationId ?? this.stationId,
      prepMinutes: prepMinutes ?? this.prepMinutes,
      fireMinutes: fireMinutes ?? this.fireMinutes,
      yieldQuantity: yieldQuantity ?? this.yieldQuantity,
      yieldUnit: yieldUnit ?? this.yieldUnit,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      costCents: costCents ?? this.costCents,
    );
  }
}
