import 'dart:math' as math show min;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:report_builder/model/data_source.dart';

import '../model/chart_configuration.dart';
import '../model/data_type.dart';
import '../model/page_layout.dart';
import '../model/report.dart';
import '../model/report_column.dart';
import '../model/report_component.dart';
import '../model/report_configuration.dart';
import '../model/report_filter.dart';
import '../model/report_grouping.dart';
import '../model/report_page.dart';
import '../model/report_sort.dart';
import 'column_configuration_provider.dart';
import 'database_provider.dart';
import 'export_provider.dart';
import 'report_builder_state.dart';

import 'report_generation_provider.dart';

final reportBuilderProvider =
    StateNotifierProvider<ReportBuilderNotifier, ReportBuilderState>((ref) {
      return ReportBuilderNotifier(ref);
    });

class ReportBuilderNotifier extends StateNotifier<ReportBuilderState> {
  final Ref ref;
  late final ColumnConfigurationService _columnService;
  late final ReportGenerationService _reportGenerationService;
  late final ExportServiceWrapper _exportServiceWrapper;

  ReportBuilderNotifier(this.ref) : super(ReportBuilderState()) {
    _columnService = ref.read(columnConfigurationServiceProvider);
    _reportGenerationService = ref.read(reportGenerationServiceProvider);
    _exportServiceWrapper = ref.read(exportServiceWrapperProvider);
    _initializeDefaultPage();
    _loadSavedReports();
  }

  void _initializeDefaultPage() {
    final defaultLayout = PageLayout(id: 'default');
    final page = ReportPage(
      id: '1',
      name: 'Page 1',
      pageNumber: 1,
      layout: defaultLayout,
    );
    state = state.copyWith(pages: [page]);
  }

  Future<void> _loadSavedReports() async {
    final db = ref.read(databaseProvider);
    final reports = await db.getSavedReports();
    state = state.copyWith(savedReports: reports);
  }

  void createNewReport(ReportDomain domain) {
    final columns = _columnService.getColumnsForDomain(domain);
    final config = ReportConfiguration(
      name: 'New ${_columnService.getDomainName(domain)} Report',
      description: '',
      domain: domain,
      type: ReportType.tabular,
      columns: columns,
      selectedColumns: columns.take(6).toList(),
      dataSource: DataSource(
        id: 'id',
        name: 'name',
        type: DataSourceType.excel,
        connectionConfig: {},
      ),
      ownerId: '',
      ownerName: '',
    );
    state = state.copyWith(currentConfig: config, showPreview: false);
  }

  void updateConfiguration(ReportConfiguration config) {
    state = state.copyWith(currentConfig: config);
  }

  // Column management methods
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

  void updateColumnWidth(String columnId, int width) {
    if (state.currentConfig == null) return;
    final columns = state.currentConfig!.selectedColumns.map((col) {
      return col.id == columnId ? col.copyWith(width: width) : col;
    }).toList();
    state = state.copyWith(
      currentConfig: state.currentConfig!.copyWith(selectedColumns: columns),
    );
  }

  // Filter management methods
  void addFilter(ReportFilter filter) {
    if (state.currentConfig == null) return;
    final filters = [...state.currentConfig!.filters, filter];
    state = state.copyWith(
      currentConfig: state.currentConfig!.copyWith(filters: filters),
    );
  }

