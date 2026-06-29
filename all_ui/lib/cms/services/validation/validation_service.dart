import '../../schema/model/field_schema.dart';
import '../../models/sql_type.dart';

class ValidationService {
  static String? validateField(FieldSchema field, dynamic value) {
    if (!field.constraints.nullable &&
        (value == null || value.toString().isEmpty)) {
      return '${field.label} is required';
    }

    if (value == null || value.toString().isEmpty) return null;

    final validation = field.validation;
    if (validation == null) return null;

    final strValue = value.toString();

    if (validation.minLength != null &&
        strValue.length < validation.minLength!) {
      return validation.errorMessage ??
          'Minimum length is ${validation.minLength}';
    }

    if (validation.maxLength != null &&
        strValue.length > validation.maxLength!) {
      return validation.errorMessage ??
          'Maximum length is ${validation.maxLength}';
    }

    if (validation.pattern != null) {
      final regex = RegExp(validation.pattern!);
      if (!regex.hasMatch(strValue)) {
        return validation.errorMessage ?? 'Invalid format';
      }
    }

    if (field.sqlType == SQLType.integer ||
        field.sqlType == SQLType.bigint ||
        field.sqlType == SQLType.decimal) {
      final numValue = num.tryParse(strValue);
      if (numValue == null) return 'Must be a valid number';

      if (validation.min != null && numValue < validation.min!) {
        return validation.errorMessage ?? 'Minimum value is ${validation.min}';
      }

      if (validation.max != null && numValue > validation.max!) {
        return validation.errorMessage ?? 'Maximum value is ${validation.max}';
      }
    }

    if (validation.allowedValues != null &&
        !validation.allowedValues!.contains(strValue)) {
      return validation.errorMessage ?? 'Invalid value';
    }

    return null;
  }
}
