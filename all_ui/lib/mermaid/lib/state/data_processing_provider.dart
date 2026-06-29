// services/data_processing_service.dart
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/data_type.dart';
import '../model/report_configuration.dart';

class DataProcessingService {
  Map<String, dynamic> calculateSummary(
    List<Map<String, dynamic>> rows,
    ReportConfiguration config,
  ) {
    final summary = <String, dynamic>{};

    for (var entry in config.aggregations.entries) {
      final column = config.selectedColumns.firstWhere(
        (c) => c.id == entry.key,
      );
      final values = rows
          .map((r) => r[column.fieldName])
          .whereType<num>()
          .toList();

      if (values.isEmpty) continue;

      summary[column.fieldName] = _calculateAggregation(values, entry.value);
    }

    summary['recordCount'] = rows.length;
    return summary;
  }

  Map<String, List<Map<String, dynamic>>>? groupData(
    List<Map<String, dynamic>> rows,
    ReportConfiguration config,
  ) {
    if (config.groupings.isEmpty) return null;

    final grouped = <String, List<Map<String, dynamic>>>{};
    final grouping = config.groupings.first;
    final column = config.columns.firstWhere((c) => c.id == grouping.columnId);

    for (var row in rows) {
      final key = row[column.fieldName]?.toString() ?? 'null';
      grouped.putIfAbsent(key, () => []).add(row);
    }

    return grouped;
  }

  dynamic _calculateAggregation(List<num> values, AggregationType type) {
    if (values.isEmpty) return 0;

    switch (type) {
      case AggregationType.sum:
        return values.reduce((a, b) => a + b);
      case AggregationType.average:
        return values.reduce((a, b) => a + b) / values.length;
      case AggregationType.count:
        return values.length;
      case AggregationType.min:
        return values.reduce((a, b) => a < b ? a : b);
      case AggregationType.max:
        return values.reduce((a, b) => a > b ? a : b);
      case AggregationType.median:
        final sorted = List<num>.from(values)..sort();
        final mid = sorted.length ~/ 2;
        return sorted.length % 2 == 0
            ? (sorted[mid - 1] + sorted[mid]) / 2
            : sorted[mid];
      case AggregationType.stdDev:
        final mean = values.reduce((a, b) => a + b) / values.length;
        final variance =
            values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) /
            values.length;
        return sqrt(variance); // Fixed: using sqrt from dart:math
      case AggregationType.variance:
        final mean = values.reduce((a, b) => a + b) / values.length;
        return values
                .map((v) => (v - mean) * (v - mean))
                .reduce((a, b) => a + b) /
            values.length;
      case AggregationType.mode:
        // TODO: Handle this case.
        throw UnimplementedError();
      case AggregationType.percentile:
        // TODO: Handle this case.
        throw UnimplementedError();
      case AggregationType.distinctCount:
        // TODO: Handle this case.
        throw UnimplementedError();
      case AggregationType.first:
        // TODO: Handle this case.
        throw UnimplementedError();
      case AggregationType.last:
        // TODO: Handle this case.
        throw UnimplementedError();
      case AggregationType.custom:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

final dataProcessingServiceProvider = Provider<DataProcessingService>((ref) {
  return DataProcessingService();
});
