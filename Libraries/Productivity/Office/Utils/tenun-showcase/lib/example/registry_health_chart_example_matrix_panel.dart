import 'package:flutter/material.dart';

import 'registry_health_chart_example_matrix_metric_strip.dart';
import 'registry_health_chart_example_matrix_model.dart';
import 'registry_health_chart_example_matrix_status_breakdown.dart';
import 'registry_health_chart_example_matrix_table.dart';
import 'registry_health_chart_example_matrix_work_sections.dart';

class RegistryHealthChartExampleMatrixPanel extends StatelessWidget {
  const RegistryHealthChartExampleMatrixPanel({
    super.key,
    required this.report,
    this.options = const RegistryHealthChartExampleMatrixPanelOptions(),
  });

  final RegistryHealthChartExampleMatrixReport report;
  final RegistryHealthChartExampleMatrixPanelOptions options;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (options.showHeadline) ...[
          Text(
            '${report.sampleCount} focused samples and ${report.sourceCheckCount} source checks mapped across ${report.rowCount} chart types.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
        ],
        if (options.showMetrics) ...[
          RegistryHealthChartExampleMatrixMetricStrip(report: report),
          const SizedBox(height: 12),
        ],
        if (options.showBreakdown) ...[
          RegistryHealthChartExampleMatrixStatusBreakdown(
            summaries: report.statusSummaries,
            title: options.breakdownTitle,
          ),
          const SizedBox(height: 12),
        ],
        if (options.showWorkSections)
          RegistryHealthChartExampleMatrixWorkSections(
            report: report,
            prioritySummaryLimit: options.prioritySummaryLimit,
            actionSummaryLimit: options.actionSummaryLimit,
            nextWorkLimit: options.nextWorkLimit,
            attentionLimit: options.attentionLimit,
          ),
        if (options.showTable)
          RegistryHealthChartExampleMatrixTable(
            rows: report.rows,
            headingRowHeight: options.tableHeadingRowHeight,
            dataRowMinHeight: options.tableDataRowMinHeight,
            dataRowMaxHeight: options.tableDataRowMaxHeight,
          ),
      ],
    );
  }
}

class RegistryHealthChartExampleMatrixPanelOptions {
  const RegistryHealthChartExampleMatrixPanelOptions({
    this.showHeadline = true,
    this.showMetrics = true,
    this.showBreakdown = true,
    this.showWorkSections = true,
    this.showTable = true,
    this.breakdownTitle = 'Readiness Breakdown',
    this.prioritySummaryLimit = 6,
    this.actionSummaryLimit = 6,
    this.nextWorkLimit = 6,
    this.attentionLimit = 8,
    this.tableHeadingRowHeight = 34,
    this.tableDataRowMinHeight = 36,
    this.tableDataRowMaxHeight = 44,
  });

  static const compact = RegistryHealthChartExampleMatrixPanelOptions(
    showTable: false,
    prioritySummaryLimit: 4,
    actionSummaryLimit: 4,
    nextWorkLimit: 3,
    attentionLimit: 4,
  );

  final bool showHeadline;
  final bool showMetrics;
  final bool showBreakdown;
  final bool showWorkSections;
  final bool showTable;
  final String breakdownTitle;
  final int prioritySummaryLimit;
  final int actionSummaryLimit;
  final int nextWorkLimit;
  final int attentionLimit;
  final double tableHeadingRowHeight;
  final double tableDataRowMinHeight;
  final double tableDataRowMaxHeight;

  RegistryHealthChartExampleMatrixPanelOptions copyWith({
    bool? showHeadline,
    bool? showMetrics,
    bool? showBreakdown,
    bool? showWorkSections,
    bool? showTable,
    String? breakdownTitle,
    int? prioritySummaryLimit,
    int? actionSummaryLimit,
    int? nextWorkLimit,
    int? attentionLimit,
    double? tableHeadingRowHeight,
    double? tableDataRowMinHeight,
    double? tableDataRowMaxHeight,
  }) {
    return RegistryHealthChartExampleMatrixPanelOptions(
      showHeadline: showHeadline ?? this.showHeadline,
      showMetrics: showMetrics ?? this.showMetrics,
      showBreakdown: showBreakdown ?? this.showBreakdown,
      showWorkSections: showWorkSections ?? this.showWorkSections,
      showTable: showTable ?? this.showTable,
      breakdownTitle: breakdownTitle ?? this.breakdownTitle,
      prioritySummaryLimit: prioritySummaryLimit ?? this.prioritySummaryLimit,
      actionSummaryLimit: actionSummaryLimit ?? this.actionSummaryLimit,
      nextWorkLimit: nextWorkLimit ?? this.nextWorkLimit,
      attentionLimit: attentionLimit ?? this.attentionLimit,
      tableHeadingRowHeight:
          tableHeadingRowHeight ?? this.tableHeadingRowHeight,
      tableDataRowMinHeight:
          tableDataRowMinHeight ?? this.tableDataRowMinHeight,
      tableDataRowMaxHeight:
          tableDataRowMaxHeight ?? this.tableDataRowMaxHeight,
    );
  }
}
