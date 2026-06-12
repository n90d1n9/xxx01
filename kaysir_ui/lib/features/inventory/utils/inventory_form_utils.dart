const inventoryRequiredTextError = 'Enter a value';
const inventoryWholeNumberError = 'Enter a whole number';
const inventoryZeroOrMoreError = 'Enter 0 or more';
const inventoryAtLeastOneError = 'Enter at least 1';
const inventoryPositiveQuantityError = 'Enter a quantity greater than zero';
const inventoryPositiveDecimalError = 'Enter a valid positive number';
const inventoryOptionalNonNegativeNumberError = 'Enter a valid number';

const inventoryProductNameRequiredError = 'Enter a product name';
const inventoryProductSkuRequiredError = 'Enter a SKU';
const inventoryProductCategoryRequiredError = 'Enter a category';
const inventoryProductUnitPriceError = 'Enter a valid positive unit price';

const inventorySupplierNameRequiredError = 'Enter a supplier name';

const inventoryWarehouseNameRequiredError = 'Enter a warehouse name';
const inventoryWarehouseBranchRequiredError = 'Enter a branch name';
const inventoryWarehouseLocationRequiredError = 'Enter a warehouse location';
const inventoryWarehouseCapacityError = 'Enter a valid capacity';

String _trimInventoryInput(String? value) => (value ?? '').trim();

int? parseInventoryInteger(String? value) {
  return int.tryParse(_trimInventoryInput(value));
}

double? parseInventoryDecimal(String? value) {
  final parsed = double.tryParse(_trimInventoryInput(value));
  if (parsed == null || !parsed.isFinite) return null;

  return parsed;
}

num? parseInventoryNumber(String? value) {
  final parsed = num.tryParse(_trimInventoryInput(value));
  if (parsed == null || !parsed.isFinite) return null;

  return parsed;
}

String? validateInventoryRequiredText(
  String? value, {
  String errorMessage = inventoryRequiredTextError,
}) {
  return _trimInventoryInput(value).isEmpty ? errorMessage : null;
}

String? validateInventoryWholeNumber(String? value, {required bool allowZero}) {
  final parsed = parseInventoryInteger(value);
  if (parsed == null) return inventoryWholeNumberError;

  final minimum = allowZero ? 0 : 1;
  if (parsed < minimum) {
    return allowZero ? inventoryZeroOrMoreError : inventoryAtLeastOneError;
  }

  return null;
}

String? validateInventoryPositiveQuantity(String? value) {
  final parsed = parseInventoryInteger(value);
  if (parsed == null || parsed <= 0) return inventoryPositiveQuantityError;

  return null;
}

String? validateInventoryPositiveDecimal(
  String? value, {
  String errorMessage = inventoryPositiveDecimalError,
}) {
  final parsed = parseInventoryDecimal(value);
  if (parsed == null || parsed <= 0) return errorMessage;

  return null;
}

String? validateInventoryOptionalNonNegativeNumber(
  String? value, {
  String errorMessage = inventoryOptionalNonNegativeNumberError,
}) {
  if (_trimInventoryInput(value).isEmpty) return null;

  final parsed = parseInventoryNumber(value);
  if (parsed == null || parsed < 0) return errorMessage;

  return null;
}
