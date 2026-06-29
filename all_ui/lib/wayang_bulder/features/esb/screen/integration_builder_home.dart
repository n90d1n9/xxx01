import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/integration_route.dart';
import '../states/canvas_stae_provider.dart';
import '../states/current_route_notifier.dart';
import '../states/route_notifier.dart';
import '../states/selected_component_provider.dart';
import '../utils/camel_xml_dialog.dart';
import '../utils/camel_yaml_generator.dart';
import '../utils/route_validator.dart';
import '../widget/canvas/canvas_area.dart';
import '../widget/component_pallete_anel.dart';
import '../widget/empty_state_widget.dart';
import '../widget/properties_panel.dart';
import '../widget/route_list_dialog.dart';
import '../widget/route_properties_dialog.dart';
import '../widget/status_bar.dart';

class IntegrationBuilderHome extends ConsumerWidget {
  const IntegrationBuilderHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = ref.watch(currentRouteProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.integration_instructions),
            const SizedBox(width: 8),
            const Text('Enterprise Integration Builder'),
            if (currentRoute != null) ...[
              const SizedBox(width: 16),
              const Text('|'),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  currentRoute.name,
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (currentRoute != null) ...[
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () => _undo(ref),
              tooltip: 'Undo',
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: () => _redo(ref),
              tooltip: 'Redo',
            ),
            const VerticalDivider(),
          ],
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => _showRoutesList(context, ref),
            tooltip: 'All Routes',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createNewRoute(context, ref),
            tooltip: 'New Route',
          ),
          if (currentRoute != null) ...[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _saveRoute(context, ref),
              tooltip: 'Save Route',
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleMenuAction(context, ref, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'xml',
                  child: Row(
                    children: [
                      Icon(Icons.code),
                      SizedBox(width: 8),
                      Text('Generate Camel XML'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'json',
                  child: Row(
                    children: [
                      Icon(Icons.data_object),
                      SizedBox(width: 8),
                      Text('Generate JSON'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'yaml',
                  child: Row(
                    children: [
                      Icon(Icons.article),
                      SizedBox(width: 8),
                      Text('Generate YAML'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'validate',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle),
                      SizedBox(width: 8),
                      Text('Validate Route'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text('Export Route'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'import',
                  child: Row(
                    children: [
                      Icon(Icons.upload),
                      SizedBox(width: 8),
                      Text('Import Route'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy),
                      SizedBox(width: 8),
                      Text('Duplicate Route'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'properties',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Route Properties'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
            tooltip: 'Help',
          ),
        ],
      ),
      body: currentRoute == null
          ? const EmptyStateWidget()
          : Row(
              children: [
                const ComponentPalettePanel(),
                Expanded(
                  child: Column(
                    children: [
                      const CanvasToolbar(),
                      const Expanded(child: CanvasArea()),
                      const StatusBar(),
                    ],
                  ),
                ),
                const PropertiesPanel(),
              ],
            ),
      floatingActionButton: currentRoute != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  onPressed: () => _zoomIn(ref),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  onPressed: () => _zoomOut(ref),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'fit',
                  mini: true,
                  onPressed: () => _fitToScreen(ref),
                  child: const Icon(Icons.fit_screen),
                ),
              ],
            )
          : null,
    );
  }

  void _undo(WidgetRef ref) {
    // Implementation for undo functionality
    // Would require history state management
  }

  void _redo(WidgetRef ref) {
    // Implementation for redo functionality
  }

  void _zoomIn(WidgetRef ref) {
    final currentScale = ref.read(canvasStateProvider).scale;
    ref
        .read(canvasStateProvider.notifier)
        .setScale((currentScale * 1.2).clamp(0.5, 3.0));
  }

  void _zoomOut(WidgetRef ref) {
    final currentScale = ref.read(canvasStateProvider).scale;
    ref
        .read(canvasStateProvider.notifier)
        .setScale((currentScale / 1.2).clamp(0.5, 3.0));
  }

  void _fitToScreen(WidgetRef ref) {
    ref.read(canvasStateProvider.notifier).setScale(1.0);
    ref.read(canvasStateProvider.notifier).setOffset(Offset.zero);
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'xml':
        _generateCamelXML(context, ref);
        break;
      case 'json':
        _generateJSON(context, ref);
        break;
      case 'yaml':
        _generateYAML(context, ref);
        break;
      case 'validate':
        _validateRoute(context, ref);
        break;
      case 'export':
        _exportRoute(context, ref);
        break;
      case 'import':
        _importRoute(context, ref);
        break;
      case 'duplicate':
        _duplicateRoute(context, ref);
        break;
      case 'properties':
        _showRouteProperties(context, ref);
        break;
    }
  }

  void _showRoutesList(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const RoutesListDialog(),
    );
  }

  void _createNewRoute(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Integration Route'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Route Name',
                  hintText: 'e.g., Order Processing Route',
                  prefixIcon: Icon(Icons.label),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the purpose of this route',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a route name')),
                );
                return;
              }
              final route = IntegrationRoute(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                description: descController.text,
                components: [],
                connections: [],
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              ref.read(routesProvider.notifier).addRoute(route);
              ref.read(currentRouteProvider.notifier).setRoute(route);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Created route: ${route.name}')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _saveRoute(BuildContext context, WidgetRef ref) {
    final currentRoute = ref.read(currentRouteProvider);
    if (currentRoute != null) {
      ref.read(routesProvider.notifier).updateRoute(currentRoute);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Route "${currentRoute.name}" saved successfully'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => _showRoutesList(context, ref),
          ),
        ),
      );
    }
  }

  void _generateCamelXML(BuildContext context, WidgetRef ref) {
    final route = ref.read(currentRouteProvider);
    if (route == null) return;

    final xml = CamelXMLGenerator.generate(route);
    _showCodeDialog(context, 'Apache Camel XML', xml, 'xml');
  }

  void _generateJSON(BuildContext context, WidgetRef ref) {
    final route = ref.read(currentRouteProvider);
    if (route == null) return;

    final json = JsonEncoder.withIndent('  ').convert(route.toJson());
    _showCodeDialog(context, 'Route JSON', json, 'json');
  }

  void _generateYAML(BuildContext context, WidgetRef ref) {
    final route = ref.read(currentRouteProvider);
    if (route == null) return;

    final yaml = CamelYAMLGenerator.generate(route);
    _showCodeDialog(context, 'Camel YAML', yaml, 'yaml');
  }

  void _showCodeDialog(
    BuildContext context,
    String title,
    String code,
    String type,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getIconForType(type)),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: SizedBox(
          width: 700,
          height: 500,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      code,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'xml':
        return Icons.code;
      case 'json':
        return Icons.data_object;
      case 'yaml':
        return Icons.article;
      default:
        return Icons.description;
    }
  }

  void _validateRoute(BuildContext context, WidgetRef ref) {
    final route = ref.read(currentRouteProvider);
    if (route == null) return;

    final validation = RouteValidator.validate(route);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              validation.isValid ? Icons.check_circle : Icons.error,
              color: validation.isValid ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(validation.isValid ? 'Route Valid' : 'Validation Errors'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: validation.isValid
              ? const Text('Route configuration is valid!')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Found ${validation.errors.length} error(s):'),
                    const SizedBox(height: 16),
                    ...validation.errors.map(
                      (error) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(error)),
                          ],
                        ),
                      ),
                    ),
                  ],
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

  void _exportRoute(BuildContext context, WidgetRef ref) {
    final route = ref.read(currentRouteProvider);
    if (route == null) return;

    final json = JsonEncoder.withIndent('  ').convert(route.toJson());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Route'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Route exported as JSON. Copy the content below:'),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: SelectableText(json),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: json));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Route exported to clipboard')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy & Close'),
          ),
        ],
      ),
    );
  }

  void _importRoute(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Route'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Paste the route JSON:'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Paste JSON here',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              try {
                final json = jsonDecode(controller.text);
                final route = IntegrationRoute.fromJson(json);
                ref.read(routesProvider.notifier).addRoute(route);
                ref.read(currentRouteProvider.notifier).setRoute(route);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Route imported successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
              }
            },
            icon: const Icon(Icons.upload),
            label: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _duplicateRoute(BuildContext context, WidgetRef ref) {
    final route = ref.read(currentRouteProvider);
    if (route == null) return;

    final duplicate = route.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${route.name} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(routesProvider.notifier).addRoute(duplicate);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Route duplicated successfully')),
    );
  }

  void _showRouteProperties(BuildContext context, WidgetRef ref) {
    final route = ref.read(currentRouteProvider);
    if (route == null) return;

    showDialog(
      context: context,
      builder: (context) => RoutePropertiesDialog(route: route),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help),
            SizedBox(width: 8),
            Text('Help & Shortcuts'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelpSection('Canvas Controls', [
                  'Drag: Pan the canvas',
                  'Scroll: Zoom in/out',
                  'Click: Select component',
                  'Ctrl+Click: Multi-select',
                ]),
                const Divider(),
                _buildHelpSection('Component Actions', [
                  'Drag from palette: Add component',
                  'Drag component: Move position',
                  'Click connector: Create connection',
                  'Right-click: Component menu',
                ]),
                const Divider(),
                _buildHelpSection('Shortcuts', [
                  'Ctrl+S: Save route',
                  'Ctrl+D: Duplicate component',
                  'Delete: Remove selected',
                  'Ctrl+Z: Undo',
                  'Ctrl+Y: Redo',
                ]),
              ],
            ),
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

  Widget _buildHelpSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.arrow_right, size: 16),
                const SizedBox(width: 4),
                Expanded(child: Text(item)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// CANVAS TOOLBAR
// ============================================================================

class CanvasToolbar extends ConsumerWidget {
  const CanvasToolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasStateProvider);
    final selectedComponents = ref.watch(selectedComponentProvider);
    final route = ref.watch(currentRouteProvider);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Selection info
          if (selectedComponents.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${selectedComponents.length} selected',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(width: 16),

          // Alignment tools
          if (selectedComponents.length > 1) ...[
            IconButton(
              icon: const Icon(Icons.align_horizontal_left),
              tooltip: 'Align Left',
              onPressed: () => ref
                  .read(currentRouteProvider.notifier)
                  .alignComponents('left'),
            ),
            IconButton(
              icon: const Icon(Icons.align_horizontal_center),
              tooltip: 'Align Center',
              onPressed: () => ref
                  .read(currentRouteProvider.notifier)
                  .alignComponents('center'),
            ),
            IconButton(
              icon: const Icon(Icons.align_horizontal_right),
              tooltip: 'Align Right',
              onPressed: () => ref
                  .read(currentRouteProvider.notifier)
                  .alignComponents('right'),
            ),
            const VerticalDivider(),
            IconButton(
              icon: const Icon(Icons.align_vertical_top),
              tooltip: 'Align Top',
              onPressed: () => ref
                  .read(currentRouteProvider.notifier)
                  .alignComponents('top'),
            ),
            IconButton(
              icon: const Icon(Icons.align_vertical_center),
              tooltip: 'Align Middle',
              onPressed: () => ref
                  .read(currentRouteProvider.notifier)
                  .alignComponents('middle'),
            ),
            IconButton(
              icon: const Icon(Icons.align_vertical_bottom),
              tooltip: 'Align Bottom',
              onPressed: () => ref
                  .read(currentRouteProvider.notifier)
                  .alignComponents('bottom'),
            ),
            const VerticalDivider(),
          ],

          // Auto layout
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Auto Layout',
            onPressed: () =>
                ref.read(currentRouteProvider.notifier).autoLayout(),
          ),

          const Spacer(),

          // Canvas controls
          IconButton(
            icon: Icon(
              canvasState.gridVisible ? Icons.grid_on : Icons.grid_off,
            ),
            tooltip: 'Toggle Grid',
            onPressed: () => ref
                .read(canvasStateProvider.notifier)
                .setGridVisible(!canvasState.gridVisible),
          ),
          IconButton(
            icon: Icon(
              canvasState.snapToGrid ? Icons.square : Icons.crop_square,
            ),
            tooltip: 'Snap to Grid',
            onPressed: () => ref
                .read(canvasStateProvider.notifier)
                .setSnapToGrid(!canvasState.snapToGrid),
          ),
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Toggle Minimap',
            onPressed: () =>
                ref.read(canvasStateProvider.notifier).toggleMinimap(),
          ),

          const VerticalDivider(),

          // Zoom controls
          Text('${(canvasState.scale * 100).toInt()}%'),
          const SizedBox(width: 8),

          // Component count
          if (route != null) ...[
            const VerticalDivider(),
            const Icon(Icons.widgets, size: 16),
            const SizedBox(width: 4),
            Text('${route.components.length}'),
            const SizedBox(width: 16),
            const Icon(Icons.arrow_forward, size: 16),
            const SizedBox(width: 4),
            Text('${route.connections.length}'),
          ],
        ],
      ),
    );
  }
}
