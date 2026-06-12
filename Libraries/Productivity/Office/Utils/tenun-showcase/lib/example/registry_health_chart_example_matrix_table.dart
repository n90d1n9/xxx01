import 'package:flutter/material.dart';

import 'registry_health_chart_example_matrix_model.dart';

class RegistryHealthChartExampleMatrixTable extends StatelessWidget {
  const RegistryHealthChartExampleMatrixTable({
    super.key,
    required this.rows,
    this.headingRowHeight = 34,
    this.dataRowMinHeight = 36,
    this.dataRowMaxHeight = 44,
  });

  final Iterable<RegistryHealthChartExampleMatrixRow> rows;
  final double headingRowHeight;
  final double dataRowMinHeight;
  final double dataRowMaxHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowHeight: headingRowHeight,
              dataRowMinHeight: dataRowMinHeight,
              dataRowMaxHeight: dataRowMaxHeight,
              columns: const [
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Shape')),
                DataColumn(label: Text('Priority')),
                DataColumn(label: Text('Samples')),
                DataColumn(label: Text('Source')),
                DataColumn(label: Text('Issues')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Action')),
              ],
              rows: [
                for (final row in rows)
                  DataRow(
                    cells: [
                      DataCell(Text(row.typeString)),
                      DataCell(Text(row.dataShape)),
                      DataCell(Text(row.priorityLabel)),
                      DataCell(Text(row.sampleCount.toString())),
                      DataCell(Text(row.sourceCheckCount.toString())),
                      DataCell(Text(row.issueCount.toString())),
                      DataCell(Text(row.statusLabel)),
                      DataCell(Text(row.nextAction)),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
