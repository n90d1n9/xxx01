/// Standard dietary and allergen labels shared by menu and recipe workflows.
enum FnbDietaryTag {
  vegetarian,
  vegan,
  glutenFree,
  dairyFree,
  halalFriendly,
  spicy,
  containsNuts,
  containsShellfish;

  String get label => switch (this) {
    FnbDietaryTag.vegetarian => 'Vegetarian',
    FnbDietaryTag.vegan => 'Vegan',
    FnbDietaryTag.glutenFree => 'Gluten free',
    FnbDietaryTag.dairyFree => 'Dairy free',
    FnbDietaryTag.halalFriendly => 'Halal friendly',
    FnbDietaryTag.spicy => 'Spicy',
    FnbDietaryTag.containsNuts => 'Contains nuts',
    FnbDietaryTag.containsShellfish => 'Contains shellfish',
  };

  bool get isAllergen => switch (this) {
    FnbDietaryTag.containsNuts || FnbDietaryTag.containsShellfish => true,
    _ => false,
  };
}
