import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../state/spreadsheet_provider.dart';

class StatusBar extends ConsumerWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(selectedCellProvider);
    final data = ref.watch(spreadsheetProvider);

    String statusText = 'Ready';
    if (selection != null && selection.isRange()) {
      final cells = selection.getCells();
      double sum = 0;
      int count = 0;
      double? min;
      double? max;

      for (final addr in cells) {
        final cellData = data[addr];
        if (cellData != null) {
          final value = double.tryParse(cellData.value);
          if (value != null) {
            sum += value;
            count++;
            min = min == null ? value : math.min(min, value);
            max = max == null ? value : math.max(max, value);
          }
        }
      }

      if (count > 0) {
        statusText =
            'Count: $count | Sum: ${sum.toStringAsFixed(2)} | Avg: ${(sum / count).toStringAsFixed(2)} | Min: ${min!.toStringAsFixed(2)} | Max: ${max!.toStringAsFixed(2)}';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
          Text(
            '${data.length} cells',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
