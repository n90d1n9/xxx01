import '../../inventory/models/movement_type.dart';
import '../../inventory/models/stock_movement.dart';
import '../models/management_pack.dart';
import '../models/management_pack_field_validation.dart'
    as management_pack_field_validation;
import '../models/product.dart';

class ProductFormDraft {
  ProductFormDraft({
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.initialStock,
    required this.description,
    this.barcode = '',
    this.unit = '',
    Map<String, String> customAttributes = const {},
  }) : customAttributes = Map.unmodifiable(
         normalizeProductCustomAttributes(customAttributes),
       );

  final String name;
  final String sku;
  final String category;
  final double price;
  final int initialStock;
  final String description;
  final String barcode;
  final String unit;
  final Map<String, String> customAttributes;

  factory ProductFormDraft.fromText({
    required String name,
    required String sku,
    required String category,
    required String price,
    required String initialStock,
    required String description,
    String barcode = '',
    String unit = '',
    Map<String, String> customAttributes = const {},
  }) {
    return ProductFormDraft(
      name: normalizeProductFormText(name),
      sku: normalizeProductFormText(sku),
      category: normalizeProductFormText(category),
      price: parseProductPriceInput(price),
      initialStock: parseProductStockInput(initialStock),
      description: normalizeProductFormText(description),
      barcode: normalizeProductFormText(barcode),
      unit: normalizeProductFormText(unit),
      customAttributes: customAttributes,
    );
  }

  Product toProduct({required String id}) {
    return Product(
      id: id,
      name: name,
      sku: sku,
      category: category,
      price: price,
      currentStock: initialStock,
      stockQuantity: initialStock,
      description: description,
      barcode: _nullableFormText(barcode),
      unit: _nullableFormText(unit),
      customAttributes: customAttributes,
    );
  }

  Product applyTo(Product product) {
    return product.copyWith(
      name: name,
      sku: sku,
      category: category,
      price: price,
      description: description,
      barcode: _nullableFormText(barcode),
      unit: _nullableFormText(unit),
      customAttributes: customAttributes,
    );
  }

  StockMovement? initialStockMovement({
    required String id,
    required String productId,
    required DateTime date,
  }) {
    if (initialStock <= 0) return null;

    return StockMovement(
      id: id,
      productId: productId,
      quantity: initialStock,
      type: MovementType.inbound,
      reference: 'Initial',
      date: date,
      notes: 'Initial stock',
    );
  }
}

String normalizeProductFormText(String value) => value.trim();

Map<String, String> normalizeProductCustomAttributes(
  Map<String, String> values,
) {
  return {
    for (final entry in values.entries)
      if (entry.key.trim().isNotEmpty && entry.value.trim().isNotEmpty)
        entry.key.trim(): entry.value.trim(),
  };
}

String? validateRequiredProductField(String? value, String label) {
  if (value == null || value.trim().isEmpty) return 'Please enter $label';
  return null;
}

String? validateProductPriceInput(String? value) {
  final requiredError = validateRequiredProductField(value, 'a price');
  if (requiredError != null) return requiredError;

  final price = double.tryParse(value!.trim());
  if (price == null) return 'Please enter a valid price';
  if (price < 0) return 'Price cannot be negative';
  return null;
}

String? validateProductStockInput(String? value) {
  final requiredError = validateRequiredProductField(value, 'initial stock');
  if (requiredError != null) return requiredError;

  final stock = int.tryParse(value!.trim());
  if (stock == null) return 'Please enter a whole number';
  if (stock < 0) return 'Stock cannot be negative';
  return null;
}

String? validateProductManagementFieldInput(
  ProductManagementPackField field,
  String? value,
) {
  return management_pack_field_validation
      .validateProductManagementPackFieldInput(field, value);
}

double parseProductPriceInput(String value) {
  return double.parse(value.trim());
}

int parseProductStockInput(String value) {
  return int.parse(value.trim());
}

String? _nullableFormText(String value) {
  final normalized = normalizeProductFormText(value);
  return normalized.isEmpty ? null : normalized;
}
