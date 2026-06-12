/// Groups menu items for display, routing, and operator filtering.
class FnbMenuCategory {
  const FnbMenuCategory({
    required this.id,
    required this.name,
    this.displayOrder = 0,
    this.description = '',
    this.isActive = true,
  });

  final String id;
  final String name;
  final int displayOrder;
  final String description;
  final bool isActive;

  String get statusLabel => isActive ? 'Active' : 'Hidden';

  FnbMenuCategory copyWith({
    String? name,
    int? displayOrder,
    String? description,
    bool? isActive,
  }) {
    return FnbMenuCategory(
      id: id,
      name: name ?? this.name,
      displayOrder: displayOrder ?? this.displayOrder,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
