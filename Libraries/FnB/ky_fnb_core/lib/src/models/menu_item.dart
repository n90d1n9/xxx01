import 'dietary_tag.dart';
import 'menu_availability.dart';
import 'money_format.dart';

/// Describes one sellable menu item and its kitchen routing metadata.
class FnbMenuItem {
  const FnbMenuItem({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.priceCents,
    this.description = '',
    this.recipeId,
    this.stationId,
    this.prepMinutes = 0,
    this.availability = FnbMenuAvailability.available,
    this.dietaryTags = const {},
    this.tags = const [],
    this.imageUrl,
    this.displayOrder = 0,
  }) : assert(priceCents >= 0, 'priceCents must not be negative.'),
       assert(prepMinutes >= 0, 'prepMinutes must not be negative.');

  final String id;
  final String name;
  final String categoryId;
  final int priceCents;
  final String description;
  final String? recipeId;
  final String? stationId;
  final int prepMinutes;
  final FnbMenuAvailability availability;
  final Set<FnbDietaryTag> dietaryTags;
  final List<String> tags;
  final String? imageUrl;
  final int displayOrder;

  bool get canOrder => availability.canOrder;

  bool get hasRecipe => recipeId != null && recipeId!.trim().isNotEmpty;

  bool get hasKitchenRoute => stationId != null && stationId!.trim().isNotEmpty;

  bool get hasAllergens => dietaryTags.any((tag) => tag.isAllergen);

  String get priceLabel => formatFnbMoney(priceCents);

  String get prepTimeLabel => prepMinutes == 0 ? 'No prep' : '${prepMinutes}m';

  String get availabilityLabel => availability.label;

  String get kitchenRouteLabel {
    final station = stationId?.trim();
    if (station == null || station.isEmpty) return 'No station route';
    return 'Station $station';
  }

  String get dietaryLabel {
    if (dietaryTags.isEmpty) return 'No dietary tags';
    return dietaryTags.map((tag) => tag.label).join(', ');
  }

  FnbMenuItem copyWith({
    String? name,
    String? categoryId,
    int? priceCents,
    String? description,
    String? recipeId,
    String? stationId,
    int? prepMinutes,
    FnbMenuAvailability? availability,
    Set<FnbDietaryTag>? dietaryTags,
    List<String>? tags,
    String? imageUrl,
    int? displayOrder,
  }) {
    return FnbMenuItem(
      id: id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      priceCents: priceCents ?? this.priceCents,
      description: description ?? this.description,
      recipeId: recipeId ?? this.recipeId,
      stationId: stationId ?? this.stationId,
      prepMinutes: prepMinutes ?? this.prepMinutes,
      availability: availability ?? this.availability,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}