  void updateFilter(int index, ReportFilter filter) {
    if (state.currentConfig == null) return;
    final filters = List<ReportFilter>.from(state.currentConfig!.filters);
    filters[index] = filter;
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

  // Sort management methods
  void addSort(ReportSort sort) {
    if (state.currentConfig == null) return;
    final sorts = [...state.currentConfig!.sorts, sort];
    state = state.copyWith(
      currentConfig: state.currentConfig!.copyWith(sorts: sorts),
    );
  }

  void removeSort(String columnId) {
    if (state.currentConfig == null) return;
    final sorts = state.currentConfig!.sorts
        .where((s) => s.columnId != columnId)
        .toList();
    state = state.copyWith(
      currentConfig: state.currentConfig!.copyWith(sorts: sorts),
    );
  }

  // Grouping management methods
  void addGrouping(ReportGrouping grouping) {
    if (state.currentConfig == null) return;
    final groupings = [...state.currentConfig!.groupings, grouping];
    state = state.copyWith(
      currentConfig: state.currentConfig!.copyWith(groupings: groupings),
    );
  }

  void removeGrouping(String columnId) {
    if (state.currentConfig == null) return;
    final groupings = state.currentConfig!.groupings
        .where((g) => g.columnId != columnId)
        .toList();
    state = state.copyWith(
      currentConfig: state.currentConfig!.copyWith(groupings: groupings),
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

  void setChartConfiguration(ChartConfiguration? config) {
    if (state.currentConfig == null) return;
    state = state.copyWith(
      currentConfig: state.currentConfig!.copyWith(chartConfig: config),
    );
  }

  void toggleGroupExpansion(String groupKey) {
    final expanded = Map<String, bool>.from(state.expandedGroups);
    expanded[groupKey] = !(expanded[groupKey] ?? true);
    state = state.copyWith(expandedGroups: expanded);
  }

  Future<void> generateReport() async {
    if (state.currentConfig == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _reportGenerationService.generateReport(
        state.currentConfig!,
      );

      state = state.copyWith(
        currentData: data,
        isLoading: false,
        showPreview: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveReport() async {
    if (state.currentConfig == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final db = ref.read(databaseProvider);
      await db.saveReport(state.currentConfig!);
      await _loadSavedReports();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteReport(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final db = ref.read(databaseProvider);
      await db.deleteReport(id);
      await _loadSavedReports();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void loadReport(ReportConfiguration config) {
    state = state.copyWith(currentConfig: config, showPreview: false);
  }

  Future<void> exportReport(ExportFormat format) async {
    if (state.currentData == null || state.currentConfig == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final success = await _exportServiceWrapper.exportReport(
        state.currentConfig!,
        state.currentData!,
        format,
      );

      state = state.copyWith(
        isLoading: false,
        error: success ? null : 'Export failed',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void duplicateReport() {
    if (state.currentConfig == null) return;
    final newConfig = state.currentConfig!.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${state.currentConfig!.name} (Copy)',
    );
    state = state.copyWith(currentConfig: newConfig);
  }

  //-----

  void addPage() {
    final newPage = ReportPage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Page ${state.pages.length + 1}',
      pageNumber: state.pages.length + 1,
      layout: PageLayout(id: 'layout_${state.pages.length + 1}'),
    );
    state = state.copyWith(pages: [...state.pages, newPage]);
  }

  void removePage(int index) {
    if (state.pages.length <= 1) return;
    final pages = List<ReportPage>.from(state.pages);
    pages.removeAt(index);
    state = state.copyWith(
      pages: pages,
      currentPageIndex: math.min(state.currentPageIndex, pages.length - 1),
    );
  }

  void setCurrentPage(int index) {
    if (index >= 0 && index < state.pages.length) {
      state = state.copyWith(currentPageIndex: index);
    }
  }

  void addComponent(ComponentType type) {
    if (state.currentPage == null) return;

    final component = ReportComponent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      name: _getComponentName(type),
      position: Offset(50, 50),
      size: _getDefaultSize(type),
      properties: _getDefaultProperties(type),
    );

    final updatedComponents = [...state.currentPage!.components, component];
    final updatedPage = state.currentPage!.copyWith(
      components: updatedComponents,
    );
    final pages = List<ReportPage>.from(state.pages);
    pages[state.currentPageIndex] = updatedPage;

    state = state.copyWith(pages: pages);
  }

  void updateComponentPosition(String componentId, Offset position) {
    if (state.currentPage == null) return;

    final components = state.currentPage!.components.map((c) {
      if (c.id == componentId) {
        final snappedPosition = state.dragDropState.snapToGrid
            ? _snapToGrid(position, state.dragDropState.gridSize)
            : position;
        return c.copyWith(position: snappedPosition);
      }
      return c;
    }).toList();

    final updatedPage = state.currentPage!.copyWith(components: components);
    final pages = List<ReportPage>.from(state.pages);
    pages[state.currentPageIndex] = updatedPage;

    state = state.copyWith(pages: pages);
  }

  void updateComponentSize(String componentId, Size size) {
    if (state.currentPage == null) return;

    final components = state.currentPage!.components.map((c) {
      return c.id == componentId ? c.copyWith(size: size) : c;
    }).toList();

    final updatedPage = state.currentPage!.copyWith(components: components);
    final pages = List<ReportPage>.from(state.pages);
    pages[state.currentPageIndex] = updatedPage;

    state = state.copyWith(pages: pages);
  }

  void removeComponent(String componentId) {
    if (state.currentPage == null) return;

    final components = state.currentPage!.components
        .where((c) => c.id != componentId)
        .toList();

    final updatedPage = state.currentPage!.copyWith(components: components);
    final pages = List<ReportPage>.from(state.pages);
    pages[state.currentPageIndex] = updatedPage;

    state = state.copyWith(pages: pages);
  }

  void selectComponent(String componentId) {
    final component = state.currentPage?.components.firstWhere(
      (c) => c.id == componentId,
    );

    if (component != null) {
      state = state.copyWith(
        dragDropState: state.dragDropState.copyWith(
          selectedComponents: [component],
        ),
      );
    }
  }

  void deselectAll() {
    state = state.copyWith(
      dragDropState: state.dragDropState.copyWith(selectedComponents: []),
    );
  }

  void toggleGrid() {
    state = state.copyWith(
      dragDropState: state.dragDropState.copyWith(
        showGrid: !state.dragDropState.showGrid,
      ),
    );
  }

  void toggleSnapToGrid() {
    state = state.copyWith(
      dragDropState: state.dragDropState.copyWith(
        snapToGrid: !state.dragDropState.snapToGrid,
      ),
    );
  }

  void setZoom(double zoom) {
    state = state.copyWith(zoom: zoom.clamp(0.25, 2.0));
  }

  void togglePreviewMode() {
    state = state.copyWith(isPreviewMode: !state.isPreviewMode);
  }

  void updatePagination(int page, int itemsPerPage) {
    final totalPages = (state.paginationConfig.totalItems / itemsPerPage)
        .ceil();
    state = state.copyWith(
      paginationConfig: state.paginationConfig.copyWith(
        currentPage: page,
        itemsPerPage: itemsPerPage,
        totalPages: totalPages,
      ),
    );
  }

  Offset _snapToGrid(Offset position, double gridSize) {
    return Offset(
      (position.dx / gridSize).round() * gridSize,
      (position.dy / gridSize).round() * gridSize,
    );
  }

  String _getComponentName(ComponentType type) {
    return '${type.name[0].toUpperCase()}${type.name.substring(1)} Component';
  }

  Size _getDefaultSize(ComponentType type) {
    switch (type) {
      case ComponentType.text:
        return const Size(200, 40);
      case ComponentType.table:
        return const Size(400, 200);
      case ComponentType.chart:
        return const Size(350, 250);
      case ComponentType.image:
        return const Size(150, 150);
      case ComponentType.divider:
        return const Size(300, 2);
      case ComponentType.metric:
        return const Size(150, 100);
      default:
        return const Size(200, 100);
    }
  }

  Map<String, dynamic> _getDefaultProperties(ComponentType type) {
    switch (type) {
      case ComponentType.text:
        return {
          'text': 'Sample Text',
          'fontSize': 14.0,
          'fontWeight': 'normal',
          'color': Colors.black.value,
        };
      case ComponentType.table:
        return {'rows': 5, 'columns': 3, 'showHeader': true};
      case ComponentType.chart:
        return {'chartType': 'bar', 'showLegend': true};
      default:
        return {};
    }
  }
}
