import 'package:flutter/material.dart';

import '../model/report_configuration.dart';
import '../model/report_data.dart';
import '../utils/utils.dart';

class SummaryBarWidget extends StatelessWidget {
  final ReportData data;
  final ReportConfiguration config;
  const SummaryBarWidget({super.key, required this.data, required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, size: 18, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildSummaryChip(
                'Total Records',
                data.totalCount.toString(),
                Icons.table_rows,
              ),
              ...data.summary.entries.where((e) => e.key != 'recordCount').map((
                entry,
              ) {
                final column = config.selectedColumns.firstWhere(
                  (c) => c.fieldName == entry.key,
                );
                return _buildSummaryChip(
                  column.displayName,
                  formatValue(entry.value, column.dataType),
                  Icons.functions,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
