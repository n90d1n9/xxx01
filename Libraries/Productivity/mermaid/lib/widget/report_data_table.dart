import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:report_builder/widget/summary_bar.dart';

import '../model/data_type.dart';
import '../model/report.dart';
import '../model/report_configuration.dart';
import '../model/report_data.dart';
import '../state/report_builder_provider.dart';
import '../state/report_builder_state.dart';
import '../utils/utils.dart';

class ReportDataTable extends StatefulWidget {
  final ReportConfiguration config;
  final ReportData data;
  final Map<String, bool> expandedGroups;
  final Function(String) onToggleGroup;

  const ReportDataTable({
    super.key,
    required this.config,
    required this.data,
    required this.expandedGroups,
    required this.onToggleGroup,
  });

  @override
  State<ReportDataTable> createState() => _ReportDataTableState();
}

class _ReportDataTableState extends State<ReportDataTable> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildSummaryBar(),
        Expanded(
          child: widget.data.groupedData != null
              ? _buildGroupedTable()
              : _buildStandardTable(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.config.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.config.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.config.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat(
                      'MMM dd, yyyy • HH:mm',
                    ).format(widget.data.generatedAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Execution time: ${widget.data.executionTime.inMilliseconds}ms',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    if (widget.data.summary.isEmpty) {
      return const SizedBox.shrink();
    } else {
      return SummaryBarWidget(config: widget.config, data: widget.data);
    }
  }

  Widget _buildStandardTable() {
    return Scrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      child: Scrollbar(
        controller: _horizontalController,
        thumbVisibility: true,
        notificationPredicate: (notification) => notification.depth == 1,
        child: SingleChildScrollView(
          controller: _verticalController,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
              headingRowHeight: 56,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 56,
              columnSpacing: 24,
              horizontalMargin: 16,
              columns: widget.config.selectedColumns.map((col) {
                return DataColumn(
                  label: Row(
                    children: [
                      Text(
                        col.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (widget.config.sorts.any(
                        (s) => s.columnId == col.id,
                      )) ...[
                        const SizedBox(width: 4),
                        Icon(
                          widget.config.sorts
                                  .firstWhere((s) => s.columnId == col.id)
                                  .ascending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
              rows: widget.data.rows.map((row) {
                return DataRow(
                  cells: widget.config.selectedColumns.map((col) {
                    final value = row[col.fieldName];
                    return DataCell(
                      Text(
                        formatCellValue(value, col.dataType),
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedTable() {
    final groupedData = widget.data.groupedData!;
    final grouping = widget.config.groupings.first;

    return ListView.builder(
      controller: _verticalController,
      itemCount: groupedData.length,
      itemBuilder: (context, index) {
        final groupKey = groupedData.keys.elementAt(index);
        final groupRows = groupedData[groupKey]!;
        final isExpanded = widget.expandedGroups[groupKey] ?? true;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              InkWell(
                onTap: () => widget.onToggleGroup(groupKey),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$groupKey (${groupRows.length} records)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      if (grouping.showSubtotals)
                        _buildGroupSubtotals(groupRows),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 24,
                    horizontalMargin: 16,
                    headingRowHeight: 0,
                    dataRowMinHeight: 40,
                    dataRowMaxHeight: 48,
                    columns: widget.config.selectedColumns
                        .map(
                          (col) => const DataColumn(label: SizedBox.shrink()),
                        )
                        .toList(),
                    rows: groupRows.map((row) {
                      return DataRow(
                        cells: widget.config.selectedColumns.map((col) {
                          final value = row[col.fieldName];
                          return DataCell(
                            Text(
                              formatCellValue(value, col.dataType),
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupSubtotals(List<Map<String, dynamic>> rows) {
    final subtotals = <Widget>[];

    for (var entry in widget.config.aggregations.entries) {
      final column = widget.config.selectedColumns.firstWhere(
        (c) => c.id == entry.key,
      );
      final values = rows
          .map((r) => r[column.fieldName])
          .whereType<num>()
          .toList();

      if (values.isEmpty) continue;

      final total = values.reduce((a, b) => a + b);
      subtotals.add(
        Chip(
          label: Text(
            '${column.displayName}: ${formatValue(total, column.dataType)}',
            style: const TextStyle(fontSize: 11),
          ),
          backgroundColor: Colors.white,
        ),
      );
    }

    return Wrap(spacing: 8, children: subtotals);
  }

  Widget _buildColumnSelection(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  getDomainIcon(state.currentConfig!.domain),
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Report Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: state.currentConfig!.name,
              decoration: const InputDecoration(
                labelText: 'Report Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              onChanged: (value) {
                ref
                    .read(reportBuilderProvider.notifier)
                    .updateConfiguration(
                      state.currentConfig!.copyWith(name: value),
                    );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.currentConfig!.description,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
              onChanged: (value) {
                ref
                    .read(reportBuilderProvider.notifier)
                    .updateConfiguration(
                      state.currentConfig!.copyWith(description: value),
                    );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ReportType>(
                    value: state.currentConfig!.type,
                    decoration: const InputDecoration(
                      labelText: 'Report Type',
                      border: OutlineInputBorder(),
                    ),
                    items: ReportType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(reportBuilderProvider.notifier)
                            .updateConfiguration(
                              state.currentConfig!.copyWith(type: value),
                            );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /* 
  Widget _buildColumnSelection(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getDomainIcon(state.currentConfig!.domain),
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Report Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: state.currentConfig!.name,
              decoration: const InputDecoration(
                labelText: 'Report Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              onChanged: (value) {
                ref
                    .read(reportBuilderProvider.notifier)
                    .updateConfiguration(
                      state.currentConfig!.copyWith(name: value),
                    );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.currentConfig!.description,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
              onChanged: (value) {
                ref
                    .read(reportBuilderProvider.notifier)
                    .updateConfiguration(
                      state.currentConfig!.copyWith(description: value),
                    );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ReportType>(
                    value: state.currentConfig!.type,
                    decoration: const InputDecoration(
                      labelText: 'Report Type',
                      border: OutlineInputBorder(),
                    ),
                    items: ReportType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(reportBuilderProvider.notifier)
                            .updateConfiguration(
                              state.currentConfig!.copyWith(type: value),
                            );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  } */
}
