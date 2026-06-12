// pubspec.yaml dependencies:
// flutter_riverpod: ^2.4.0
// freezed_annotation: ^2.4.1
// json_annotation: ^4.8.1
// uuid: ^4.0.0
// intl: ^0.18.1
// pdf: ^3.10.4
// excel: ^4.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// ==================== DOMAIN MODELS ====================

enum ReportDomain { sales, finance, operations, hr, marketing, analytics }

enum ReportType { tabular, summary, chart, dashboard, custom }

enum ExportFormat { pdf, excel, csv, json }

enum AggregationType { sum, average, count, min, max, median }

class ReportColumn {
  final String id;
  final String fieldName;
  final String displayName;
  final DataType dataType;
  final bool sortable;
  final bool filterable;
  final bool aggregatable;
  final AggregationType? defaultAggregation;
  final String? format;

  ReportColumn({
    required this.id,
    required this.fieldName,
    required this.displayName,
    required this.dataType,
    this.sortable = true,
    this.filterable = true,
    this.aggregatable = false,
    this.defaultAggregation,
    this.format,
  });

  ReportColumn copyWith({
    String? id,
    String? fieldName,
    String? displayName,
    DataType? dataType,
    bool? sortable,
    bool? filterable,
    bool? aggregatable,
    AggregationType? defaultAggregation,
    String? format,
  }) {
    return ReportColumn(
      id: id ?? this.id,
      fieldName: fieldName ?? this.fieldName,
      displayName: displayName ?? this.displayName,
      dataType: dataType ?? this.dataType,
      sortable: sortable ?? this.sortable,
      filterable: filterable ?? this.filterable,
      aggregatable: aggregatable ?? this.aggregatable,
      defaultAggregation: defaultAggregation ?? this.defaultAggregation,
      format: format ?? this.format,
    );
  }
}

enum DataType { string, number, date, boolean, currency, percentage }

class ReportFilter {
  final String columnId;
  final FilterOperator operator;
  final dynamic value;
  final dynamic value2; // For BETWEEN operator

  ReportFilter({
    required this.columnId,
    required this.operator,
    required this.value,
    this.value2,
  });
}

enum FilterOperator {
  equals,
  notEquals,
  contains,
  startsWith,
  endsWith,
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual,
  between,
  inList,
  isNull,
  isNotNull,
}

class ReportSort {
  final String columnId;
  final bool ascending;

  ReportSort({required this.columnId, this.ascending = true});
}

class ReportConfiguration {
  final String id;
  final String name;
  final String description;
  final ReportDomain domain;
  final ReportType type;
  final List<ReportColumn> columns;
  final List<ReportColumn> selectedColumns;
  final List<ReportFilter> filters;
  final List<ReportSort> sorts;
  final Map<String, AggregationType> aggregations;
  final int pageSize;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool includeCharts;
  final Map<String, dynamic> customSettings;

  ReportConfiguration({
    required this.id,
    required this.name,
    required this.description,
    required this.domain,
    required this.type,
    required this.columns,
    required this.selectedColumns,
    this.filters = const [],
    this.sorts = const [],
    this.aggregations = const {},
    this.pageSize = 50,
    this.dateFrom,
    this.dateTo,
    this.includeCharts = false,
    this.customSettings = const {},
  });

