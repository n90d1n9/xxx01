import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/node.dart';
import '../../services/alignment_handler.dart';
import '../../services/alignment_tools.dart';
import '../../services/documentation_generator.dart';
import '../../services/export_service.dart';
import '../../services/layout_handler.dart';
import '../../services/simulation_dialog.dart';
import '../../services/undo_redo_handler.dart';
import '../../services/zoom_handler.dart';
import '../../states/canvas_transform_provider.dart';
import '../../states/node_route_provider.dart';
import '../../states/select_route_provider.dart';
import '../../states/snapshot_provider.dart';
import '../../states/validation_error_provider.dart';
import '../../utils/convert_to_yaml.dart';
import 'export_menu.dart';
import 'grid_snap_toggle.dart';
import 'plugins_dialog.dart';
import 'stats_dialog.dart';
import 'template_dialog.dart';
import 'tools_menu.dart';
import 'undo_redo_buttons.dart.dart';
import 'zoom_control.dart';

import 'ai_suggestion_dialog.dart';
import 'data_mapper_panel.dart';
import 'expression_builder_dialog.dart';
import 'new_route_dialog.dart';
import 'performance_dialog.dart';
import 'settings_panel.dart';
import 'snapshot_dialog.dart';
import 'testing_framework_dialog.dart';
import 'validation_dialog.dart';
import 'yaml_dialog.dart';

class WayangAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const WayangAppBar({super.key});

  @override
  ConsumerState<WayangAppBar> createState() => _WayangAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _WayangAppBarState extends ConsumerState<WayangAppBar> {
  @override
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Apache Camel Visual Designer'),
      actions: [
        // Essential actions - always visible
        UndoRedoButtons(onUndo: _handleUndo, onRedo: _handleRedo),
        const VerticalDivider(),

        // Primary tools - always visible
        ToolsMenu(
          onExpressionBuilder: () => _showExpressionBuilder(context),
          onDataMapper: () => _showDataMapper(context),
          onCreateSnapshot: _createSnapshot,
          onViewSnapshots: () => _showSnapshotsDialog(context),
          onTestingFramework: () => _showTestingFramework(context),
          onGenerateDocs: _generateDocumentation,
          onCompareRoutes: () => _showCompareDialog(context),
          onShowStats: () => _showStatsDialog(context),
          onShowPlugins: () => _showPluginsDialog(context),
        ),
        ExportMenu(onExport: _handleAdvancedExport),
        const VerticalDivider(),

        // Zoom controls - compact version
        ZoomControls(
          onZoomIn: () => _zoom(0.1),
          onZoomOut: () => _zoom(-0.1),
          onFitToScreen: _fitToScreen,
          onResetView: () => ref.read(canvasTransformProvider.notifier).reset(),
        ),
        const VerticalDivider(),

        // Layout tools
        IconButton(
          icon: const Icon(Icons.auto_fix_high),
          onPressed: _autoLayout,
          tooltip: 'Auto Layout',
        ),
        const GridSnapToggle(),
        const VerticalDivider(),

        // Overflow menu for secondary actions
        _buildOverflowMenu(),
      ],
    );
  }

  // Delegated methods
  void _handleUndo() => UndoRedoHandler.handleUndo(ref);
  void _handleRedo() => UndoRedoHandler.handleRedo(ref);
  void _fitToScreen() => ZoomHandler.fitToScreen(ref, context);
  void _autoLayout() => LayoutHandler.autoLayout(ref, context);
  void _zoom(double delta) => ZoomHandler.zoom(ref, delta);
  void _handleAlignment(AlignmentType type, BuildContext context) =>
      AlignmentHandler.handleAlignment(type, ref, context);

  // Dialog methods (now much simpler)
  void _showTemplatesDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const TemplatesDialog());
  }

  void _showSimulationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SimulationDialog(),
    );
  }

  PopupMenuButton<String> _buildOverflowMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'More Actions',
      onSelected: (value) => _handleOverflowAction(value, context),
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'templates',
              child: Row(
                children: [
                  Icon(Icons.library_books, size: 20),
                  SizedBox(width: 8),
                  Text('Templates Library'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'simulation',
              child: Row(
                children: [
                  Icon(Icons.play_circle, size: 20),
                  SizedBox(width: 8),
                  Text('Test Simulation'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'performance',
              child: Row(
                children: [
                  Icon(Icons.analytics, size: 20),
                  SizedBox(width: 8),
                  Text('Performance Metrics'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'ai_suggestions',
              child: Row(
                children: [
                  Icon(Icons.lightbulb, size: 20),
                  SizedBox(width: 8),
                  Text('AI Suggestions'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'alignment',
              child: Row(
                children: [
                  Icon(Icons.align_horizontal_left, size: 20),
                  SizedBox(width: 8),
                  Text('Alignment Tools'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'import_export',
              child: Row(
                children: [
                  Icon(Icons.import_export, size: 20),
                  SizedBox(width: 8),
                  Text('Import/Export'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'validation',
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 20),
                  SizedBox(width: 8),
                  Text('Validate Route'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'new_route',
              child: Row(
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text('New Route'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
          ],
    );
  }

  void _handleOverflowAction(String value, BuildContext context) {
    switch (value) {
      case 'templates':
        _showTemplatesDialog(context);
        break;
      case 'simulation':
        _showSimulationDialog(context);
        break;
      case 'performance':
        _showPerformanceDialog(context);
        break;
      case 'ai_suggestions':
        _showAISuggestionsDialog(context);
        break;
      case 'alignment':
        _showAlignmentTools(context);
        break;
      case 'import_export':
        _showImportExportMenu(context);
        break;
      case 'validation':
        _showValidation();
        break;
      case 'new_route':
        _showNewRouteDialog(context);
        break;
      case 'settings':
        _showSettings();
        break;
    }
  }

  void _showAlignmentTools(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => SimpleDialog(
            title: const Text('Alignment Tools'),
            children: [
              _buildAlignmentButton(AlignmentType.left, 'Align Left', context),
              _buildAlignmentButton(
                AlignmentType.right,
                'Align Right',
                context,
              ),
              _buildAlignmentButton(AlignmentType.top, 'Align Top', context),
              _buildAlignmentButton(
                AlignmentType.bottom,
                'Align Bottom',
                context,
              ),
              _buildAlignmentButton(
                AlignmentType.centerH,
                'Center Horizontally',
                context,
              ),
              _buildAlignmentButton(
                AlignmentType.centerV,
                'Center Vertically',
                context,
              ),
            ],
          ),
    );
  }

  SimpleDialogOption _buildAlignmentButton(
    AlignmentType type,
    String text,
    BuildContext context,
  ) {
    return SimpleDialogOption(
      onPressed: () {
        _handleAlignment(type, context);
        Navigator.pop(context);
      },
      child: Text(text),
    );
  }

  void _showImportExportMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.upload),
                  title: const Text('Import Route'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleImport();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Export as YAML'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleExport('yaml');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Export as JSON'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleExport('json');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.visibility),
                  title: const Text('View YAML'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleExport('view');
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showPerformanceDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => PerformanceDialog());
  }

  void _handleExport(String format) {
    final route = ref.read(selectedRouteProvider);
    if (route == null) return;

    if (format == 'view') {
      _showYamlDialog(context);
      return;
    }

    String output;
    if (format == 'yaml') {
      output = CodeConverter.toYaml(route);
    } else {
      output = jsonEncode(route.toJson());
    }

    // In a real app, you would save to file here
    print('Exported as $format:\n$output');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported as ${format.toUpperCase()}')),
    );
  }

  void _handleImport() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Import Route'),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Paste JSON or YAML route definition:'),
                  const SizedBox(height: 16),
                  TextField(
                    maxLines: 10,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '{"id": "...", "name": "...", ...}',
                    ),
                    onSubmitted: (value) {
                      _importRoute(value);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _importRoute(String data) {
    try {
      final json = jsonDecode(data);
      final route = WNode.fromJson(json);
      ref.read(routesProvider.notifier).addRoute(route);
      ref.read(selectedRouteIdProvider.notifier).state = route.id;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Route imported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  void _showYamlDialog(BuildContext context) {
    final route = ref.read(selectedRouteProvider);
    if (route == null) return;

    final yaml = CodeConverter.toYaml(route);

    showDialog(context: context, builder: (context) => YamlDialog(yaml: yaml));
  }

  void _showDataMapper(BuildContext context) {
    showDialog(context: context, builder: (context) => DataMapperPanel());
  }

  void _showAISuggestionsDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => AISuggestionDialog());
  }

  void _showNewRouteDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => NewRouteDialog(
            nameController: nameController,
            descController: descController,
          ),
    );
  }

  void _showValidation() {
    final errors = ref.read(validationErrorsProvider);

    showDialog(
      context: context,
      builder: (context) => ValidationDialog(errors: errors),
    );
  }

  void _showSettings() {
    showDialog(context: context, builder: (context) => SettingsPanel());
  }

  void _handleAdvancedExport(ExportFormat format) {
    final route = ref.read(selectedRouteProvider);
    if (route == null) return;

    final output = ExportService.export(route, format);

    // Show export dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Export as ${format.name.toUpperCase()}'),
            content: SizedBox(
              width: 600,
              height: 400,
              child: SingleChildScrollView(
                child: SelectableText(
                  output,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: output));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard!')),
                  );
                },
                child: const Text('Copy'),
              ),
            ],
          ),
    );
  }

  void _showExpressionBuilder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExpressionBuilderDialog(),
    );
  }

  void _createSnapshot() {
    final route = ref.read(selectedRouteProvider);
    if (route == null) return;

    showDialog(
      context: context,
      builder: (context) {
        final commentController = TextEditingController();
        return AlertDialog(
          title: const Text('Create Snapshot'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Save the current route state as a snapshot'),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(snapshotsProvider.notifier)
                    .createSnapshot(
                      route,
                      commentController.text.isNotEmpty
                          ? commentController.text
                          : null,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Snapshot created')),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showSnapshotsDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => SnapshotDialog());
  }

  void _showTestingFramework(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TestingFrameworkDialog(),
    );
  }

  void _generateDocumentation() {
    final route = ref.read(selectedRouteProvider);
    if (route == null) return;

    final markdown = DocumentationGenerator.generateMarkdown(route);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Generated Documentation'),
            content: SizedBox(
              width: 700,
              height: 500,
              child: SingleChildScrollView(child: SelectableText(markdown)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: markdown));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Documentation copied!')),
                  );
                },
                child: const Text('Copy'),
              ),
            ],
          ),
    );
  }

  void _showCompareDialog(BuildContext context) {
    final routes = ref.read(routesProvider);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Compare Routes'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select two routes to compare:'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Route 1',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        routes
                            .map(
                              (r) => DropdownMenuItem(
                                value: r.id,
                                child: Text(r.name),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Route 2',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        routes
                            .map(
                              (r) => DropdownMenuItem(
                                value: r.id,
                                child: Text(r.name),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {},
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
                onPressed: () {
                  Navigator.pop(context);
                  // Show comparison results
                },
                child: const Text('Compare'),
              ),
            ],
          ),
    );
  }

  void _showStatsDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => StatsDialog());
  }

  void _showPluginsDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => PluginsDialog());
  }
}
