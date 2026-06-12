import 'package:flutter/material.dart';

import 'registry_health_api_consistency.dart';

class RegistryHealthApiConsistencyAttentionTable extends StatelessWidget {
  const RegistryHealthApiConsistencyAttentionTable({
    super.key,
    required this.report,
    this.rowLimit = 8,
  });

  final RegistryHealthApiConsistencyReport report;
  final int rowLimit;

  @override
  Widget build(BuildContext context) {
    final rows = report.attentionRows.take(rowLimit).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (rows.isEmpty)
          const Text('All API consistency concerns are covered.')
        else
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowHeight: 36,
                    dataRowMinHeight: 54,
                    dataRowMaxHeight: 112,
                    columns: const [
                      DataColumn(label: Text('Contract')),
                      DataColumn(label: Text('Charts')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Missing')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: [
                      for (final row in rows)
                        DataRow(
                          cells: [
                            DataCell(Text(row.contractName)),
                            DataCell(_ApiConsistencyChips(row.chartExamples)),
                            DataCell(Text(row.statusLabel)),
                            DataCell(
                              _ApiConsistencyChips(
                                _apiConsistencyMissingLabels(row),
                              ),
                            ),
                            DataCell(
                              Text(registryHealthApiConsistencyAction(row)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        if (report.attentionRows.length > rows.length)
          Text(
            '+${report.attentionRows.length - rows.length} more contracts',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}

String registryHealthApiConsistencyAction(RegistryHealthApiConsistencyRow row) {
  if (row.missingConcerns.isEmpty) return 'No action needed.';
  return row.missingConcerns.first.action;
}

List<String> _apiConsistencyMissingLabels(RegistryHealthApiConsistencyRow row) {
  return [
    for (final concern in row.requiredMissingConcerns) concern.label,
    for (final concern in row.advisoryMissingConcerns)
      '${concern.label} (Advisory)',
  ];
}

class _ApiConsistencyChips extends StatelessWidget {
  const _ApiConsistencyChips(this.labels);

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const Text('-');

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        for (final label in labels)
          Chip(
            label: Text(label, style: const TextStyle(fontSize: 10)),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          ),
      ],
    );
  }
}