  ReportConfiguration copyWith({
    String? id,
    String? name,
    String? description,
    ReportDomain? domain,
    ReportType? type,
    List<ReportColumn>? columns,
    List<ReportColumn>? selectedColumns,
    List<ReportFilter>? filters,
    List<ReportSort>? sorts,
    Map<String, AggregationType>? aggregations,
    int? pageSize,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? includeCharts,
    Map<String, dynamic>? customSettings,
  }) {
    return ReportConfiguration(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      domain: domain ?? this.domain,
      type: type ?? this.type,
      columns: columns ?? this.columns,
      selectedColumns: selectedColumns ?? this.selectedColumns,
      filters: filters ?? this.filters,
      sorts: sorts ?? this.sorts,
      aggregations: aggregations ?? this.aggregations,
      pageSize: pageSize ?? this.pageSize,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      includeCharts: includeCharts ?? this.includeCharts,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}

class ReportData {
  final List<Map<String, dynamic>> rows;
  final Map<String, dynamic> summary;
  final int totalCount;
  final DateTime generatedAt;

  ReportData({
    required this.rows,
    required this.summary,
    required this.totalCount,
    required this.generatedAt,
  });
}

// ==================== STATE MANAGEMENT ====================

class ReportBuilderState {
  final ReportConfiguration? currentConfig;
  final ReportData? currentData;
  final bool isLoading;
  final String? error;
  final List<ReportConfiguration> savedReports;

  ReportBuilderState({
    this.currentConfig,
    this.currentData,
    this.isLoading = false,
    this.error,
    this.savedReports = const [],
  });

  ReportBuilderState copyWith({
    ReportConfiguration? currentConfig,
    ReportData? currentData,
    bool? isLoading,
    String? error,
    List<ReportConfiguration>? savedReports,
  }) {
    return ReportBuilderState(
      currentConfig: currentConfig ?? this.currentConfig,
      currentData: currentData ?? this.currentData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      savedReports: savedReports ?? this.savedReports,
    );
  }
}

// ==================== PROVIDERS ====================

final reportBuilderProvider =
    StateNotifierProvider<ReportBuilderNotifier, ReportBuilderState>((ref) {
      return ReportBuilderNotifier(ref);
    });

class ReportBuilderNotifier extends StateNotifier<ReportBuilderState> {
  final Ref ref;

  ReportBuilderNotifier(this.ref) : super(ReportBuilderState());

  void createNewReport(ReportDomain domain) {
    final columns = _getColumnsForDomain(domain);
    final config = ReportConfiguration(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'New ${_getDomainName(domain)} Report',
      description: '',
      domain: domain,
      type: ReportType.tabular,
      columns: columns,
      selectedColumns: columns.take(5).toList(),
    );
    state = state.copyWith(currentConfig: config);
  }

  void updateConfiguration(ReportConfiguration config) {
    state = state.copyWith(currentConfig: config);
  }

  void addColumn(ReportColumn column) {
    if (state.currentConfig == null) return;
    final selectedColumns = [...state.currentConfig!.selectedColumns, column];
    state = state.copyWith(
      currentConfig: state.currentConfig!.copyWith(
        selectedColumns: selectedColumns,
      ),
    );
  }

  void removeColumn(String columnId) {
    if (state.currentConfig == null) return;
    final selectedColumns = state.currentConfig!.selectedColumns
        .where((c) => c.id != columnId)
        .toList();
    state = state.copyWith(
      currentConfig: state.currentConfig!.copyWith(
        selectedColumns: selectedColumns,
      ),
    );
  }

  void reorderColumns(int oldIndex, int newIndex) {
    if (state.currentConfig == null) return;
    final columns = List<ReportColumn>.from(
      state.currentConfig!.selectedColumns,
    );
    if (newIndex > oldIndex) newIndex--;
    final column = columns.removeAt(oldIndex);
    columns.insert(newIndex, column);
    state = state.copyWith(
      currentConfig: state.currentConfig!.copyWith(selectedColumns: columns),
    );
  }

  void addFilter(ReportFilter filter) {
    if (state.currentConfig == null) return;
    final filters = [...state.currentConfig!.filters, filter];
    state = state.copyWith(
      currentConfig: state.currentConfig!.copyWith(filters: filters),
    );
  }

  void removeFilter(int index) {
    if (state.currentConfig == null) return;
    final filters = List<ReportFilter>.from(state.currentConfig!.filters);
    filters.removeAt(index);
    state = state.copyWith(
      currentConfig: state.currentConfig!.copyWith(filters: filters),
    );
  }

  void addSort(ReportSort sort) {
    if (state.currentConfig == null) return;
    final sorts = [...state.currentConfig!.sorts, sort];
    state = state.copyWith(
      currentConfig: state.currentConfig!.copyWith(sorts: sorts),
    );
  }

  void updateAggregation(String columnId, AggregationType? type) {
    if (state.currentConfig == null) return;
    final aggregations = Map<String, AggregationType>.from(
      state.currentConfig!.aggregations,
    );
    if (type == null) {
      aggregations.remove(columnId);
    } else {
      aggregations[columnId] = type;
    }
    state = state.copyWith(
      currentConfig: state.currentConfig!.copyWith(aggregations: aggregations),
    );
  }

  Future<void> generateReport() async {
    if (state.currentConfig == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final data = _generateMockData(state.currentConfig!);
      state = state.copyWith(currentData: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void saveReport() {
    if (state.currentConfig == null) return;
    final savedReports = [...state.savedReports, state.currentConfig!];
    state = state.copyWith(savedReports: savedReports);
  }

  void loadReport(ReportConfiguration config) {
    state = state.copyWith(currentConfig: config);
  }

  Future<void> exportReport(ExportFormat format) async {
    if (state.currentData == null) return;
    // Implementation for export logic
    await Future.delayed(const Duration(milliseconds: 500));
  }

  List<ReportColumn> _getColumnsForDomain(ReportDomain domain) {
    switch (domain) {
      case ReportDomain.sales:
        return [
          ReportColumn(
            id: 'order_id',
            fieldName: 'orderId',
            displayName: 'Order ID',
            dataType: DataType.string,
          ),
          ReportColumn(
            id: 'customer',
            fieldName: 'customer',
            displayName: 'Customer',
            dataType: DataType.string,
          ),
          ReportColumn(
            id: 'amount',
            fieldName: 'amount',
            displayName: 'Amount',
            dataType: DataType.currency,
            aggregatable: true,
            defaultAggregation: AggregationType.sum,
          ),
          ReportColumn(
            id: 'quantity',
            fieldName: 'quantity',
            displayName: 'Quantity',
            dataType: DataType.number,
            aggregatable: true,
            defaultAggregation: AggregationType.sum,
          ),
          ReportColumn(
            id: 'date',
            fieldName: 'date',
            displayName: 'Order Date',
            dataType: DataType.date,
          ),
          ReportColumn(
            id: 'status',
            fieldName: 'status',
            displayName: 'Status',
            dataType: DataType.string,
          ),
          ReportColumn(
            id: 'region',
            fieldName: 'region',
            displayName: 'Region',
            dataType: DataType.string,
          ),
        ];
      case ReportDomain.finance:
        return [
          ReportColumn(
            id: 'transaction_id',
            fieldName: 'transactionId',
            displayName: 'Transaction ID',
            dataType: DataType.string,
          ),
          ReportColumn(
            id: 'account',
            fieldName: 'account',
            displayName: 'Account',
            dataType: DataType.string,
          ),
          ReportColumn(
            id: 'debit',
            fieldName: 'debit',
            displayName: 'Debit',
            dataType: DataType.currency,
            aggregatable: true,
          ),
          ReportColumn(
            id: 'credit',
            fieldName: 'credit',
            displayName: 'Credit',
            dataType: DataType.currency,
            aggregatable: true,
          ),
          ReportColumn(
            id: 'balance',
            fieldName: 'balance',
            displayName: 'Balance',
            dataType: DataType.currency,
          ),
          ReportColumn(
            id: 'date',
            fieldName: 'date',
            displayName: 'Date',
            dataType: DataType.date,
          ),
        ];
      default:
        return [];
    }
  }

  String _getDomainName(ReportDomain domain) {
    return domain.name[0].toUpperCase() + domain.name.substring(1);
  }

  ReportData _generateMockData(ReportConfiguration config) {
    final rows = List.generate(50, (i) {
      final map = <String, dynamic>{};
      for (var col in config.selectedColumns) {
        map[col.fieldName] = _generateMockValue(col.dataType, i);
      }
      return map;
    });

    final summary = <String, dynamic>{};
    for (var entry in config.aggregations.entries) {
      final column = config.selectedColumns.firstWhere(
        (c) => c.id == entry.key,
      );
      summary[column.fieldName] = _calculateAggregation(
        rows.map((r) => r[column.fieldName]).toList(),
        entry.value,
      );
    }

    return ReportData(
      rows: rows,
      summary: summary,
      totalCount: rows.length,
      generatedAt: DateTime.now(),
    );
  }

  dynamic _generateMockValue(DataType type, int index) {
    switch (type) {
      case DataType.string:
        return 'Value ${index + 1}';
      case DataType.number:
        return (index + 1) * 10;
      case DataType.currency:
        return (index + 1) * 100.0;
      case DataType.date:
        return DateTime.now().subtract(Duration(days: index));
      case DataType.boolean:
        return index % 2 == 0;
      case DataType.percentage:
        return (index + 1) * 5.0;
    }
  }

  dynamic _calculateAggregation(List<dynamic> values, AggregationType type) {
    final numbers = values.whereType<num>().toList();
    if (numbers.isEmpty) return 0;

    switch (type) {
      case AggregationType.sum:
        return numbers.reduce((a, b) => a + b);
      case AggregationType.average:
        return numbers.reduce((a, b) => a + b) / numbers.length;
      case AggregationType.count:
        return numbers.length;
      case AggregationType.min:
        return numbers.reduce((a, b) => a < b ? a : b);
      case AggregationType.max:
        return numbers.reduce((a, b) => a > b ? a : b);
      case AggregationType.median:
        final sorted = List<num>.from(numbers)..sort();
        final mid = sorted.length ~/ 2;
        return sorted.length % 2 == 0
            ? (sorted[mid - 1] + sorted[mid]) / 2
            : sorted[mid];
    }
  }
}

// ==================== UI COMPONENTS ====================

class ReportBuilderScreen extends ConsumerWidget {
  const ReportBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportBuilderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Report Builder'),
        actions: [
          if (state.currentConfig != null) ...[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () =>
                  ref.read(reportBuilderProvider.notifier).saveReport(),
              tooltip: 'Save Report',
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () =>
                  ref.read(reportBuilderProvider.notifier).generateReport(),
              tooltip: 'Generate Report',
            ),
            PopupMenuButton<ExportFormat>(
              icon: const Icon(Icons.download),
              onSelected: (format) =>
                  ref.read(reportBuilderProvider.notifier).exportReport(format),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: ExportFormat.pdf,
                  child: Text('Export as PDF'),
                ),
                const PopupMenuItem(
                  value: ExportFormat.excel,
                  child: Text('Export as Excel'),
                ),
                const PopupMenuItem(
                  value: ExportFormat.csv,
                  child: Text('Export as CSV'),
                ),
              ],
            ),
          ],
        ],
      ),
      body: state.currentConfig == null
          ? _buildDomainSelector(context, ref)
          : Row(
              children: [
                SizedBox(
                  width: 350,
                  child: _buildConfigPanel(context, ref, state),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _buildPreviewPanel(context, ref, state)),
              ],
            ),
    );
  }

  Widget _buildDomainSelector(BuildContext context, WidgetRef ref) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Report Domain',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: ReportDomain.values.map((domain) {
                return _DomainCard(
                  domain: domain,
                  onTap: () => ref
                      .read(reportBuilderProvider.notifier)
                      .createNewReport(domain),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigPanel(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildBasicInfo(context, ref, state),
        const SizedBox(height: 24),
        _buildColumnSelection(context, ref, state),
        const SizedBox(height: 24),
        _buildFiltersSection(context, ref, state),
        const SizedBox(height: 24),
        _buildSortingSection(context, ref, state),
        const SizedBox(height: 24),
        _buildAggregationSection(context, ref, state),
      ],
    );
  }

  Widget _buildBasicInfo(
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
            const Text(
              'Report Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: state.currentConfig!.name,
              decoration: const InputDecoration(
                labelText: 'Report Name',
                border: OutlineInputBorder(),
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
          ],
        ),
      ),
    );
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selected Columns',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showColumnPicker(context, ref, state),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(reportBuilderProvider.notifier)
                    .reorderColumns(oldIndex, newIndex);
              },
              children: state.currentConfig!.selectedColumns.map((col) {
                return ListTile(
                  key: ValueKey(col.id),
                  leading: const Icon(Icons.drag_handle),
                  title: Text(col.displayName),
                  subtitle: Text(col.dataType.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => ref
                        .read(reportBuilderProvider.notifier)
                        .removeColumn(col.id),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showFilterDialog(context, ref, state),
                ),
              ],
            ),
            if (state.currentConfig!.filters.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No filters applied'),
              )
            else
              ...state.currentConfig!.filters.asMap().entries.map((entry) {
                final index = entry.key;
                final filter = entry.value;
                final column = state.currentConfig!.columns.firstWhere(
                  (c) => c.id == filter.columnId,
                );
                return ListTile(
                  title: Text(column.displayName),
                  subtitle: Text('${filter.operator.name}: ${filter.value}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => ref
                        .read(reportBuilderProvider.notifier)
                        .removeFilter(index),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildSortingSection(
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
            const Text(
              'Sorting',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Sort By',
                border: OutlineInputBorder(),
              ),
              items: state.currentConfig!.selectedColumns.map((col) {
                return DropdownMenuItem(
                  value: col.id,
                  child: Text(col.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(reportBuilderProvider.notifier)
                      .addSort(ReportSort(columnId: value));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAggregationSection(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    final aggregatableColumns = state.currentConfig!.selectedColumns
        .where((c) => c.aggregatable)
        .toList();

    if (aggregatableColumns.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aggregations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...aggregatableColumns.map((col) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(child: Text(col.displayName)),
                    DropdownButton<AggregationType?>(
                      value: state.currentConfig!.aggregations[col.id],
                      hint: const Text('None'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('None'),
                        ),
                        ...AggregationType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.name.toUpperCase()),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        ref
                            .read(reportBuilderProvider.notifier)
                            .updateAggregation(col.id, value);
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewPanel(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
          ],
        ),
      );
    }

    if (state.currentData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assessment, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Click Generate to preview report'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(reportBuilderProvider.notifier).generateReport(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Generate Report'),
            ),
          ],
        ),
      );
    }

    return _ReportDataTable(
      config: state.currentConfig!,
      data: state.currentData!,
    );
  }

  void _showColumnPicker(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    final availableColumns = state.currentConfig!.columns
        .where((col) => !state.currentConfig!.selectedColumns.contains(col))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Column'),
        content: SizedBox(
          width: 400,
          child: ListView(
            shrinkWrap: true,
            children: availableColumns.map((col) {
              return ListTile(
                title: Text(col.displayName),
                subtitle: Text(col.dataType.name),
                onTap: () {
                  ref.read(reportBuilderProvider.notifier).addColumn(col);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    String? selectedColumnId;
    FilterOperator selectedOperator = FilterOperator.equals;
    String filterValue = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Filter'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Column',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedColumnId,
                  items: state.currentConfig!.selectedColumns
                      .where((c) => c.filterable)
                      .map((col) {
                        return DropdownMenuItem(
                          value: col.id,
                          child: Text(col.displayName),
                        );
                      })
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedColumnId = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<FilterOperator>(
                  decoration: const InputDecoration(
                    labelText: 'Operator',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedOperator,
                  items: FilterOperator.values.map((op) {
                    return DropdownMenuItem(
                      value: op,
                      child: Text(_getOperatorLabel(op)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedOperator = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (selectedOperator != FilterOperator.isNull &&
                    selectedOperator != FilterOperator.isNotNull)
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => filterValue = value,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedColumnId == null
                  ? null
                  : () {
                      ref
                          .read(reportBuilderProvider.notifier)
                          .addFilter(
                            ReportFilter(
                              columnId: selectedColumnId!,
                              operator: selectedOperator,
                              value: filterValue,
                            ),
                          );
                      Navigator.pop(context);
                    },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  String _getOperatorLabel(FilterOperator op) {
    switch (op) {
      case FilterOperator.equals:
        return 'Equals';
      case FilterOperator.notEquals:
        return 'Not Equals';
      case FilterOperator.contains:
        return 'Contains';
      case FilterOperator.startsWith:
        return 'Starts With';
      case FilterOperator.endsWith:
        return 'Ends With';
      case FilterOperator.greaterThan:
        return 'Greater Than';
      case FilterOperator.lessThan:
        return 'Less Than';
      case FilterOperator.greaterThanOrEqual:
        return 'Greater Than or Equal';
      case FilterOperator.lessThanOrEqual:
        return 'Less Than or Equal';
      case FilterOperator.between:
        return 'Between';
      case FilterOperator.inList:
        return 'In List';
      case FilterOperator.isNull:
        return 'Is Null';
      case FilterOperator.isNotNull:
        return 'Is Not Null';
    }
  }
}

class _DomainCard extends StatelessWidget {
  final ReportDomain domain;
  final VoidCallback onTap;

  const _DomainCard({required this.domain, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getIcon(), size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                _getLabel(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (domain) {
      case ReportDomain.sales:
        return Icons.shopping_cart;
      case ReportDomain.finance:
        return Icons.account_balance;
      case ReportDomain.operations:
        return Icons.settings;
      case ReportDomain.hr:
        return Icons.people;
      case ReportDomain.marketing:
        return Icons.campaign;
      case ReportDomain.analytics:
        return Icons.analytics;
    }
  }

  String _getLabel() {
    return domain.name[0].toUpperCase() + domain.name.substring(1);
  }
}

class _ReportDataTable extends StatelessWidget {
  final ReportConfiguration config;
  final ReportData data;

  const _ReportDataTable({required this.config, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with summary
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    config.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Generated: ${DateFormat('MMM dd, yyyy HH:mm').format(data.generatedAt)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Total Records: ${data.totalCount}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (data.summary.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: data.summary.entries.map((entry) {
                    return Chip(
                      label: Text('${entry.key}: ${_formatValue(entry.value)}'),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        // Data table
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: config.selectedColumns.map((col) {
                  return DataColumn(
                    label: Text(
                      col.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                rows: data.rows.map((row) {
                  return DataRow(
                    cells: config.selectedColumns.map((col) {
                      final value = row[col.fieldName];
                      return DataCell(
                        Text(_formatCellValue(value, col.dataType)),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatValue(dynamic value) {
    if (value is num) {
      return NumberFormat('#,##0.00').format(value);
    }
    return value.toString();
  }

  String _formatCellValue(dynamic value, DataType type) {
    if (value == null) return '-';

    switch (type) {
      case DataType.currency:
        return NumberFormat.currency(symbol: '\\').format(value);
      case DataType.number:
        return NumberFormat('#,##0').format(value);
      case DataType.date:
        if (value is DateTime) {
          return DateFormat('MMM dd, yyyy').format(value);
        }
        return value.toString();
      case DataType.percentage:
        return '${value}%';
      case DataType.boolean:
        return value ? 'Yes' : 'No';
      default:
        return value.toString();
    }
  }
}

// ==================== MAIN APP ====================

void main() {
  runApp(const ProviderScope(child: ReportBuilderApp()));
}

class ReportBuilderApp extends StatelessWidget {
  const ReportBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Report Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: const ReportBuilderScreen(),
    );
  }
}
