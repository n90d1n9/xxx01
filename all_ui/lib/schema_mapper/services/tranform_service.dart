import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';

import '../models/schema.dart';

class TransformationService {
  Either<String, dynamic> applyTransformation(
    dynamic value,
    TransformationType type,
    Map<String, dynamic> parameters,
  ) {
    try {
      switch (type) {
        case TransformationType.trim:
          return Right(value.toString().trim());

        case TransformationType.lowercase:
          return Right(value.toString().toLowerCase());

        case TransformationType.uppercase:
          return Right(value.toString().toUpperCase());

        case TransformationType.substringBefore:
          final separator = parameters['separator'] as String;
          return Right(value.toString().split(separator).first);

        case TransformationType.substringAfter:
          final separator = parameters['separator'] as String;
          return Right(value.toString().split(separator).last);

        case TransformationType.replace:
          final old = parameters['old'] as String;
          final replacement = parameters['replacement'] as String;
          return Right(value.toString().replaceAll(old, replacement));

        case TransformationType.regex:
          final pattern = parameters['pattern'] as String;
          final replacement = parameters['replacement'] as String;
          return Right(
            value.toString().replaceAll(RegExp(pattern), replacement),
          );

        case TransformationType.dateFormat:
          final inputFormat = parameters['inputFormat'] as String;
          final outputFormat = parameters['outputFormat'] as String;
          final dateTime = DateFormat(inputFormat).parse(value.toString());
          return Right(DateFormat(outputFormat).format(dateTime));

        case TransformationType.mathematical:
          final operation = parameters['operation'] as String;
          final operand = parameters['operand'] as num;

          if (value is num) {
            switch (operation) {
              case 'add':
                return Right(value + operand);
              case 'subtract':
                return Right(value - operand);
              case 'multiply':
                return Right(value * operand);
              case 'divide':
                return Right(value / operand);
              default:
                return Left('Unknown mathematical operation');
            }
          }
          return Left('Mathematical operations require numeric values');

        default:
          return Left('Unsupported transformation type');
      }
    } catch (e) {
      return Left('Transformation failed: ${e.toString()}');
    }
  }

  DataType inferDataType(dynamic value) {
    if (value == null) return DataType.custom;

    if (value is String) {
      if (_isValidDateTime(value)) return DataType.datetime;
      return DataType.string;
    }

    if (value is int) return DataType.integer;
    if (value is double) return DataType.double;
    if (value is bool) return DataType.boolean;

    return DataType.custom;
  }

  bool _isValidDateTime(String value) {
    try {
      DateTime.parse(value);
      return true;
    } catch (e) {
      return false;
    }
  }
}
