import 'management_pack.dart';

/// Shared validation rules for editable product management pack fields.
String? validateProductManagementPackFieldInput(
  ProductManagementPackField field,
  String? value,
) {
  final trimmedValue = value?.trim() ?? '';
  if (field.required && trimmedValue.isEmpty) {
    return 'Please enter ${field.label.toLowerCase()}';
  }
  if (trimmedValue.isEmpty) return null;

  switch (field.type) {
    case ProductManagementFieldType.number:
      if (double.tryParse(trimmedValue) == null) {
        return 'Please enter a valid ${field.label.toLowerCase()}';
      }
      break;
    case ProductManagementFieldType.date:
      if (DateTime.tryParse(trimmedValue) == null) {
        return 'Please enter a valid ${field.label.toLowerCase()}';
      }
      break;
    case ProductManagementFieldType.select:
      if (field.options.isNotEmpty && !field.options.contains(trimmedValue)) {
        return 'Please select a valid ${field.label.toLowerCase()}';
      }
      break;
    case ProductManagementFieldType.text:
    case ProductManagementFieldType.toggle:
      break;
  }

  return null;
}
