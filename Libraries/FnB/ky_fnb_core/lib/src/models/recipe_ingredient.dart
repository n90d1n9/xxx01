import 'money_format.dart';

/// Describes one inventory-backed ingredient used by a recipe.
class FnbRecipeIngredient {
  const FnbRecipeIngredient({
    required this.inventoryItemId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.preparationNote,
    this.costCents = 0,
  }) : assert(quantity > 0, 'quantity must be greater than zero.'),
       assert(costCents >= 0, 'costCents must not be negative.');

  final String inventoryItemId;
  final String name;
  final double quantity;
  final String unit;
  final String? preparationNote;
  final int costCents;

  String get quantityLabel {
    final normalized = quantity % 1 == 0
        ? quantity.toStringAsFixed(0)
        : quantity.toStringAsFixed(2);
    return '$normalized $unit';
  }

  String get costLabel => formatFnbMoney(costCents);

  String get label {
    final note = preparationNote?.trim();
    if (note == null || note.isEmpty) return '$quantityLabel $name';
    return '$quantityLabel $name, $note';
  }
}
