import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../model/chart_configuration.dart';
import '../model/data_type.dart';
import '../model/page_layout.dart';
import '../model/report.dart';

import '../model/report_component.dart';
import '../model/report_filter.dart';
import '../model/report_grouping.dart';
import '../model/report_sort.dart';
import '../state/report_builder_provider.dart';
import '../state/report_builder_state.dart';
import '../utils/utils.dart';
import '../widget/domain_card.dart';
import '../widget/gauge_painter.dart';
import '../widget/grid_painter.dart';
import '../widget/report_data_table.dart';
import '../widget/simple_chart_painter.dart';

class ReportBuilderScreen extends ConsumerStatefulWidget {
  const ReportBuilderScreen({super.key});

  @override
  ConsumerState<ReportBuilderScreen> createState() =>
      _ReportBuilderScreenState();
}

class _ReportBuilderScreenState extends ConsumerState<ReportBuilderScreen> {
  final _reorderableKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportBuilderProvider);

    return Scaffold(
      appBar: _buildAppBar(context, ref, state),

      drawer: state.currentConfig != null
          ? null
          : _buildNavigationDrawer(context, ref, state),
      body: state.currentConfig == null
          ? _buildDomainSelector(context, ref)
          : Row(
              children: [
                SizedBox(
                  width: 380,
                  child: _buildConfigPanel(context, ref, state),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _buildPreviewPanel(context, ref, state)),
                // Component Library Panel
                if (!state.isPreviewMode) _buildComponentLibrary(context, ref),

                // Main Canvas Area
                Expanded(
                  child: Column(
                    children: [
                      _buildToolbar(context, ref, state),
                      Expanded(child: _buildCanvas(context, ref, state)),
                      _buildPaginationBar(context, ref, state),
                    ],
                  ),
                ),

                // Properties Panel
                if (!state.isPreviewMode &&
                    state.dragDropState.selectedComponents.isNotEmpty)
                  _buildPropertiesPanel(context, ref, state),
              ],
            ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.view_column, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Columns',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${state.currentConfig!.selectedColumns.length} selected',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _showColumnPicker(context, ref, state),
                      tooltip: 'Add Column',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.currentConfig!.selectedColumns.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text('No columns selected. Click + to add columns.'),
                ),
              )
            else
              ReorderableListView(
                key: ValueKey(
                  'columns_${state.currentConfig!.selectedColumns.length}_${state.currentConfig!.selectedColumns.map((e) => e.id).join('_')}',
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  ref
                      .read(reportBuilderProvider.notifier)
                      .reorderColumns(oldIndex, newIndex);
                },
                children: state.currentConfig!.selectedColumns.map((col) {
                  return Card(
                    key: ValueKey(col.id),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.drag_handle, size: 20),
                          const SizedBox(width: 8),
                          Icon(getDataTypeIcon(col.dataType), size: 18),
                        ],
                      ),
                      title: Text(col.displayName),
                      subtitle: Text(
                        col.dataType.name,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (col.aggregatable)
                            Icon(
                              Icons.functions,
                              size: 16,
                              color: Colors.blue[300],
                            ),
                          if (col.groupable)
                            Icon(
                              Icons.group_work,
                              size: 16,
                              color: Colors.green[300],
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => ref
                                .read(reportBuilderProvider.notifier)
                                .removeColumn(col.id),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    return AppBar(
      title: const Text('Report Builder - Drag & Drop Layout'),
      actions: [
        if (state.currentConfig != null) ...[
          IconButton(
            icon: const Icon(Icons.content_copy),
            onPressed: () =>
                ref.read(reportBuilderProvider.notifier).duplicateReport(),
            tooltip: 'Duplicate Report',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () =>
                ref.read(reportBuilderProvider.notifier).saveReport(),
            tooltip: 'Save Report',
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: state.isLoading
                ? null
                : () =>
                      ref.read(reportBuilderProvider.notifier).generateReport(),
            tooltip: 'Generate Report',
          ),
          if (state.currentData != null)
            PopupMenuButton<ExportFormat>(
              icon: const Icon(Icons.download),
              tooltip: 'Export',
              onSelected: (format) =>
                  ref.read(reportBuilderProvider.notifier).exportReport(format),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: ExportFormat.pdf,
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 20),
                      SizedBox(width: 12),
                      Text('Export as PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ExportFormat.excel,
                  child: Row(
                    children: [
                      Icon(Icons.table_chart, size: 20),
                      SizedBox(width: 12),
                      Text('Export as Excel'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ExportFormat.csv,
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file, size: 20),
                      SizedBox(width: 12),
                      Text('Export as CSV'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ExportFormat.json,
                  child: Row(
                    children: [
                      Icon(Icons.data_object, size: 20),
                      SizedBox(width: 12),
                      Text('Export as JSON'),
                    ],
                  ),
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () => _showSavedReports(context, ref),
            tooltip: 'Saved Reports',
          ),
        ],
        IconButton(
          icon: Icon(state.isPreviewMode ? Icons.edit : Icons.preview),
          onPressed: () =>
              ref.read(reportBuilderProvider.notifier).togglePreviewMode(),
          tooltip: state.isPreviewMode ? 'Edit Mode' : 'Preview Mode',
        ),
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () {},
          tooltip: 'Save',
        ),
        IconButton(
          icon: const Icon(Icons.print),
          onPressed: () {},
          tooltip: 'Print',
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {},
          tooltip: 'Export',
        ),
      ],
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          // Zoom controls
          IconButton(
            icon: const Icon(Icons.remove),
            iconSize: 20,
            onPressed: () => ref
                .read(reportBuilderProvider.notifier)
                .setZoom(state.zoom - 0.1),
          ),
          Text('${(state.zoom * 100).toInt()}%'),
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: 20,
            onPressed: () => ref
                .read(reportBuilderProvider.notifier)
                .setZoom(state.zoom + 0.1),
          ),
          const VerticalDivider(),
          // Grid controls
          IconButton(
            icon: Icon(
              state.dragDropState.showGrid ? Icons.grid_on : Icons.grid_off,
            ),
            iconSize: 20,
            onPressed: () =>
                ref.read(reportBuilderProvider.notifier).toggleGrid(),
            tooltip: 'Toggle Grid',
          ),
          IconButton(
            icon: Icon(
              state.dragDropState.snapToGrid
                  ? Icons.align_horizontal_left
                  : Icons.align_horizontal_center,
            ),
            iconSize: 20,
            onPressed: () =>
                ref.read(reportBuilderProvider.notifier).toggleSnapToGrid(),
            tooltip: 'Snap to Grid',
          ),
          const VerticalDivider(),
          // Alignment tools
          IconButton(
            icon: const Icon(Icons.align_horizontal_left),
            iconSize: 20,
            onPressed: () {},
            tooltip: 'Align Left',
          ),
          IconButton(
            icon: const Icon(Icons.align_horizontal_center),
            iconSize: 20,
            onPressed: () {},
            tooltip: 'Align Center',
          ),
          IconButton(
            icon: const Icon(Icons.align_horizontal_right),
            iconSize: 20,
            onPressed: () {},
            tooltip: 'Align Right',
          ),
          const VerticalDivider(),
          // Layer controls
          IconButton(
            icon: const Icon(Icons.flip_to_front),
            iconSize: 20,
            onPressed: () {},
            tooltip: 'Bring to Front',
          ),
          IconButton(
            icon: const Icon(Icons.flip_to_back),
            iconSize: 20,
            onPressed: () {},
            tooltip: 'Send to Back',
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    if (state.currentPage == null) {
      return const Center(child: Text('No page available'));
    }

    return Container(
      color: Colors.grey[300],
      child: InteractiveViewer(
        minScale: 0.25,
        maxScale: 2.0,
        constrained: false,
        child: Center(
          child: Transform.scale(
            scale: state.zoom,
            child: _buildPageCanvas(context, ref, state),
          ),
        ),
      ),
    );
  }

  Widget _buildPageCanvas(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    final page = state.currentPage!;
    final layout = page.layout;

    return GestureDetector(
      onTap: () => ref.read(reportBuilderProvider.notifier).deselectAll(),
      child: Container(
        width: layout.width,
        height: layout.height,
        margin: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: layout.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Grid overlay
            if (state.dragDropState.showGrid && !state.isPreviewMode)
              _buildGridOverlay(layout, state.dragDropState.gridSize),

            // Page margins guide
            if (!state.isPreviewMode) _buildMarginsGuide(layout),

            // Components
            ...page.components.map((component) {
              return _buildDraggableComponent(
                context,
                ref,
                component,
                state.isPreviewMode,
                state.dragDropState.selectedComponents.contains(component),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGridOverlay(PageLayout layout, double gridSize) {
    return CustomPaint(
      size: Size(layout.width, layout.height),
      painter: GridPainter(gridSize: gridSize),
    );
  }

  IconData _getComponentIcon(ComponentType type) {
    switch (type) {
      case ComponentType.text:
        return Icons.text_fields;
      case ComponentType.table:
        return Icons.table_chart;
      case ComponentType.chart:
        return Icons.bar_chart;
      case ComponentType.image:
        return Icons.image;
      case ComponentType.divider:
        return Icons.horizontal_rule;
      case ComponentType.spacer:
        return Icons.space_bar;
      case ComponentType.container:
        return Icons.crop_square;
      case ComponentType.header:
        return Icons.view_headline;
      case ComponentType.footer:
        return Icons.view_stream;
      case ComponentType.pageBreak:
        return Icons.flip_to_back;
      case ComponentType.qrCode:
        return Icons.qr_code;
      case ComponentType.barcode:
        return Icons.qr_code_scanner;
      case ComponentType.signature:
        return Icons.draw;
      case ComponentType.richText:
        return Icons.format_size;
      case ComponentType.formula:
        return Icons.functions;
      case ComponentType.metric:
        return Icons.speed;
      case ComponentType.gauge:
        return Icons.donut_large;
      case ComponentType.progress:
        return Icons.linear_scale;
      case ComponentType.timeline:
        return Icons.timeline;
      case ComponentType.calendar:
        return Icons.calendar_month;
      case ComponentType.map:
        return Icons.map;
      case ComponentType.custom:
        return Icons.extension;
    }
  }

  Widget _buildMarginsGuide(PageLayout layout) {
    return Positioned.fill(
      child: Container(
        margin: layout.margins,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
        ),
      ),
    );
  }

  Widget _buildComponentCategory(
    String title,
    List<ComponentType> components,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...components.map((type) => _buildComponentTile(type, ref)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildComponentTile(ComponentType type, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: Icon(_getComponentIcon(type), size: 20),
        title: Text(
          type.name[0].toUpperCase() + type.name.substring(1),
          style: const TextStyle(fontSize: 13),
        ),
        onTap: () =>
            ref.read(reportBuilderProvider.notifier).addComponent(type),
        trailing: const Icon(Icons.add, size: 18),
      ),
    );
  }

  Widget _buildComponentLibrary(BuildContext context, WidgetRef ref) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: const Row(
              children: [
                Icon(Icons.widgets, size: 20),
                SizedBox(width: 8),
                Text(
                  'Components',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildComponentCategory('Basic', [
                  ComponentType.text,
                  ComponentType.image,
                  ComponentType.divider,
                  ComponentType.spacer,
                ], ref),
                _buildComponentCategory('Data', [
                  ComponentType.table,
                  ComponentType.chart,
                  ComponentType.metric,
                ], ref),
                _buildComponentCategory('Advanced', [
                  ComponentType.gauge,
                  ComponentType.progress,
                  ComponentType.timeline,
                  ComponentType.qrCode,
                ], ref),
              ],
            ),
          ),
        ],
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

  Widget _buildNavigationDrawer(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    return Drawer(
      child: ListView(
        padding: EdgeInsetsGeometry.only(),
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              //mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.analytics, size: 48, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Report Builder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_chart),
            title: const Text('New Report'),
            onTap: () {
              Navigator.pop(context);
              // Show domain selector
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Saved Reports'),
            trailing: Chip(
              label: Text('${state.savedReports.length}'),
              backgroundColor: Colors.blue.shade100,
            ),
            onTap: () {
              Navigator.pop(context);
              _showSavedReports(context, ref);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDomainSelector(BuildContext context, WidgetRef ref) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        // padding: const EdgeInsets.all(value), // EdgeInsets.fromLTRB(),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics_outlined, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Select Report Domain',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose a domain to create a new report',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 48),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: ReportDomain.values.map((domain) {
                return DomainCard(
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
        const SizedBox(height: 16),
        _buildColumnSelection(context, ref, state),
        const SizedBox(height: 16),
        _buildFiltersSection(context, ref, state),
        const SizedBox(height: 16),
        _buildSortingSection(context, ref, state),
        const SizedBox(height: 16),
        _buildGroupingSection(context, ref, state),
        const SizedBox(height: 16),
        _buildAggregationSection(context, ref, state),
        const SizedBox(height: 16),
        _buildChartSection(context, ref, state),
      ],
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
                const Row(
                  children: [
                    Icon(Icons.filter_alt, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _showFilterDialog(context, ref, state),
                  tooltip: 'Add Filter',
                ),
              ],
            ),
            if (state.currentConfig!.filters.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No filters applied')),
              )
            else
              ...state.currentConfig!.filters.asMap().entries.map((entry) {
                final index = entry.key;
                final filter = entry.value;
                final column = state.currentConfig!.columns.firstWhere(
                  (c) => c.id == filter.columnId,
                );
                return Card(
                  margin: const EdgeInsets.only(top: 8),
                  child: ListTile(
                    leading: const Icon(Icons.filter_list, size: 18),
                    title: Text(column.displayName),
                    subtitle: Text(
                      '${getOperatorSymbol(filter.operator)} ${filter.value}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (filter.logic != null)
                          Chip(
                            label: Text(
                              filter.logic!.name.toUpperCase(),
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Colors.blue[100],
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          onPressed: () => ref
                              .read(reportBuilderProvider.notifier)
                              .removeFilter(index),
                        ),
                      ],
                    ),
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
            const Row(
              children: [
                Icon(Icons.sort, size: 20),
                SizedBox(width: 8),
                Text(
                  'Sorting',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.currentConfig!.sorts.isEmpty)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Sort By Column',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.arrow_upward),
                ),
                items: state.currentConfig!.selectedColumns
                    .where((c) => c.sortable)
                    .map((col) {
                      return DropdownMenuItem(
                        value: col.id,
                        child: Text(col.displayName),
                      );
                    })
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(reportBuilderProvider.notifier)
                        .addSort(ReportSort(columnId: value));
                  }
                },
              )
            else
              ...state.currentConfig!.sorts.map((sort) {
                final column = state.currentConfig!.selectedColumns.firstWhere(
                  (c) => c.id == sort.columnId,
                );
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      sort.ascending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 18,
                    ),
                    title: Text(column.displayName),
                    subtitle: Text(
                      sort.ascending ? 'Ascending' : 'Descending',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () => ref
                          .read(reportBuilderProvider.notifier)
                          .removeSort(sort.columnId),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupingSection(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    final groupableColumns = state.currentConfig!.selectedColumns
        .where((c) => c.groupable)
        .toList();

    if (groupableColumns.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.group_work, size: 20),
                SizedBox(width: 8),
                Text(
                  'Grouping',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.currentConfig!.groupings.isEmpty)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Group By Column',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: groupableColumns.map((col) {
                  return DropdownMenuItem(
                    value: col.id,
                    child: Text(col.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(reportBuilderProvider.notifier)
                        .addGrouping(ReportGrouping(columnId: value));
                  }
                },
              )
            else
              ...state.currentConfig!.groupings.map((grouping) {
                final column = state.currentConfig!.columns.firstWhere(
                  (c) => c.id == grouping.columnId,
                );
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.layers, size: 18),
                    title: Text(column.displayName),
                    subtitle: Text(
                      grouping.showSubtotals
                          ? 'With subtotals'
                          : 'No subtotals',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () => ref
                          .read(reportBuilderProvider.notifier)
                          .removeGrouping(grouping.columnId),
                    ),
                  ),
                );
              }),
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
            const Row(
              children: [
                Icon(Icons.functions, size: 20),
                SizedBox(width: 8),
                Text(
                  'Aggregations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...aggregatableColumns.map((col) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        col.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<AggregationType?>(
                        value: state.currentConfig!.aggregations[col.id],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
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

  Widget _buildChartSection(
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
                const Row(
                  children: [
                    Icon(Icons.bar_chart, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Chart Configuration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: state.currentConfig!.chartConfig != null,
                  onChanged: (value) {
                    if (value &&
                        state.currentConfig!.selectedColumns.length >= 2) {
                      ref
                          .read(reportBuilderProvider.notifier)
                          .setChartConfiguration(
                            ChartConfiguration(
                              type: ChartType.bar,
                              xAxisColumn:
                                  state.currentConfig!.selectedColumns[0].id,
                              yAxisColumns: [
                                state.currentConfig!.selectedColumns[1].id,
                              ],
                            ),
                          );
                    } else {
                      ref
                          .read(reportBuilderProvider.notifier)
                          .setChartConfiguration(null);
                    }
                  },
                ),
              ],
            ),
            if (state.currentConfig!.chartConfig != null) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<ChartType>(
                value: state.currentConfig!.chartConfig!.type,
                decoration: const InputDecoration(
                  labelText: 'Chart Type',
                  border: OutlineInputBorder(),
                ),
                items: ChartType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(getChartIcon(type), size: 18),
                        const SizedBox(width: 8),
                        Text(type.name.toUpperCase()),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(reportBuilderProvider.notifier)
                        .setChartConfiguration(
                          state.currentConfig!.chartConfig!.copyWith(
                            type: value,
                          ),
                        );
                  }
                },
              ),
            ],
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating report...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  ref.read(reportBuilderProvider.notifier).generateReport(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!state.showPreview || state.currentData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'Preview your report',
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure your report and click Generate',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(reportBuilderProvider.notifier).generateReport(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Generate Report'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ReportDataTable(
      config: state.currentConfig!,
      data: state.currentData!,
      expandedGroups: state.expandedGroups,
      onToggleGroup: (key) =>
          ref.read(reportBuilderProvider.notifier).toggleGroupExpansion(key),
    );
  }

  void _showColumnPicker(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    final availableColumns = state.currentConfig!.columns
        .where(
          (col) => !state.currentConfig!.selectedColumns.any(
            (sc) => sc.id == col.id,
          ),
        )
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Column'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: availableColumns.isEmpty
              ? const Center(child: Text('All columns are already selected'))
              : ListView.builder(
                  itemCount: availableColumns.length,
                  itemBuilder: (context, index) {
                    final col = availableColumns[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(getDataTypeIcon(col.dataType)),
                        title: Text(col.displayName),
                        subtitle: Row(
                          children: [
                            Text(col.dataType.name),
                            if (col.aggregatable) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.functions,
                                size: 14,
                                color: Colors.blue,
                              ),
                            ],
                            if (col.groupable) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.group_work,
                                size: 14,
                                color: Colors.green,
                              ),
                            ],
                          ],
                        ),
                        trailing: const Icon(Icons.add),
                        onTap: () {
                          ref
                              .read(reportBuilderProvider.notifier)
                              .addColumn(col);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
    FilterLogic? selectedLogic = state.currentConfig!.filters.isNotEmpty
        ? FilterLogic.and
        : null;
    String filterValue = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Filter'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.currentConfig!.filters.isNotEmpty)
                    DropdownButtonFormField<FilterLogic>(
                      decoration: const InputDecoration(
                        labelText: 'Filter Logic',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedLogic,
                      items: FilterLogic.values.map((logic) {
                        return DropdownMenuItem(
                          value: logic,
                          child: Text(logic.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedLogic = value);
                      },
                    ),
                  const SizedBox(height: 16),
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
                        child: Text(getOperatorLabel(op)),
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
                      selectedOperator != FilterOperator.isNotNull &&
                      selectedOperator != FilterOperator.isEmpty &&
                      selectedOperator != FilterOperator.isNotEmpty)
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
                              logic: selectedLogic,
                            ),
                          );
                      Navigator.pop(context);
                    },
              child: const Text('Add Filter'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSavedReports(BuildContext context, WidgetRef ref) {
    final state = ref.read(reportBuilderProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved Reports'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: state.savedReports.isEmpty
              ? const Center(child: Text('No saved reports'))
              : ListView.builder(
                  itemCount: state.savedReports.length,
                  itemBuilder: (context, index) {
                    final report = state.savedReports[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(getDomainIcon(report.domain)),
                        title: Text(report.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(report.description),
                            const SizedBox(height: 4),
                            Text(
                              'Updated: ${DateFormat('MMM dd, yyyy').format(report.updatedAt)}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.open_in_new, size: 18),
                              onPressed: () {
                                ref
                                    .read(reportBuilderProvider.notifier)
                                    .loadReport(report);
                                Navigator.pop(context);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              onPressed: () {
                                ref
                                    .read(reportBuilderProvider.notifier)
                                    .deleteReport(report.id);
                                Navigator.pop(context);
                                _showSavedReports(context, ref);
                              },
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /* 
  Widget _buildComponentLibrary(BuildContext context, WidgetRef ref) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: const Row(
              children: [
                Icon(Icons.widgets, size: 20),
                SizedBox(width: 8),
                Text(
                  'Components',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildComponentCategory('Basic', [
                  ComponentType.text,
                  ComponentType.image,
                  ComponentType.divider,
                  ComponentType.spacer,
                ], ref),
                _buildComponentCategory('Data', [
                  ComponentType.table,
                  ComponentType.chart,
                  ComponentType.metric,
                ], ref),
                _buildComponentCategory('Advanced', [
                  ComponentType.gauge,
                  ComponentType.progress,
                  ComponentType.timeline,
                  ComponentType.qrCode,
                ], ref),
              ],
            ),
          ),
        ],
      ),
    );
  } */
  /* 
  Widget _buildComponentCategory(
    String title,
    List<ComponentType> components,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...components.map((type) => _buildComponentTile(type, ref)),
        const SizedBox(height: 16),
      ],
    );
  } */
  /* 
  Widget _buildComponentTile(ComponentType type, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: Icon(_getComponentIcon(type), size: 20),
        title: Text(
          type.name[0].toUpperCase() + type.name.substring(1),
          style: const TextStyle(fontSize: 13),
        ),
        onTap: () => ref.read(reportBuilderProvider.notifier).addComponent(type),
        trailing: const Icon(Icons.add, size: 18),
      ),
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          // Zoom controls
          IconButton(
            icon: const Icon(Icons.remove),
            iconSize: 20,
            onPressed: () => ref
                .read(reportBuilderProvider.notifier)
                .setZoom(state.zoom - 0.1),
          ),
          Text('${(state.zoom * 100).toInt()}%'),
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: 20,
            onPressed: () => ref
                .read(reportBuilderProvider.notifier)
                .setZoom(state.zoom + 0.1),
          ),
          const VerticalDivider(),
          // Grid controls
          IconButton(
            icon: Icon(
              state.dragDropState.showGrid ? Icons.grid_on : Icons.grid_off,
            ),
            iconSize: 20,
            onPressed: () =>
                ref.read(reportBuilderProvider.notifier).toggleGrid(),
            tooltip: 'Toggle Grid',
          ),
          IconButton(
            icon: Icon(
              state.dragDropState.snapToGrid
                  ? Icons.align_horizontal_left
                  : Icons.align_horizontal_center,
            ),
            iconSize: 20,
            onPressed: () =>
                ref.read(reportBuilderProvider.notifier).toggleSnapToGrid(),
            tooltip: 'Snap to Grid',
          ),
          const VerticalDivider(),
          // Alignment tools
          IconButton(
            icon: const Icon(Icons.align_horizontal_left),
            iconSize: 20,
            onPressed: () {},
            tooltip: 'Align Left',
          ),
          IconButton(
            icon: const Icon(Icons.align_horizontal_center),
            iconSize: 20,
            onPressed: () {},
            tooltip: 'Align Center',
          ),
          IconButton(
            icon: const Icon(Icons.align_horizontal_right),
            iconSize: 20,
            onPressed: () {},
            tooltip: 'Align Right',
          ),
          const VerticalDivider(),
          // Layer controls
          IconButton(
            icon: const Icon(Icons.flip_to_front),
            iconSize: 20,
            onPressed: () {},
            tooltip: 'Bring to Front',
          ),
          IconButton(
            icon: const Icon(Icons.flip_to_back),
            iconSize: 20,
            onPressed: () {},
            tooltip: 'Send to Back',
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    if (state.currentPage == null) {
      return const Center(child: Text('No page available'));
    }

    return Container(
      color: Colors.grey[300],
      child: InteractiveViewer(
        minScale: 0.25,
        maxScale: 2.0,
        constrained: false,
        child: Center(
          child: Transform.scale(
            scale: state.zoom,
            child: _buildPageCanvas(context, ref, state),
          ),
        ),
      ),
    );
  }

  Widget _buildPageCanvas(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    final page = state.currentPage!;
    final layout = page.layout;

    return GestureDetector(
      onTap: () => ref.read(reportBuilderProvider.notifier).deselectAll(),
      child: Container(
        width: layout.width,
        height: layout.height,
        margin: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: layout.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Grid overlay
            if (state.dragDropState.showGrid && !state.isPreviewMode)
              _buildGridOverlay(layout, state.dragDropState.gridSize),
            
            // Page margins guide
            if (!state.isPreviewMode)
              _buildMarginsGuide(layout),
            
            // Components
            ...page.components.map((component) {
              return _buildDraggableComponent(
                context,
                ref,
                component,
                state.isPreviewMode,
                state.dragDropState.selectedComponents.contains(component),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGridOverlay(PageLayout layout, double gridSize) {
    return CustomPaint(
      size: Size(layout.width, layout.height),
      painter: GridPainter(gridSize: gridSize),
    );
  }

  Widget _buildMarginsGuide(PageLayout layout) {
    return Positioned.fill(
      child: Container(
        margin: layout.margins,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
        ),
      ),
    );
  }
 */

  Widget _buildFeatureChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Colors.blue.shade50,
    );
  }

  void _showAIAssistant(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.psychology, color: Colors.purple),
            SizedBox(width: 8),
            Text('AI Assistant'),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText:
                      'Ask me anything... e.g., "Show sales from last month"',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildAISuggestion(
                      'Create sales report',
                      'Generate a comprehensive sales report with revenue trends',
                      Icons.trending_up,
                    ),
                    _buildAISuggestion(
                      'Find anomalies',
                      'Detect unusual patterns in your data',
                      Icons.warning,
                    ),
                    _buildAISuggestion(
                      'Optimize performance',
                      'Suggestions to improve report loading speed',
                      Icons.speed,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAISuggestion(String title, String description, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          child: Icon(icon, color: Colors.purple),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward),
      ),
    );
  }

  Widget _buildDraggableComponent(
    BuildContext context,
    WidgetRef ref,
    ReportComponent component,
    bool isPreviewMode,
    bool isSelected,
  ) {
    return Positioned(
      left: component.position.dx,
      top: component.position.dy,
      child: GestureDetector(
        onTap: () {
          if (!isPreviewMode) {
            ref
                .read(reportBuilderProvider.notifier)
                .selectComponent(component.id);
          }
        },
        onPanUpdate: (details) {
          if (!isPreviewMode && !component.locked) {
            final newPosition = component.position + details.delta;
            ref
                .read(reportBuilderProvider.notifier)
                .updateComponentPosition(component.id, newPosition);
          }
        },
        child: Container(
          width: component.size.width,
          height: component.size.height,
          decoration: BoxDecoration(
            border: isSelected && !isPreviewMode
                ? Border.all(color: Colors.blue, width: 2)
                : null,
            boxShadow: isSelected && !isPreviewMode
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Component content
              _buildComponentContent(component),

              // Resize handles (4 corners + 4 sides)
              if (isSelected && !isPreviewMode) ...[
                // Corner handles
                _buildResizeHandle(
                  ref,
                  component,
                  Alignment.topLeft,
                  const Icon(Icons.circle, size: 12, color: Colors.white),
                ),
                _buildResizeHandle(
                  ref,
                  component,
                  Alignment.topRight,
                  const Icon(Icons.circle, size: 12, color: Colors.white),
                ),
                _buildResizeHandle(
                  ref,
                  component,
                  Alignment.bottomLeft,
                  const Icon(Icons.circle, size: 12, color: Colors.white),
                ),
                _buildResizeHandle(
                  ref,
                  component,
                  Alignment.bottomRight,
                  const Icon(Icons.circle, size: 12, color: Colors.white),
                ),

                // Side handles
                _buildResizeHandle(
                  ref,
                  component,
                  Alignment.topCenter,
                  Container(width: 8, height: 8, color: Colors.blue),
                ),
                _buildResizeHandle(
                  ref,
                  component,
                  Alignment.bottomCenter,
                  Container(width: 8, height: 8, color: Colors.blue),
                ),
                _buildResizeHandle(
                  ref,
                  component,
                  Alignment.centerLeft,
                  Container(width: 8, height: 8, color: Colors.blue),
                ),
                _buildResizeHandle(
                  ref,
                  component,
                  Alignment.centerRight,
                  Container(width: 8, height: 8, color: Colors.blue),
                ),
              ],

              // Delete button
              if (isSelected && !isPreviewMode)
                Positioned(
                  top: -12,
                  right: -12,
                  child: GestureDetector(
                    onTap: () => ref
                        .read(reportBuilderProvider.notifier)
                        .removeComponent(component.id),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              // Lock indicator
              if (component.locked && !isPreviewMode)
                Positioned(
                  top: -12,
                  left: -12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== RESIZE HANDLE ====================

  Widget _buildResizeHandle(
    WidgetRef ref,
    ReportComponent component,
    Alignment alignment,
    Widget icon,
  ) {
    // Calculate position based on alignment
    double? left, right, top, bottom;

    if (alignment.x < 0) left = -6;
    if (alignment.x > 0) right = -6;
    if (alignment.x == 0) left = component.size.width / 2 - 6;

    if (alignment.y < 0) top = -6;
    if (alignment.y > 0) bottom = -6;
    if (alignment.y == 0) top = component.size.height / 2 - 6;

    // Determine cursor type
    MouseCursor cursor = MouseCursor.defer;
    if (alignment == Alignment.topLeft || alignment == Alignment.bottomRight) {
      cursor = SystemMouseCursors.resizeUpLeftDownRight;
    } else if (alignment == Alignment.topRight ||
        alignment == Alignment.bottomLeft) {
      cursor = SystemMouseCursors.resizeUpRightDownLeft;
    } else if (alignment == Alignment.topCenter ||
        alignment == Alignment.bottomCenter) {
      cursor = SystemMouseCursors.resizeUpDown;
    } else if (alignment == Alignment.centerLeft ||
        alignment == Alignment.centerRight) {
      cursor = SystemMouseCursors.resizeLeftRight;
    }

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          onPanUpdate: (details) {
            double newWidth = component.size.width;
            double newHeight = component.size.height;
            Offset newPosition = component.position;

            // Resize based on alignment
            if (alignment.x < 0) {
              // Left side
              newWidth = (component.size.width - details.delta.dx).clamp(
                50,
                1000,
              );
              if (newWidth != component.size.width) {
                newPosition = Offset(
                  component.position.dx + (component.size.width - newWidth),
                  component.position.dy,
                );
              }
            } else if (alignment.x > 0) {
              // Right side
              newWidth = (component.size.width + details.delta.dx).clamp(
                50,
                1000,
              );
            }

            if (alignment.y < 0) {
              // Top side
              newHeight = (component.size.height - details.delta.dy).clamp(
                30,
                800,
              );
              if (newHeight != component.size.height) {
                newPosition = Offset(
                  newPosition.dx,
                  component.position.dy + (component.size.height - newHeight),
                );
              }
            } else if (alignment.y > 0) {
              // Bottom side
              newHeight = (component.size.height + details.delta.dy).clamp(
                30,
                800,
              );
            }

            final newSize = Size(newWidth, newHeight);

            ref
                .read(reportBuilderProvider.notifier)
                .updateComponentSize(component.id, newSize);

            if (newPosition != component.position) {
              ref
                  .read(reportBuilderProvider.notifier)
                  .updateComponentPosition(component.id, newPosition);
            }
          },
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
              ],
            ),
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }

  // ==================== COMPONENT CONTENT ====================

  Widget _buildComponentContent(ReportComponent component) {
    switch (component.type) {
      case ComponentType.text:
        return _buildTextComponent(component);

      case ComponentType.table:
        return _buildTableComponent(component);

      case ComponentType.chart:
        return _buildChartComponent(component);

      case ComponentType.image:
        return _buildImageComponent(component);

      case ComponentType.divider:
        return _buildDividerComponent(component);

      case ComponentType.spacer:
        return _buildSpacerComponent(component);

      case ComponentType.metric:
        return _buildMetricComponent(component);

      case ComponentType.gauge:
        return _buildGaugeComponent(component);

      case ComponentType.progress:
        return _buildProgressComponent(component);

      case ComponentType.timeline:
        return _buildTimelineComponent(component);

      case ComponentType.qrCode:
        return _buildQRCodeComponent(component);

      case ComponentType.barcode:
        return _buildBarcodeComponent(component);

      case ComponentType.header:
        return _buildHeaderComponent(component);

      case ComponentType.footer:
        return _buildFooterComponent(component);

      case ComponentType.container:
        return _buildContainerComponent(component);

      default:
        return _buildDefaultComponent(component);
    }
  }

  // ==================== INDIVIDUAL COMPONENT BUILDERS ====================

  Widget _buildTextComponent(ReportComponent component) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.centerLeft,
      color: Colors.white,
      child: Text(
        component.properties['text'] ?? 'Text Component',
        style: TextStyle(
          fontSize: component.properties['fontSize'] ?? 14.0,
          color: Color(component.properties['color'] ?? Colors.black.value),
          fontWeight: component.properties['fontWeight'] == 'bold'
              ? FontWeight.bold
              : FontWeight.normal,
        ),
        maxLines: component.properties['maxLines'],
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTableComponent(ReportComponent component) {
    final rows = component.properties['rows'] ?? 5;
    final columns = component.properties['columns'] ?? 3;
    final showHeader = component.properties['showHeader'] ?? true;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Table(
        border: TableBorder.all(color: Colors.grey[300]!),
        children: List.generate(
          rows,
          (rowIndex) => TableRow(
            decoration: rowIndex == 0 && showHeader
                ? BoxDecoration(color: Colors.blue[50])
                : null,
            children: List.generate(
              columns,
              (colIndex) => Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  rowIndex == 0 && showHeader
                      ? 'Column ${colIndex + 1}'
                      : 'Row $rowIndex Col $colIndex',
                  style: TextStyle(
                    fontWeight: rowIndex == 0 && showHeader
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartComponent(ReportComponent component) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        painter: SimpleChartPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildImageComponent(ReportComponent component) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 2),
        color: Colors.grey[100],
      ),
      child: component.properties['imageUrl'] != null
          ? Image.network(component.properties['imageUrl'], fit: BoxFit.cover)
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Click to add image',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDividerComponent(ReportComponent component) {
    return Container(
      color: Color(component.properties['color'] ?? Colors.grey[400]!.value),
      height: component.properties['thickness'] ?? 2.0,
    );
  }

  Widget _buildSpacerComponent(ReportComponent component) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        color: Colors.grey[50],
      ),
      child: Center(
        child: Icon(Icons.space_bar, color: Colors.grey[400], size: 32),
      ),
    );
  }

  Widget _buildMetricComponent(ReportComponent component) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            component.properties['title'] ?? 'Total Sales',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            component.properties['value'] ?? '\$45,678',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: Colors.green[200]),
              const SizedBox(width: 4),
              Text(
                component.properties['change'] ?? '+12.5%',
                style: TextStyle(
                  color: Colors.green[200],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeComponent(ReportComponent component) {
    final value = component.properties['value'] ?? 0.65;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: GaugePainter(value: value),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(value * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                component.properties['label'] ?? 'Performance',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressComponent(ReportComponent component) {
    final value = component.properties['value'] ?? 0.7;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            component.properties['label'] ?? 'Progress',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 12,
          ),
          const SizedBox(height: 8),
          Text(
            '${(value * 100).toInt()}% Complete',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineComponent(ReportComponent component) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(12),
      child: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (index < 2)
                    Container(width: 2, height: 30, color: Colors.grey[300]),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event ${index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Description for event ${index + 1}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQRCodeComponent(ReportComponent component) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'QR Code',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarcodeComponent(ReportComponent component) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Barcode',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderComponent(ReportComponent component) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.blue[50],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            component.properties['title'] ?? 'Report Header',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            component.properties['date'] ?? 'Date',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterComponent(ReportComponent component) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.grey[100],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            component.properties['leftText'] ?? '© 2024 Company Name',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          Text(
            component.properties['rightText'] ?? 'Page 1',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildContainerComponent(ReportComponent component) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(
            component.properties['borderColor'] ?? Colors.grey[300]!.value,
          ),
          width: component.properties['borderWidth'] ?? 1.0,
        ),
        color: Color(
          component.properties['backgroundColor'] ?? Colors.white.value,
        ),
        borderRadius: BorderRadius.circular(
          component.properties['borderRadius'] ?? 0.0,
        ),
      ),
      child: Center(
        child: Text(
          component.properties['text'] ?? 'Container',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildDefaultComponent(ReportComponent component) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getComponentIcon(component.type),
              size: 40,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              component.name,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationBar(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Page thumbnails with scroll
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.pages.length,
                itemBuilder: (context, index) {
                  final page = state.pages[index];
                  final isActive = index == state.currentPageIndex;

                  return GestureDetector(
                    onTap: () => ref
                        .read(reportBuilderProvider.notifier)
                        .setCurrentPage(index),
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isActive ? Colors.blue : Colors.grey[300]!,
                          width: isActive ? 2.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 24,
                            color: isActive ? Colors.blue : Colors.grey[400],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            page.name,
                            style: TextStyle(
                              fontSize: 10,
                              color: isActive ? Colors.blue : Colors.grey[700],
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (page.components.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.blue[100]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${page.components.length} items',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: isActive
                                      ? Colors.blue[700]
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Add page button
          Tooltip(
            message: 'Add New Page',
            child: Material(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () => ref.read(reportBuilderProvider.notifier).addPage(),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.add_circle_outline,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          const VerticalDivider(width: 24, thickness: 1),

          // Navigation controls
          Row(
            children: [
              // First page
              IconButton(
                icon: const Icon(Icons.first_page),
                iconSize: 20,
                onPressed: state.currentPageIndex > 0
                    ? () => ref
                          .read(reportBuilderProvider.notifier)
                          .setCurrentPage(0)
                    : null,
                tooltip: 'First Page',
              ),

              // Previous page
              IconButton(
                icon: const Icon(Icons.chevron_left),
                iconSize: 20,
                onPressed: state.currentPageIndex > 0
                    ? () => ref
                          .read(reportBuilderProvider.notifier)
                          .setCurrentPage(state.currentPageIndex - 1)
                    : null,
                tooltip: 'Previous Page',
              ),

              // Page indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  '${state.currentPageIndex + 1} / ${state.pages.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.blue[900],
                  ),
                ),
              ),

              // Next page
              IconButton(
                icon: const Icon(Icons.chevron_right),
                iconSize: 20,
                onPressed: state.currentPageIndex < state.pages.length - 1
                    ? () => ref
                          .read(reportBuilderProvider.notifier)
                          .setCurrentPage(state.currentPageIndex + 1)
                    : null,
                tooltip: 'Next Page',
              ),

              // Last page
              IconButton(
                icon: const Icon(Icons.last_page),
                iconSize: 20,
                onPressed: state.currentPageIndex < state.pages.length - 1
                    ? () => ref
                          .read(reportBuilderProvider.notifier)
                          .setCurrentPage(state.pages.length - 1)
                    : null,
                tooltip: 'Last Page',
              ),
            ],
          ),

          const VerticalDivider(width: 24, thickness: 1),

          // Delete current page
          if (state.pages.length > 1)
            Tooltip(
              message: 'Delete Current Page',
              child: Material(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Page'),
                        content: Text(
                          'Are you sure you want to delete "${state.pages[state.currentPageIndex].name}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(reportBuilderProvider.notifier)
                                  .removePage(state.currentPageIndex);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red[700],
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== PROPERTIES PANEL ====================

  Widget _buildPropertiesPanel(
    BuildContext context,
    WidgetRef ref,
    ReportBuilderState state,
  ) {
    if (state.dragDropState.selectedComponents.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedComponent = state.dragDropState.selectedComponents.first;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getComponentIcon(selectedComponent.type),
                    size: 20,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Properties',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        selectedComponent.name,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () =>
                      ref.read(reportBuilderProvider.notifier).deselectAll(),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          // Properties content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Basic section
                _buildPropertySection('Basic', Icons.info_outline, [
                  _buildPropertyTextField('Name', selectedComponent.name, (
                    value,
                  ) {
                    // Update name
                  }),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPropertySwitch(
                          'Visible',
                          selectedComponent.visible,
                          (value) {
                            // Update visibility
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPropertySwitch(
                          'Locked',
                          selectedComponent.locked,
                          (value) {
                            // Update locked
                          },
                        ),
                      ),
                    ],
                  ),
                ]),

                const SizedBox(height: 20),

                // Position & Size section
                _buildPropertySection('Position & Size', Icons.crop_square, [
                  Row(
                    children: [
                      Expanded(
                        child: _buildPropertyNumberField(
                          'X',
                          selectedComponent.position.dx.toInt().toString(),
                          (value) {
                            final x = double.tryParse(value) ?? 0;
                            ref
                                .read(reportBuilderProvider.notifier)
                                .updateComponentPosition(
                                  selectedComponent.id,
                                  Offset(x, selectedComponent.position.dy),
                                );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPropertyNumberField(
                          'Y',
                          selectedComponent.position.dy.toInt().toString(),
                          (value) {
                            final y = double.tryParse(value) ?? 0;
                            ref
                                .read(reportBuilderProvider.notifier)
                                .updateComponentPosition(
                                  selectedComponent.id,
                                  Offset(selectedComponent.position.dx, y),
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPropertyNumberField(
                          'Width',
                          selectedComponent.size.width.toInt().toString(),
                          (value) {
                            final width = double.tryParse(value) ?? 50;
                            ref
                                .read(reportBuilderProvider.notifier)
                                .updateComponentSize(
                                  selectedComponent.id,
                                  Size(width, selectedComponent.size.height),
                                );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPropertyNumberField(
                          'Height',
                          selectedComponent.size.height.toInt().toString(),
                          (value) {
                            final height = double.tryParse(value) ?? 30;
                            ref
                                .read(reportBuilderProvider.notifier)
                                .updateComponentSize(
                                  selectedComponent.id,
                                  Size(selectedComponent.size.width, height),
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                ]),

                const SizedBox(height: 20),

                // Component-specific properties
                if (selectedComponent.type == ComponentType.text)
                  _buildTextProperties(selectedComponent, ref),

                if (selectedComponent.type == ComponentType.table)
                  _buildTableProperties(selectedComponent, ref),

                if (selectedComponent.type == ComponentType.metric)
                  _buildMetricProperties(selectedComponent, ref),

                if (selectedComponent.type == ComponentType.gauge)
                  _buildGaugeProperties(selectedComponent, ref),

                const SizedBox(height: 20),

                // Appearance section
                _buildPropertySection('Appearance', Icons.palette_outlined, [
                  _buildPropertySlider('Opacity', selectedComponent.opacity, (
                    value,
                  ) {
                    // Update opacity
                  }),
                  const SizedBox(height: 12),
                  _buildPropertySlider(
                    'Rotation',
                    selectedComponent.rotation / 360,
                    (value) {
                      // Update rotation
                    },
                    suffix: '${(selectedComponent.rotation).toInt()}°',
                  ),
                ]),

                const SizedBox(height: 20),

                // Layer section
                _buildPropertySection('Layer', Icons.layers_outlined, [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Bring to front
                          },
                          icon: const Icon(Icons.flip_to_front, size: 18),
                          label: const Text('Front'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Send to back
                          },
                          icon: const Icon(Icons.flip_to_back, size: 18),
                          label: const Text('Back'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildPropertyNumberField(
                    'Z-Index',
                    selectedComponent.zIndex.toString(),
                    (value) {
                      // Update z-index
                    },
                  ),
                ]),

                const SizedBox(height: 20),

                // Actions section
                _buildPropertySection('Actions', Icons.bolt_outlined, [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Duplicate component
                      },
                      icon: const Icon(Icons.content_copy, size: 18),
                      label: const Text('Duplicate'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref
                            .read(reportBuilderProvider.notifier)
                            .removeComponent(selectedComponent.id);
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PROPERTY SECTION BUILDER ====================

  Widget _buildPropertySection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  // ==================== PROPERTY FIELD BUILDERS ====================

  Widget _buildPropertyTextField(
    String label,
    String value,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          style: const TextStyle(fontSize: 13),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPropertyNumberField(
    String label,
    String value,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixText: 'px',
          ),
          style: const TextStyle(fontSize: 13),
          keyboardType: TextInputType.number,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPropertySwitch(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildPropertySlider(
    String label,
    double value,
    Function(double) onChanged, {
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              suffix ?? '${(value * 100).toInt()}%',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Slider(value: value, onChanged: onChanged, min: 0, max: 1),
      ],
    );
  }

  // ==================== COMPONENT-SPECIFIC PROPERTIES ====================

  Widget _buildTextProperties(ReportComponent component, WidgetRef ref) {
    return _buildPropertySection('Text Properties', Icons.text_fields, [
      _buildPropertyTextField(
        'Content',
        component.properties['text'] ?? 'Text',
        (value) {
          // Update text content
        },
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Font Size',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<double>(
                  value: component.properties['fontSize'] ?? 14.0,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items:
                      [
                            8.0,
                            10.0,
                            12.0,
                            14.0,
                            16.0,
                            18.0,
                            20.0,
                            24.0,
                            28.0,
                            32.0,
                          ]
                          .map(
                            (size) => DropdownMenuItem(
                              value: size,
                              child: Text('${size.toInt()}pt'),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    // Update font size
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildTableProperties(ReportComponent component, WidgetRef ref) {
    return _buildPropertySection('Table Properties', Icons.table_chart, [
      Row(
        children: [
          Expanded(
            child: _buildPropertyNumberField(
              'Rows',
              (component.properties['rows'] ?? 5).toString(),
              (value) {
                // Update rows
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPropertyNumberField(
              'Columns',
              (component.properties['columns'] ?? 3).toString(),
              (value) {
                // Update columns
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _buildPropertySwitch(
        'Show Header',
        component.properties['showHeader'] ?? true,
        (value) {
          // Update show header
        },
      ),
    ]);
  }

  Widget _buildMetricProperties(ReportComponent component, WidgetRef ref) {
    return _buildPropertySection('Metric Properties', Icons.speed, [
      _buildPropertyTextField(
        'Title',
        component.properties['title'] ?? 'Metric',
        (value) {
          // Update title
        },
      ),
      const SizedBox(height: 12),
      _buildPropertyTextField('Value', component.properties['value'] ?? '0', (
        value,
      ) {
        // Update value
      }),
      const SizedBox(height: 12),
      _buildPropertyTextField(
        'Change',
        component.properties['change'] ?? '+0%',
        (value) {
          // Update change
        },
      ),
    ]);
  }

  Widget _buildGaugeProperties(ReportComponent component, WidgetRef ref) {
    return _buildPropertySection('Gauge Properties', Icons.donut_large, [
      _buildPropertySlider('Value', component.properties['value'] ?? 0.5, (
        value,
      ) {
        // Update gauge value
      }),
      const SizedBox(height: 12),
      _buildPropertyTextField(
        'Label',
        component.properties['label'] ?? 'Performance',
        (value) {
          // Update label
        },
      ),
    ]);
  }
}
