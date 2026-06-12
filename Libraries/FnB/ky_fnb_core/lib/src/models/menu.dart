import 'menu_availability.dart';
import 'menu_category.dart';
import 'menu_item.dart';

/// Represents one menu book with display categories and sellable items.
class FnbMenu {
  const FnbMenu({
    required this.id,
    required this.name,
    this.isActive = true,
    this.categories = const [],
    this.items = const [],
  });

  final String id;
  final String name;
  final bool isActive;
  final List<FnbMenuCategory> categories;
  final List<FnbMenuItem> items;

  List<FnbMenuCategory> get activeCategories {
    final active = categories
        .where((category) => category.isActive)
        .toList(growable: false);
    active.sort((first, second) {
      final order = first.displayOrder.compareTo(second.displayOrder);
      if (order != 0) return order;
      return first.name.compareTo(second.name);
    });
    return active;
  }

  List<FnbMenuItem> get visibleItems {
    final visible = items
        .where((item) => item.availability != FnbMenuAvailability.hidden)
        .toList(growable: false);
    visible.sort((first, second) {
      final categoryOrder = _categoryOrder(
        first.categoryId,
      ).compareTo(_categoryOrder(second.categoryId));
      if (categoryOrder != 0) return categoryOrder;

      final itemOrder = first.displayOrder.compareTo(second.displayOrder);
      if (itemOrder != 0) return itemOrder;

      return first.name.compareTo(second.name);
    });
    return visible;
  }

  List<FnbMenuItem> itemsForCategory(String categoryId) {
    return visibleItems
        .where((item) => item.categoryId == categoryId)
        .toList(growable: false);
  }

  FnbMenuCategory? categoryById(String categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  FnbMenuItem? itemById(String itemId) {
    for (final item in items) {
      if (item.id == itemId) return item;
    }
    return null;
  }

  int get itemCount => items.length;

  int get availableItemCount {
    return items.where((item) => item.canOrder).length;
  }

  int get attentionItemCount {
    return items.where((item) => item.availability.needsAttention).length;
  }

  String get itemCountLabel => itemCount == 1 ? '1 item' : '$itemCount items';

  String get availabilitySummaryLabel {
    return '$availableItemCount available, $attentionItemCount need attention';
  }

  FnbMenu copyWith({
    String? name,
    bool? isActive,
    List<FnbMenuCategory>? categories,
    List<FnbMenuItem>? items,
  }) {
    return FnbMenu(
      id: id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      categories: categories ?? this.categories,
      items: items ?? this.items,
    );
  }

  int _categoryOrder(String categoryId) {
    return categoryById(categoryId)?.displayOrder ?? 1 << 20;
  }
}
