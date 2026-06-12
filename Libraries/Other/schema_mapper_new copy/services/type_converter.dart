import '../models/data_schema.dart';

class TypeConverter {
  static dynamic convertType(
    dynamic value,
    DataType sourceType,
    DataType targetType,
  ) {
    if (value == null) return null;

    switch (targetType) {
      case DataType.string:
        return _convertToString(value, sourceType);
      case DataType.integer:
        return _convertToInteger(value, sourceType);
      case DataType.double:
        return _convertToDouble(value, sourceType);
      case DataType.boolean:
        return _convertToBoolean(value, sourceType);
      case DataType.datetime:
        return _convertToDateTime(value, sourceType);
      case DataType.list:
        return _convertToList(value, sourceType);
      case DataType.map:
        return _convertToMap(value, sourceType);
      case DataType.custom:
        return value; // Custom type conversion might need special handling
    }
  }

  static String _convertToString(dynamic value, DataType sourceType) {
    return value.toString();
  }

  static int? _convertToInteger(dynamic value, DataType sourceType) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _convertToDouble(dynamic value, DataType sourceType) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static bool? _convertToBoolean(dynamic value, DataType sourceType) {
    if (value is bool) return value;
    if (value is String) {
      return ['true', '1', 'yes'].contains(value.toLowerCase());
    }
    if (value is int) return value > 0;
    return null;
  }

  static DateTime? _convertToDateTime(dynamic value, DataType sourceType) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static List? _convertToList(dynamic value, DataType sourceType) {
    if (value is List) return value;
    return [value];
  }

  static Map? _convertToMap(dynamic value, DataType sourceType) {
    if (value is Map) return value;
    return {'value': value};
  }
}
