import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_riverpod/legacy.dart';

// ============================================================================
// MODELS
// ============================================================================

enum ComponentType {
  from,
  to,
  transform,
  filter,
  choice,
  log,
  setHeader,
  setBody,
  process,
  split,
  aggregate,
  enrich,
  multicast,
  wiretap,
  loop,
  delay,
  throttle,
  removeHeader,
  removeHeaders,
  convertBodyTo,
  marshal,
  unmarshal,
  script,
  validate,
  onException,
  doTry,
  doCatch,
  doFinally,
  pollEnrich,
  recipientList,
  dynamicRouter,
  loadBalance,
  hystrix,
  idempotentConsumer,
}

class IntegrationComponent {
  final String id;
  final ComponentType type;
  final String label;
  final Map<String, dynamic> properties;
  final Offset position;
  final String? description;
  final bool enabled;

  IntegrationComponent({
    required this.id,
    required this.type,
    required this.label,
    required this.properties,
    required this.position,
    this.description,
    this.enabled = true,
  });

  IntegrationComponent copyWith({
    String? id,
    ComponentType? type,
    String? label,
    Map<String, dynamic>? properties,
    Offset? position,
    String? description,
    bool? enabled,
  }) {
    return IntegrationComponent(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      properties: properties ?? this.properties,
      position: position ?? this.position,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'label': label,
      'properties': properties,
      'position': {'dx': position.dx, 'dy': position.dy},
      'description': description,
      'enabled': enabled,
    };
  }

  factory IntegrationComponent.fromJson(Map<String, dynamic> json) {
    return IntegrationComponent(
      id: json['id'],
      type: ComponentType.values.firstWhere((e) => e.name == json['type']),
      label: json['label'],
      properties: Map<String, dynamic>.from(json['properties']),
      position: Offset(json['position']['dx'], json['position']['dy']),
      description: json['description'],
      enabled: json['enabled'] ?? true,
    );
  }
}

class Connection {
  final String id;
  final String fromId;
  final String toId;
  final String? label;
  final String? condition;

  Connection({
    required this.id,
    required this.fromId,
    required this.toId,
    this.label,
    this.condition,
  });

  Connection copyWith({
    String? id,
    String? fromId,
    String? toId,
    String? label,
    String? condition,
  }) {
    return Connection(
      id: id ?? this.id,
      fromId: fromId ?? this.fromId,
      toId: toId ?? this.toId,
      label: label ?? this.label,
      condition: condition ?? this.condition,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromId': fromId,
      'toId': toId,
      'label': label,
      'condition': condition,
    };
  }

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'],
      fromId: json['fromId'],
      toId: json['toId'],
      label: json['label'],
      condition: json['condition'],
    );
  }
}

class IntegrationRoute {
  final String id;
  final String name;
  final String description;
  final List<IntegrationComponent> components;
  final List<Connection> connections;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  IntegrationRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.components,
    required this.connections,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  IntegrationRoute copyWith({
    String? id,
    String? name,
    String? description,
    List<IntegrationComponent>? components,
    List<Connection>? connections,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return IntegrationRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      components: components ?? this.components,
      connections: connections ?? this.connections,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'components': components.map((c) => c.toJson()).toList(),
      'connections': connections.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory IntegrationRoute.fromJson(Map<String, dynamic> json) {
    return IntegrationRoute(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      components: (json['components'] as List)
          .map((c) => IntegrationComponent.fromJson(c))
          .toList(),
      connections: (json['connections'] as List)
          .map((c) => Connection.fromJson(c))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      metadata: json['metadata'],
    );
  }
}

// ============================================================================
// STATE PROVIDERS
// ============================================================================

class RoutesNotifier extends StateNotifier<List<IntegrationRoute>> {
  RoutesNotifier() : super([]);

  void addRoute(IntegrationRoute route) {
    state = [...state, route];
  }

  void updateRoute(IntegrationRoute route) {
    state = [
      for (final r in state)
        if (r.id == route.id) route else r,
    ];
  }

  void deleteRoute(String id) {
    state = state.where((r) => r.id != id).toList();
  }

  void importRoutes(List<IntegrationRoute> routes) {
    state = [...state, ...routes];
  }

  String exportToJson() {
    final data = state.map((r) => r.toJson()).toList();
    return JsonEncoder.withIndent('  ').convert(data);
  }
}

class CurrentRouteNotifier extends StateNotifier<IntegrationRoute?> {
  CurrentRouteNotifier() : super(null);

  void setRoute(IntegrationRoute? route) {
    state = route;
  }

  void updateMetadata(String key, dynamic value) {
    if (state == null) return;
    final newMetadata = Map<String, dynamic>.from(state!.metadata ?? {});
    newMetadata[key] = value;
    state = state!.copyWith(metadata: newMetadata);
  }

  void addComponent(IntegrationComponent component) {
    if (state == null) return;
    state = state!.copyWith(components: [...state!.components, component]);
  }

  void updateComponent(IntegrationComponent component) {
    if (state == null) return;
    state = state!.copyWith(
      components: [
        for (final c in state!.components)
          if (c.id == component.id) component else c,
      ],
    );
  }

  void deleteComponent(String id) {
    if (state == null) return;
    state = state!.copyWith(
      components: state!.components.where((c) => c.id != id).toList(),
      connections: state!.connections
          .where((conn) => conn.fromId != id && conn.toId != id)
          .toList(),
    );
  }

  void duplicateComponent(String id) {
    if (state == null) return;
    final component = state!.components.firstWhere((c) => c.id == id);
    final newComponent = component.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      position: component.position + const Offset(50, 50),
      label: '${component.label} (Copy)',
    );
    addComponent(newComponent);
  }

  void addConnection(Connection connection) {
    if (state == null) return;
    state = state!.copyWith(connections: [...state!.connections, connection]);
  }

  void updateConnection(Connection connection) {
    if (state == null) return;
    state = state!.copyWith(
      connections: [
        for (final c in state!.connections)
          if (c.id == connection.id) connection else c,
      ],
    );
  }

  void deleteConnection(String id) {
    if (state == null) return;
    state = state!.copyWith(
      connections: state!.connections.where((c) => c.id != id).toList(),
    );
  }

  void alignComponents(String alignment) {
    if (state == null || state!.components.isEmpty) return;

    final components = List<IntegrationComponent>.from(state!.components);

    switch (alignment) {
      case 'left':
        final minX = components.map((c) => c.position.dx).reduce(math.min);
        for (var i = 0; i < components.length; i++) {
          components[i] = components[i].copyWith(
            position: Offset(minX, components[i].position.dy),
          );
        }
        break;
      case 'center':
        final avgX =
            components.map((c) => c.position.dx).reduce((a, b) => a + b) /
            components.length;
        for (var i = 0; i < components.length; i++) {
          components[i] = components[i].copyWith(
            position: Offset(avgX, components[i].position.dy),
          );
        }
        break;
      case 'right':
        final maxX = components.map((c) => c.position.dx).reduce(math.max);
        for (var i = 0; i < components.length; i++) {
          components[i] = components[i].copyWith(
            position: Offset(maxX, components[i].position.dy),
          );
        }
        break;
      case 'top':
        final minY = components.map((c) => c.position.dy).reduce(math.min);
        for (var i = 0; i < components.length; i++) {
          components[i] = components[i].copyWith(
            position: Offset(components[i].position.dx, minY),
          );
        }
        break;
      case 'middle':
        final avgY =
            components.map((c) => c.position.dy).reduce((a, b) => a + b) /
            components.length;
        for (var i = 0; i < components.length; i++) {
          components[i] = components[i].copyWith(
            position: Offset(components[i].position.dx, avgY),
          );
        }
        break;
      case 'bottom':
        final maxY = components.map((c) => c.position.dy).reduce(math.max);
        for (var i = 0; i < components.length; i++) {
          components[i] = components[i].copyWith(
            position: Offset(components[i].position.dx, maxY),
          );
        }
        break;
    }

    state = state!.copyWith(components: components);
  }

  void autoLayout() {
    if (state == null || state!.components.isEmpty) return;

    final components = List<IntegrationComponent>.from(state!.components);
    final connections = state!.connections;

    // Find starting nodes (nodes with no incoming connections)
    final startingNodes = components.where((c) {
      return !connections.any((conn) => conn.toId == c.id);
    }).toList();

    // Simple hierarchical layout
    final positioned = <String>{};
    var currentY = 100.0;
    var currentLevel = startingNodes;

    while (currentLevel.isNotEmpty) {
      var currentX = 100.0;
      final nextLevel = <IntegrationComponent>[];

      for (final component in currentLevel) {
        if (!positioned.contains(component.id)) {
          final index = components.indexWhere((c) => c.id == component.id);
          components[index] = component.copyWith(
            position: Offset(currentX, currentY),
          );
          positioned.add(component.id);
          currentX += 250;

          // Find next level components
          final outgoing = connections.where((c) => c.fromId == component.id);
          for (final conn in outgoing) {
            final nextComp = components.firstWhere((c) => c.id == conn.toId);
            if (!positioned.contains(nextComp.id)) {
              nextLevel.add(nextComp);
            }
          }
        }
      }

      currentLevel = nextLevel;
      currentY += 150;
    }

    state = state!.copyWith(components: components);
  }
}

class SelectedComponentNotifier extends StateNotifier<Set<String>> {
  SelectedComponentNotifier() : super({});

  void select(String id, {bool multi = false}) {
    if (multi) {
      state = {...state, id};
    } else {
      state = {id};
    }
  }

  void deselect(String id) {
    state = {...state}..remove(id);
  }

  void clear() {
    state = {};
  }

  void toggle(String id) {
    if (state.contains(id)) {
      deselect(id);
    } else {
      state = {...state, id};
    }
  }
}

class CanvasStateNotifier extends StateNotifier<CanvasState> {
  CanvasStateNotifier() : super(CanvasState());

  void setScale(double scale) {
    state = state.copyWith(scale: scale);
  }

  void setOffset(Offset offset) {
    state = state.copyWith(offset: offset);
  }

  void setGridVisible(bool visible) {
    state = state.copyWith(gridVisible: visible);
  }

  void setSnapToGrid(bool snap) {
    state = state.copyWith(snapToGrid: snap);
  }

  void toggleMinimap() {
    state = state.copyWith(minimapVisible: !state.minimapVisible);
  }
}

class CanvasState {
  final double scale;
  final Offset offset;
  final bool gridVisible;
  final bool snapToGrid;
  final bool minimapVisible;
  final double gridSize;

  CanvasState({
    this.scale = 1.0,
    this.offset = Offset.zero,
    this.gridVisible = true,
    this.snapToGrid = false,
    this.minimapVisible = true,
    this.gridSize = 20.0,
  });

  CanvasState copyWith({
    double? scale,
    Offset? offset,
    bool? gridVisible,
    bool? snapToGrid,
    bool? minimapVisible,
    double? gridSize,
  }) {
    return CanvasState(
      scale: scale ?? this.scale,
      offset: offset ?? this.offset,
      gridVisible: gridVisible ?? this.gridVisible,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      minimapVisible: minimapVisible ?? this.minimapVisible,
      gridSize: gridSize ?? this.gridSize,
    );
  }
}

final routesProvider =
    StateNotifierProvider<RoutesNotifier, List<IntegrationRoute>>((ref) {
      return RoutesNotifier();
    });

final currentRouteProvider =
    StateNotifierProvider<CurrentRouteNotifier, IntegrationRoute?>((ref) {
      return CurrentRouteNotifier();
    });

final selectedComponentProvider =
    StateNotifierProvider<SelectedComponentNotifier, Set<String>>((ref) {
      return SelectedComponentNotifier();
    });

final canvasStateProvider =
    StateNotifierProvider<CanvasStateNotifier, CanvasState>((ref) {
      return CanvasStateNotifier();
    });

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredComponentsProvider = Provider<List<ComponentType>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) {
    return ComponentType.values;
  }
  return ComponentType.values
      .where((type) => type.name.toLowerCase().contains(query))
      .toList();
});

// ============================================================================
// MAIN APP
// ============================================================================

void main() {
  runApp(const ProviderScope(child: IntegrationBuilderApp()));
}

class IntegrationBuilderApp extends StatelessWidget {
  const IntegrationBuilderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enterprise Integration Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[100],
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: const IntegrationBuilderHome(),
    );
  }
}

// ============================================================================
// HOME SCREEN
// ============================================================================

class IntegrationBuilderHome extends ConsumerWidget {
  const IntegrationBuilderHome({Key? key}) : super(key: key);

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

// ============================================================================
// STATUS BAR
// ============================================================================

class StatusBar extends ConsumerWidget {
  const StatusBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(currentRouteProvider);

    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16),
          const SizedBox(width: 8),
          if (route != null)
            Text(
              'Last updated: ${_formatDateTime(route.updatedAt)}',
              style: const TextStyle(fontSize: 12),
            )
          else
            const Text('No route selected', style: TextStyle(fontSize: 12)),
          const Spacer(),
          const Text(
            'Apache Camel Integration Builder v1.0',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day}/${dt.month}/${dt.year}';
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class EmptyStateWidget extends ConsumerWidget {
  const EmptyStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree, size: 120, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'Welcome to Integration Builder',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new route or open an existing one to get started',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  final nameController = TextEditingController();
                  final descController = TextEditingController();

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Create New Route'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Route Name',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: descController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
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
                            final route = IntegrationRoute(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              name: nameController.text,
                              description: descController.text,
                              components: [],
                              connections: [],
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            );
                            ref.read(routesProvider.notifier).addRoute(route);
                            ref
                                .read(currentRouteProvider.notifier)
                                .setRoute(route);
                            Navigator.pop(context);
                          },
                          child: const Text('Create'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New Route'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const RoutesListDialog(),
                  );
                },
                icon: const Icon(Icons.folder_open),
                label: const Text('Open Existing Route'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// COMPONENT PALETTE
// ============================================================================

class ComponentPalettePanel extends ConsumerWidget {
  const ComponentPalettePanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredComponents = ref.watch(filteredComponentsProvider);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.widgets),
                    const SizedBox(width: 8),
                    Text(
                      'Components',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search components...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildCategory(context, 'Endpoints', filteredComponents, [
                  ComponentType.from,
                  ComponentType.to,
                ]),
                _buildCategory(context, 'Transformation', filteredComponents, [
                  ComponentType.transform,
                  ComponentType.setBody,
                  ComponentType.setHeader,
                  ComponentType.removeHeader,
                  ComponentType.removeHeaders,
                  ComponentType.convertBodyTo,
                ]),
                _buildCategory(context, 'Routing', filteredComponents, [
                  ComponentType.choice,
                  ComponentType.filter,
                  ComponentType.multicast,
                  ComponentType.split,
                  ComponentType.recipientList,
                  ComponentType.dynamicRouter,
                  ComponentType.loadBalance,
                ]),
                _buildCategory(context, 'Processing', filteredComponents, [
                  ComponentType.process,
                  ComponentType.log,
                  ComponentType.aggregate,
                  ComponentType.enrich,
                  ComponentType.pollEnrich,
                  ComponentType.wiretap,
                  ComponentType.script,
                ]),
                _buildCategory(context, 'Control Flow', filteredComponents, [
                  ComponentType.loop,
                  ComponentType.delay,
                  ComponentType.throttle,
                ]),
                _buildCategory(context, 'Data Format', filteredComponents, [
                  ComponentType.marshal,
                  ComponentType.unmarshal,
                ]),
                _buildCategory(context, 'Error Handling', filteredComponents, [
                  ComponentType.onException,
                  ComponentType.doTry,
                  ComponentType.doCatch,
                  ComponentType.doFinally,
                ]),
                _buildCategory(context, 'Advanced', filteredComponents, [
                  ComponentType.validate,
                  ComponentType.hystrix,
                  ComponentType.idempotentConsumer,
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(
    BuildContext context,
    String title,
    List<ComponentType> filtered,
    List<ComponentType> types,
  ) {
    final visibleTypes = types.where((t) => filtered.contains(t)).toList();
    if (visibleTypes.isEmpty) return const SizedBox();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: true,
        children: visibleTypes
            .map((type) => ComponentPaletteItem(type: type))
            .toList(),
      ),
    );
  }
}

class ComponentPaletteItem extends StatelessWidget {
  final ComponentType type;

  const ComponentPaletteItem({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<ComponentType>(
      data: type,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: ComponentChip(type: type),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: ListTile(
          dense: true,
          leading: Icon(_getIcon(type), size: 20),
          title: Text(_getLabel(type)),
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(_getIcon(type), size: 20, color: _getColor(type)),
        title: Text(_getLabel(type)),
        subtitle: Text(
          _getDescription(type),
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        onTap: () {},
      ),
    );
  }

  IconData _getIcon(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return Icons.input;
      case ComponentType.to:
        return Icons.output;
      case ComponentType.transform:
        return Icons.transform;
      case ComponentType.filter:
        return Icons.filter_alt;
      case ComponentType.choice:
        return Icons.call_split;
      case ComponentType.log:
        return Icons.article;
      case ComponentType.setHeader:
        return Icons.view_headline;
      case ComponentType.setBody:
        return Icons.data_object;
      case ComponentType.process:
        return Icons.settings;
      case ComponentType.split:
        return Icons.call_split;
      case ComponentType.aggregate:
        return Icons.merge;
      case ComponentType.enrich:
        return Icons.add_circle;
      case ComponentType.multicast:
        return Icons.broadcast_on_personal;
      case ComponentType.wiretap:
        return Icons.visibility;
      case ComponentType.loop:
        return Icons.loop;
      case ComponentType.delay:
        return Icons.schedule;
      case ComponentType.throttle:
        return Icons.speed;
      case ComponentType.removeHeader:
        return Icons.remove_circle;
      case ComponentType.removeHeaders:
        return Icons.clear_all;
      case ComponentType.convertBodyTo:
        return Icons.swap_horiz;
      case ComponentType.marshal:
        return Icons.archive;
      case ComponentType.unmarshal:
        return Icons.unarchive;
      case ComponentType.script:
        return Icons.code;
      case ComponentType.validate:
        return Icons.verified;
      case ComponentType.onException:
        return Icons.error;
      case ComponentType.doTry:
        return Icons.try_sms_star;
      case ComponentType.doCatch:
        return Icons.catching_pokemon;
      case ComponentType.doFinally:
        return Icons.done_all;
      case ComponentType.pollEnrich:
        return Icons.cloud_download;
      case ComponentType.recipientList:
        return Icons.list;
      case ComponentType.dynamicRouter:
        return Icons.alt_route;
      case ComponentType.loadBalance:
        return Icons.balance;
      case ComponentType.hystrix:
        return Icons.shield;
      case ComponentType.idempotentConsumer:
        return Icons.filter_1;
    }
  }

  String _getLabel(ComponentType type) {
    return type.name[0].toUpperCase() +
        type.name
            .substring(1)
            .replaceAllMapped(
              RegExp(r'([A-Z])'),
              (match) => ' ${match.group(1)}',
            );
  }

  String _getDescription(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return 'Consume from endpoint';
      case ComponentType.to:
        return 'Send to endpoint';
      case ComponentType.transform:
        return 'Transform message';
      case ComponentType.filter:
        return 'Filter messages';
      case ComponentType.choice:
        return 'Conditional routing';
      case ComponentType.log:
        return 'Log message';
      case ComponentType.setHeader:
        return 'Set message header';
      case ComponentType.setBody:
        return 'Set message body';
      case ComponentType.process:
        return 'Custom processor';
      case ComponentType.split:
        return 'Split message';
      case ComponentType.aggregate:
        return 'Aggregate messages';
      case ComponentType.enrich:
        return 'Enrich content';
      case ComponentType.multicast:
        return 'Send to multiple endpoints';
      case ComponentType.wiretap:
        return 'Copy to endpoint';
      case ComponentType.loop:
        return 'Loop messages';
      case ComponentType.delay:
        return 'Delay processing';
      case ComponentType.throttle:
        return 'Throttle messages';
      case ComponentType.removeHeader:
        return 'Remove header';
      case ComponentType.removeHeaders:
        return 'Remove multiple headers';
      case ComponentType.convertBodyTo:
        return 'Convert body type';
      case ComponentType.marshal:
        return 'Marshal to format';
      case ComponentType.unmarshal:
        return 'Unmarshal from format';
      case ComponentType.script:
        return 'Execute script';
      case ComponentType.validate:
        return 'Validate message';
      case ComponentType.onException:
        return 'Exception handler';
      case ComponentType.doTry:
        return 'Try block';
      case ComponentType.doCatch:
        return 'Catch block';
      case ComponentType.doFinally:
        return 'Finally block';
      case ComponentType.pollEnrich:
        return 'Poll and enrich';
      case ComponentType.recipientList:
        return 'Dynamic recipients';
      case ComponentType.dynamicRouter:
        return 'Dynamic routing';
      case ComponentType.loadBalance:
        return 'Load balancing';
      case ComponentType.hystrix:
        return 'Circuit breaker';
      case ComponentType.idempotentConsumer:
        return 'Deduplicate messages';
    }
  }

  Color _getColor(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return Colors.green;
      case ComponentType.to:
        return Colors.red;
      case ComponentType.transform:
      case ComponentType.setBody:
      case ComponentType.setHeader:
      case ComponentType.removeHeader:
      case ComponentType.removeHeaders:
      case ComponentType.convertBodyTo:
        return Colors.purple;
      case ComponentType.choice:
      case ComponentType.filter:
      case ComponentType.multicast:
      case ComponentType.split:
      case ComponentType.recipientList:
      case ComponentType.dynamicRouter:
      case ComponentType.loadBalance:
        return Colors.orange;
      case ComponentType.marshal:
      case ComponentType.unmarshal:
        return Colors.teal;
      case ComponentType.onException:
      case ComponentType.doTry:
      case ComponentType.doCatch:
      case ComponentType.doFinally:
        return Colors.red[700]!;
      case ComponentType.loop:
      case ComponentType.delay:
      case ComponentType.throttle:
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }
}

class ComponentChip extends StatelessWidget {
  final ComponentType type;

  const ComponentChip({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _getColor(type),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(type), color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            type.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(ComponentType type) {
    // Same as ComponentPaletteItem
    switch (type) {
      case ComponentType.from:
        return Icons.input;
      case ComponentType.to:
        return Icons.output;
      case ComponentType.transform:
        return Icons.transform;
      case ComponentType.filter:
        return Icons.filter_alt;
      case ComponentType.choice:
        return Icons.call_split;
      case ComponentType.log:
        return Icons.article;
      case ComponentType.setHeader:
        return Icons.view_headline;
      case ComponentType.setBody:
        return Icons.data_object;
      case ComponentType.process:
        return Icons.settings;
      case ComponentType.split:
        return Icons.call_split;
      case ComponentType.aggregate:
        return Icons.merge;
      case ComponentType.enrich:
        return Icons.add_circle;
      case ComponentType.multicast:
        return Icons.broadcast_on_personal;
      case ComponentType.wiretap:
        return Icons.visibility;
      case ComponentType.loop:
        return Icons.loop;
      case ComponentType.delay:
        return Icons.schedule;
      case ComponentType.throttle:
        return Icons.speed;
      default:
        return Icons.widgets;
    }
  }

  Color _getColor(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return Colors.green;
      case ComponentType.to:
        return Colors.red;
      case ComponentType.transform:
      case ComponentType.setBody:
      case ComponentType.setHeader:
        return Colors.purple;
      case ComponentType.choice:
      case ComponentType.filter:
      case ComponentType.multicast:
      case ComponentType.split:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

// ============================================================================
// CANVAS AREA - CONTINUED IN NEXT RESPONSE
// ============================================================================

class CanvasArea extends ConsumerStatefulWidget {
  const CanvasArea({Key? key}) : super(key: key);

  @override
  ConsumerState<CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends ConsumerState<CanvasArea> {
  String? _connectingFromId;
  Offset? _connectionEndPoint;
  final TransformationController _transformController =
      TransformationController();

  @override
  Widget build(BuildContext context) {
    final route = ref.watch(currentRouteProvider);
    final canvasState = ref.watch(canvasStateProvider);
    if (route == null) return const SizedBox();

    return Stack(
      children: [
        DragTarget<ComponentType>(
          onAcceptWithDetails: (details) {
            final renderBox = context.findRenderObject() as RenderBox;
            final localPos = renderBox.globalToLocal(details.offset);
            final matrix = _transformController.value;
            final scale = matrix.getMaxScaleOnAxis();
            final translation = matrix.getTranslation();

            final canvasPos =
                (localPos - Offset(translation.x, translation.y)) / scale;

            _addComponent(
              type: details.data,
              position: canvasState.snapToGrid
                  ? _snapToGrid(canvasPos, canvasState.gridSize)
                  : canvasPos,
            );
          },
          builder: (context, candidateData, rejectedData) {
            return GestureDetector(
              onTapUp: (details) {
                ref.read(selectedComponentProvider.notifier).clear();
              },
              child: InteractiveViewer(
                transformationController: _transformController,
                boundaryMargin: const EdgeInsets.all(2000),
                minScale: 0.5,
                maxScale: 2.0,
                constrained: false,
                child: SizedBox(
                  width: 4000,
                  height: 4000,
                  child: Stack(
                    children: [
                      // Grid background
                      if (canvasState.gridVisible)
                        CustomPaint(
                          size: const Size(4000, 4000),
                          painter: GridPainter(gridSize: canvasState.gridSize),
                        ),

                      // Connections
                      CustomPaint(
                        size: const Size(4000, 4000),
                        painter: ConnectionsPainter(
                          route.components,
                          route.connections,
                          _connectingFromId,
                          _connectionEndPoint,
                        ),
                      ),

                      // Components
                      ...route.components.map(
                        (c) => ComponentWidget(
                          key: ValueKey(c.id),
                          component: c,
                          isSelected: ref
                              .watch(selectedComponentProvider)
                              .contains(c.id),
                          onPositionChanged: (offset) =>
                              _updateComponentPosition(c, offset),
                          onTap: (isMulti) => _selectComponent(c.id, isMulti),
                          onConnectStart: () {
                            setState(() {
                              _connectingFromId = c.id;
                            });
                          },
                          onConnectEnd: (toId) => _createConnection(toId),
                          onConnectDrag: (position) {
                            setState(() {
                              _connectionEndPoint = position;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Minimap
        if (canvasState.minimapVisible)
          Positioned(
            right: 16,
            bottom: 16,
            child: MinimapWidget(
              components: route.components,
              connections: route.connections,
            ),
          ),
      ],
    );
  }

  Offset _snapToGrid(Offset position, double gridSize) {
    return Offset(
      (position.dx / gridSize).round() * gridSize,
      (position.dy / gridSize).round() * gridSize,
    );
  }

  void _addComponent({required ComponentType type, required Offset position}) {
    final component = IntegrationComponent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      label: type.name[0].toUpperCase() + type.name.substring(1),
      properties: _getDefaultProperties(type),
      position: position,
    );
    ref.read(currentRouteProvider.notifier).addComponent(component);
  }

  Map<String, dynamic> _getDefaultProperties(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return {'uri': 'direct:start'};
      case ComponentType.to:
        return {'uri': 'direct:end'};
      case ComponentType.log:
        return {'message': 'Processing: \${body}'};
      case ComponentType.delay:
        return {'delay': '1000'};
      case ComponentType.throttle:
        return {'maximumRequests': '10', 'timePeriodMillis': '1000'};
      default:
        return {};
    }
  }

  void _updateComponentPosition(IntegrationComponent component, Offset offset) {
    final canvasState = ref.read(canvasStateProvider);
    final finalOffset = canvasState.snapToGrid
        ? _snapToGrid(offset, canvasState.gridSize)
        : offset;

    ref
        .read(currentRouteProvider.notifier)
        .updateComponent(component.copyWith(position: finalOffset));
  }

  void _selectComponent(String id, bool isMulti) {
    if (isMulti) {
      ref.read(selectedComponentProvider.notifier).toggle(id);
    } else {
      ref.read(selectedComponentProvider.notifier).select(id);
    }
  }

  void _createConnection(String toId) {
    if (_connectingFromId != null && _connectingFromId != toId) {
      final connection = Connection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fromId: _connectingFromId!,
        toId: toId,
      );
      ref.read(currentRouteProvider.notifier).addConnection(connection);
    }
    setState(() {
      _connectingFromId = null;
      _connectionEndPoint = null;
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }
}

// ============================================================================
// GRID PAINTER
// ============================================================================

class GridPainter extends CustomPainter {
  final double gridSize;

  GridPainter({required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// COMPONENT WIDGET
// ============================================================================

class ComponentWidget extends StatefulWidget {
  final IntegrationComponent component;
  final bool isSelected;
  final Function(Offset) onPositionChanged;
  final Function(bool) onTap;
  final VoidCallback onConnectStart;
  final Function(String) onConnectEnd;
  final Function(Offset) onConnectDrag;

  const ComponentWidget({
    Key? key,
    required this.component,
    required this.isSelected,
    required this.onPositionChanged,
    required this.onTap,
    required this.onConnectStart,
    required this.onConnectEnd,
    required this.onConnectDrag,
  }) : super(key: key);

  @override
  State<ComponentWidget> createState() => _ComponentWidgetState();
}

class _ComponentWidgetState extends State<ComponentWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.component.position.dx,
      top: widget.component.position.dy,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () {
            widget.onTap(HardwareKeyboard.instance.isControlPressed);
          },
          onPanUpdate: (details) {
            widget.onPositionChanged(widget.component.position + details.delta);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.component.enabled
                  ? _getColor(widget.component.type)
                  : Colors.grey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? Colors.blue
                    : _isHovered
                    ? Colors.blue.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: widget.isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 
                    widget.isSelected ? 0.3 : 0.15,
                  ),
                  blurRadius: widget.isSelected ? 12 : 6,
                  offset: Offset(0, widget.isSelected ? 4 : 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getIcon(widget.component.type),
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.component.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        return PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 18,
                          ),
                          onSelected: (value) =>
                              _handleMenuAction(context, ref, value),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'duplicate',
                              child: Row(
                                children: [
                                  Icon(Icons.copy, size: 18),
                                  SizedBox(width: 8),
                                  Text('Duplicate'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'toggle',
                              child: Row(
                                children: [
                                  Icon(
                                    widget.component.enabled
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.component.enabled
                                        ? 'Disable'
                                        : 'Enable',
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                if (widget.component.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.component.description!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Input connector
                    GestureDetector(
                      onTap: () => widget.onConnectEnd(widget.component.id),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_downward,
                          size: 14,
                          color: _getColor(widget.component.type),
                        ),
                      ),
                    ),
                    // Output connector
                    GestureDetector(
                      onPanStart: (_) {
                        widget.onConnectStart();
                      },
                      onPanUpdate: (details) {
                        widget.onConnectDrag(
                          widget.component.position +
                              Offset(90, 60) +
                              details.localPosition,
                        );
                      },
                      onPanEnd: (_) {
                        widget.onConnectEnd(widget.component.id);
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: _getColor(widget.component.type),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'duplicate':
        ref
            .read(currentRouteProvider.notifier)
            .duplicateComponent(widget.component.id);
        break;
      case 'toggle':
        ref
            .read(currentRouteProvider.notifier)
            .updateComponent(
              widget.component.copyWith(enabled: !widget.component.enabled),
            );
        break;
      case 'delete':
        ref
            .read(currentRouteProvider.notifier)
            .deleteComponent(widget.component.id);
        break;
    }
  }

  IconData _getIcon(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return Icons.input;
      case ComponentType.to:
        return Icons.output;
      case ComponentType.transform:
        return Icons.transform;
      case ComponentType.filter:
        return Icons.filter_alt;
      case ComponentType.choice:
        return Icons.call_split;
      case ComponentType.log:
        return Icons.article;
      case ComponentType.setHeader:
        return Icons.view_headline;
      case ComponentType.setBody:
        return Icons.data_object;
      case ComponentType.process:
        return Icons.settings;
      case ComponentType.split:
        return Icons.call_split;
      case ComponentType.aggregate:
        return Icons.merge;
      case ComponentType.enrich:
        return Icons.add_circle;
      case ComponentType.multicast:
        return Icons.broadcast_on_personal;
      case ComponentType.wiretap:
        return Icons.visibility;
      case ComponentType.loop:
        return Icons.loop;
      case ComponentType.delay:
        return Icons.schedule;
      case ComponentType.throttle:
        return Icons.speed;
      default:
        return Icons.widgets;
    }
  }

  Color _getColor(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return Colors.green[700]!;
      case ComponentType.to:
        return Colors.red[700]!;
      case ComponentType.transform:
      case ComponentType.setBody:
      case ComponentType.setHeader:
        return Colors.purple[700]!;
      case ComponentType.choice:
      case ComponentType.filter:
      case ComponentType.multicast:
      case ComponentType.split:
        return Colors.orange[700]!;
      case ComponentType.loop:
      case ComponentType.delay:
      case ComponentType.throttle:
        return Colors.indigo[700]!;
      case ComponentType.marshal:
      case ComponentType.unmarshal:
        return Colors.teal[700]!;
      case ComponentType.onException:
      case ComponentType.doTry:
      case ComponentType.doCatch:
        return Colors.red[900]!;
      default:
        return Colors.blue[700]!;
    }
  }
}

// ============================================================================
// CONNECTIONS PAINTER
// ============================================================================

class ConnectionsPainter extends CustomPainter {
  final List<IntegrationComponent> components;
  final List<Connection> connections;
  final String? connectingFromId;
  final Offset? connectionEndPoint;

  ConnectionsPainter(
    this.components,
    this.connections,
    this.connectingFromId,
    this.connectionEndPoint,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Draw existing connections
    for (final conn in connections) {
      try {
        final from = components.firstWhere((c) => c.id == conn.fromId);
        final to = components.firstWhere((c) => c.id == conn.toId);

        final start = Offset(from.position.dx + 168, from.position.dy + 72);
        final end = Offset(to.position.dx + 12, to.position.dy + 12);

        _drawCurvedArrow(canvas, paint, start, end, conn.label);
      } catch (e) {
        // Component not found, skip connection
      }
    }

    // Draw temporary connection while dragging
    if (connectingFromId != null && connectionEndPoint != null) {
      try {
        final from = components.firstWhere((c) => c.id == connectingFromId);
        final start = Offset(from.position.dx + 168, from.position.dy + 72);

        final tempPaint = Paint()
          ..color = Colors.blue.withValues(alpha: 0.6)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

        _drawCurvedArrow(canvas, tempPaint, start, connectionEndPoint!, null);
      } catch (e) {
        // Component not found
      }
    }
  }

  void _drawCurvedArrow(
    Canvas canvas,
    Paint paint,
    Offset start,
    Offset end,
    String? label,
  ) {
    final controlPoint1 = Offset(start.dx + (end.dx - start.dx) / 2, start.dy);
    final controlPoint2 = Offset(start.dx + (end.dx - start.dx) / 2, end.dy);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        end.dx,
        end.dy,
      );

    canvas.drawPath(path, paint);

    // Draw arrow head
    final arrowSize = 12.0;
    final angle = math.atan2(
      end.dy - controlPoint2.dy,
      end.dx - controlPoint2.dx,
    );

    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - arrowSize * math.cos(angle - math.pi / 6),
        end.dy - arrowSize * math.sin(angle - math.pi / 6),
      )
      ..lineTo(
        end.dx - arrowSize * math.cos(angle + math.pi / 6),
        end.dy - arrowSize * math.sin(angle + math.pi / 6),
      )
      ..close();

    canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke;

    // Draw label if exists
    if (label != null && label.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 11,
            backgroundColor: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final midPoint = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

      textPainter.paint(
        canvas,
        midPoint - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============================================================================
// MINIMAP WIDGET
// ============================================================================

class MinimapWidget extends StatelessWidget {
  final List<IntegrationComponent> components;
  final List<Connection> connections;

  const MinimapWidget({
    Key? key,
    required this.components,
    required this.connections,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(painter: MinimapPainter(components, connections)),
    );
  }
}

class MinimapPainter extends CustomPainter {
  final List<IntegrationComponent> components;
  final List<Connection> connections;

  MinimapPainter(this.components, this.connections);

  @override
  void paint(Canvas canvas, Size size) {
    if (components.isEmpty) return;

    // Calculate bounds
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;

    for (final comp in components) {
      minX = math.min(minX, comp.position.dx);
      minY = math.min(minY, comp.position.dy);
      maxX = math.max(maxX, comp.position.dx + 180);
      maxY = math.max(maxY, comp.position.dy + 80);
    }

    final width = maxX - minX;
    final height = maxY - minY;
    final scale = math.min(size.width / width, size.height / height) * 0.9;

    // Draw connections
    final connPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;

    for (final conn in connections) {
      try {
        final from = components.firstWhere((c) => c.id == conn.fromId);
        final to = components.firstWhere((c) => c.id == conn.toId);

        final start = Offset(
          (from.position.dx - minX) * scale + 10,
          (from.position.dy - minY) * scale + 10,
        );
        final end = Offset(
          (to.position.dx - minX) * scale + 10,
          (to.position.dy - minY) * scale + 10,
        );

        canvas.drawLine(start, end, connPaint);
      } catch (e) {
        // Skip if component not found
      }
    }

    // Draw components
    for (final comp in components) {
      final rect = Rect.fromLTWH(
        (comp.position.dx - minX) * scale + 10,
        (comp.position.dy - minY) * scale + 10,
        180 * scale,
        80 * scale,
      );

      final paint = Paint()..color = Colors.blue[300]!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============================================================================
// PROPERTIES PANEL - Due to length, will continue in next part
// ============================================================================

class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectedComponentProvider);
    final route = ref.watch(currentRouteProvider);

    if (selectedIds.isEmpty || route == null) {
      return Container(
        width: 320,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No component selected',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a component to edit',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final component = route.components.firstWhere(
      (c) => c.id == selectedIds.first,
    );

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getColorForType(component.type),
                  _getColorForType(component.type).withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getIconForType(component.type),
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Properties',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        component.type.name.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    prefixIcon: Icon(Icons.label),
                  ),
                  controller: TextEditingController(text: component.label),
                  onChanged: (value) {
                    ref
                        .read(currentRouteProvider.notifier)
                        .updateComponent(component.copyWith(label: value));
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  controller: TextEditingController(
                    text: component.description ?? '',
                  ),
                  onChanged: (value) {
                    ref
                        .read(currentRouteProvider.notifier)
                        .updateComponent(
                          component.copyWith(description: value),
                        );
                  },
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Configuration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._buildPropertiesForType(context, ref, component),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPropertiesForType(
    BuildContext context,
    WidgetRef ref,
    IntegrationComponent component,
  ) {
    switch (component.type) {
      case ComponentType.from:
      case ComponentType.to:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'URI',
              prefixIcon: Icon(Icons.link),
              helperText: 'e.g., direct:start, file:input, http://example.com',
            ),
            controller: TextEditingController(
              text: component.properties['uri'] ?? '',
            ),
            onChanged: (value) => _updateProperty(ref, component, 'uri', value),
          ),
        ];

      case ComponentType.log:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Log Message',
              prefixIcon: Icon(Icons.message),
              helperText: 'Use \${body}, \${header.name}, etc.',
            ),
            controller: TextEditingController(
              text: component.properties['message'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'message', value),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Log Level',
              prefixIcon: Icon(Icons.info),
            ),
            value: component.properties['level'] ?? 'INFO',
            items: ['TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR']
                .map(
                  (level) => DropdownMenuItem(value: level, child: Text(level)),
                )
                .toList(),
            onChanged: (value) =>
                _updateProperty(ref, component, 'level', value ?? 'INFO'),
          ),
        ];

      case ComponentType.setHeader:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Header Name',
              prefixIcon: Icon(Icons.label),
            ),
            controller: TextEditingController(
              text: component.properties['name'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'name', value),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Header Value',
              prefixIcon: Icon(Icons.text_fields),
              helperText: 'Use expressions like \${body.field}',
            ),
            controller: TextEditingController(
              text: component.properties['value'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'value', value),
          ),
        ];

      case ComponentType.setBody:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Body Value',
              prefixIcon: Icon(Icons.data_object),
              helperText: 'Constant value or expression',
            ),
            controller: TextEditingController(
              text: component.properties['value'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'value', value),
            maxLines: 5,
          ),
        ];

      case ComponentType.transform:
        return [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Expression Language',
              prefixIcon: Icon(Icons.code),
            ),
            value: component.properties['language'] ?? 'simple',
            items: ['simple', 'jsonpath', 'xpath', 'groovy', 'spel']
                .map(
                  (lang) => DropdownMenuItem(
                    value: lang,
                    child: Text(lang.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                _updateProperty(ref, component, 'language', value ?? 'simple'),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Expression',
              prefixIcon: Icon(Icons.transform),
              helperText: 'Transformation expression',
            ),
            controller: TextEditingController(
              text: component.properties['expression'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'expression', value),
            maxLines: 3,
          ),
        ];

      case ComponentType.filter:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Filter Expression',
              prefixIcon: Icon(Icons.filter_alt),
              helperText: 'e.g., \${body.amount} > 100',
            ),
            controller: TextEditingController(
              text: component.properties['expression'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'expression', value),
            maxLines: 2,
          ),
        ];

      case ComponentType.choice:
        return [
          const Text('Define conditions in connections'),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              // Add condition dialog
            },
            icon: const Icon(Icons.add),
            label: const Text('Add When Condition'),
          ),
        ];

      case ComponentType.split:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Split Expression',
              prefixIcon: Icon(Icons.call_split),
              helperText: 'e.g., \${body} or xpath expression',
            ),
            controller: TextEditingController(
              text: component.properties['expression'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'expression', value),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Parallel Processing'),
            value: component.properties['parallel'] ?? false,
            onChanged: (value) =>
                _updateProperty(ref, component, 'parallel', value),
          ),
        ];

      case ComponentType.aggregate:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Correlation Expression',
              prefixIcon: Icon(Icons.merge),
              helperText: 'Group messages by this expression',
            ),
            controller: TextEditingController(
              text: component.properties['correlationExpression'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'correlationExpression', value),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Completion Size',
              prefixIcon: Icon(Icons.numbers),
              helperText: 'Number of messages to aggregate',
            ),
            controller: TextEditingController(
              text: component.properties['completionSize']?.toString() ?? '',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateProperty(
              ref,
              component,
              'completionSize',
              int.tryParse(value) ?? 0,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Completion Timeout (ms)',
              prefixIcon: Icon(Icons.timer),
            ),
            controller: TextEditingController(
              text: component.properties['completionTimeout']?.toString() ?? '',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateProperty(
              ref,
              component,
              'completionTimeout',
              int.tryParse(value) ?? 0,
            ),
          ),
        ];

      case ComponentType.enrich:
      case ComponentType.pollEnrich:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Resource URI',
              prefixIcon: Icon(Icons.cloud_download),
              helperText: 'URI to enrich from',
            ),
            controller: TextEditingController(
              text: component.properties['uri'] ?? '',
            ),
            onChanged: (value) => _updateProperty(ref, component, 'uri', value),
          ),
        ];

      case ComponentType.delay:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Delay (milliseconds)',
              prefixIcon: Icon(Icons.schedule),
            ),
            controller: TextEditingController(
              text: component.properties['delay']?.toString() ?? '1000',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateProperty(
              ref,
              component,
              'delay',
              int.tryParse(value) ?? 1000,
            ),
          ),
        ];

      case ComponentType.throttle:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Maximum Requests',
              prefixIcon: Icon(Icons.speed),
            ),
            controller: TextEditingController(
              text: component.properties['maximumRequests']?.toString() ?? '10',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateProperty(
              ref,
              component,
              'maximumRequests',
              int.tryParse(value) ?? 10,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Time Period (milliseconds)',
              prefixIcon: Icon(Icons.timer),
            ),
            controller: TextEditingController(
              text:
                  component.properties['timePeriodMillis']?.toString() ??
                  '1000',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateProperty(
              ref,
              component,
              'timePeriodMillis',
              int.tryParse(value) ?? 1000,
            ),
          ),
        ];

      case ComponentType.loop:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Loop Count',
              prefixIcon: Icon(Icons.loop),
              helperText: 'Number of iterations',
            ),
            controller: TextEditingController(
              text: component.properties['count']?.toString() ?? '1',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateProperty(
              ref,
              component,
              'count',
              int.tryParse(value) ?? 1,
            ),
          ),
        ];

      case ComponentType.marshal:
      case ComponentType.unmarshal:
        return [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: component.type == ComponentType.marshal
                  ? 'Marshal To'
                  : 'Unmarshal From',
              prefixIcon: const Icon(Icons.data_object),
            ),
            value: component.properties['format'] ?? 'json',
            items: ['json', 'xml', 'csv', 'yaml', 'protobuf', 'avro']
                .map(
                  (format) => DropdownMenuItem(
                    value: format,
                    child: Text(format.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                _updateProperty(ref, component, 'format', value ?? 'json'),
          ),
        ];

      case ComponentType.script:
        return [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Script Language',
              prefixIcon: Icon(Icons.code),
            ),
            value: component.properties['language'] ?? 'groovy',
            items: ['groovy', 'javascript', 'python', 'ruby']
                .map(
                  (lang) => DropdownMenuItem(
                    value: lang,
                    child: Text(lang.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                _updateProperty(ref, component, 'language', value ?? 'groovy'),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Script',
              prefixIcon: Icon(Icons.article),
              helperText: 'Enter script code',
            ),
            controller: TextEditingController(
              text: component.properties['script'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'script', value),
            maxLines: 10,
          ),
        ];

      case ComponentType.validate:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Validation Expression',
              prefixIcon: Icon(Icons.verified),
              helperText: 'Expression that should return true',
            ),
            controller: TextEditingController(
              text: component.properties['expression'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'expression', value),
            maxLines: 2,
          ),
        ];

      case ComponentType.process:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Processor Bean Reference',
              prefixIcon: Icon(Icons.settings),
              helperText: 'Spring bean name',
            ),
            controller: TextEditingController(
              text: component.properties['ref'] ?? '',
            ),
            onChanged: (value) => _updateProperty(ref, component, 'ref', value),
          ),
        ];

      case ComponentType.removeHeader:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Header Name',
              prefixIcon: Icon(Icons.remove),
            ),
            controller: TextEditingController(
              text: component.properties['name'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'name', value),
          ),
        ];

      case ComponentType.removeHeaders:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Pattern',
              prefixIcon: Icon(Icons.clear_all),
              helperText: 'Regex pattern for headers to remove',
            ),
            controller: TextEditingController(
              text: component.properties['pattern'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'pattern', value),
          ),
        ];

      default:
        return [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600]),
                const SizedBox(height: 8),
                Text(
                  'No additional properties for ${component.type.name}',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ];
    }
  }

  void _updateProperty(
    WidgetRef ref,
    IntegrationComponent component,
    String key,
    dynamic value,
  ) {
    final newProperties = Map<String, dynamic>.from(component.properties);
    newProperties[key] = value;
    ref
        .read(currentRouteProvider.notifier)
        .updateComponent(component.copyWith(properties: newProperties));
  }

  IconData _getIconForType(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return Icons.input;
      case ComponentType.to:
        return Icons.output;
      case ComponentType.transform:
        return Icons.transform;
      case ComponentType.filter:
        return Icons.filter_alt;
      case ComponentType.choice:
        return Icons.call_split;
      case ComponentType.log:
        return Icons.article;
      case ComponentType.setHeader:
        return Icons.view_headline;
      case ComponentType.setBody:
        return Icons.data_object;
      case ComponentType.process:
        return Icons.settings;
      case ComponentType.split:
        return Icons.call_split;
      case ComponentType.aggregate:
        return Icons.merge;
      default:
        return Icons.widgets;
    }
  }

  Color _getColorForType(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return Colors.green[700]!;
      case ComponentType.to:
        return Colors.red[700]!;
      case ComponentType.transform:
      case ComponentType.setBody:
      case ComponentType.setHeader:
        return Colors.purple[700]!;
      case ComponentType.choice:
      case ComponentType.filter:
      case ComponentType.multicast:
      case ComponentType.split:
        return Colors.orange[700]!;
      default:
        return Colors.blue[700]!;
    }
  }
}

// ============================================================================
// ROUTES LIST DIALOG
// ============================================================================

class RoutesListDialog extends ConsumerWidget {
  const RoutesListDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(routesProvider);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.account_tree),
          SizedBox(width: 8),
          Text('Integration Routes'),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 400,
        child: routes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No routes created yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  final route = routes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[700],
                        child: Text(
                          route.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        route.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (route.description.isNotEmpty)
                            Text(route.description),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.widgets,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text('${route.components.length} components'),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.update,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(_formatDate(route.updatedAt)),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _confirmDelete(context, ref, route);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        ref.read(currentRouteProvider.notifier).setRoute(route);
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
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    IntegrationRoute route,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Route'),
        content: Text('Are you sure you want to delete "${route.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(routesProvider.notifier).deleteRoute(route.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Route deleted')));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ROUTE PROPERTIES DIALOG
// ============================================================================

class RoutePropertiesDialog extends ConsumerStatefulWidget {
  final IntegrationRoute route;

  const RoutePropertiesDialog({Key? key, required this.route})
    : super(key: key);

  @override
  ConsumerState<RoutePropertiesDialog> createState() =>
      _RoutePropertiesDialogState();
}

class _RoutePropertiesDialogState extends ConsumerState<RoutePropertiesDialog> {
  late TextEditingController nameController;
  late TextEditingController descController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.route.name);
    descController = TextEditingController(text: widget.route.description);
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Route Properties'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Route Name',
                  prefixIcon: Icon(Icons.label),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const Text(
                'Statistics',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Components',
                widget.route.components.length.toString(),
              ),
              _buildInfoRow(
                'Connections',
                widget.route.connections.length.toString(),
              ),
              _buildInfoRow('Created', _formatDateTime(widget.route.createdAt)),
              _buildInfoRow(
                'Last Modified',
                _formatDateTime(widget.route.updatedAt),
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
          onPressed: () {
            final updated = widget.route.copyWith(
              name: nameController.text,
              description: descController.text,
            );
            ref.read(currentRouteProvider.notifier).setRoute(updated);
            ref.read(routesProvider.notifier).updateRoute(updated);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ============================================================================
// CODE GENERATORS
// ============================================================================

class CamelXMLGenerator {
  static String generate(IntegrationRoute route) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<routes xmlns="http://camel.apache.org/schema/spring">');
    buffer.writeln('  <route id="${route.id}">');
    buffer.writeln('    <description>${route.description}</description>');

    for (final component in route.components) {
      if (!component.enabled) continue;
      buffer.writeln(_componentToXML(component));
    }

    buffer.writeln('  </route>');
    buffer.writeln('</routes>');
    return buffer.toString();
  }

  static String _componentToXML(IntegrationComponent component) {
    final indent = '    ';

    switch (component.type) {
      case ComponentType.from:
        return '$indent<from uri="${component.properties['uri'] ?? 'direct:start'}"/>';
      case ComponentType.to:
        return '$indent<to uri="${component.properties['uri'] ?? 'direct:end'}"/>';
      case ComponentType.log:
        return '$indent<log message="${component.properties['message'] ?? 'Processing'}" loggingLevel="${component.properties['level'] ?? 'INFO'}"/>';
      case ComponentType.setHeader:
        return '$indent<setHeader name="${component.properties['name']}">\n$indent  <constant>${component.properties['value']}</constant>\n$indent</setHeader>';
      case ComponentType.setBody:
        return '$indent<setBody>\n$indent  <constant>${component.properties['value']}</constant>\n$indent</setBody>';
      case ComponentType.transform:
        return '$indent<transform>\n$indent  <${component.properties['language'] ?? 'simple'}>${component.properties['expression']}</${component.properties['language'] ?? 'simple'}>\n$indent</transform>';
      case ComponentType.filter:
        return '$indent<filter>\n$indent  <simple>${component.properties['expression']}</simple>\n$indent</filter>';
      case ComponentType.split:
        return '$indent<split ${component.properties['parallel'] == true ? 'parallelProcessing="true"' : ''}>\n$indent  <simple>${component.properties['expression']}</simple>\n$indent</split>';
      case ComponentType.delay:
        return '$indent<delay>\n$indent  <constant>${component.properties['delay']}</constant>\n$indent</delay>';
      case ComponentType.throttle:
        return '$indent<throttle timePeriodMillis="${component.properties['timePeriodMillis']}">\n$indent  <constant>${component.properties['maximumRequests']}</constant>\n$indent</throttle>';
      case ComponentType.marshal:
        return '$indent<marshal>\n$indent  <${component.properties['format'] ?? 'json'}/>\n$indent</marshal>';
      case ComponentType.unmarshal:
        return '$indent<unmarshal>\n$indent  <${component.properties['format'] ?? 'json'}/>\n$indent</unmarshal>';
      default:
        return '$indent<!-- ${component.type.name} -->';
    }
  }
}

class CamelYAMLGenerator {
  static String generate(IntegrationRoute route) {
    final buffer = StringBuffer();
    buffer.writeln('- route:');
    buffer.writeln('    id: ${route.id}');
    buffer.writeln('    description: ${route.description}');
    buffer.writeln('    from:');

    for (var i = 0; i < route.components.length; i++) {
      final component = route.components[i];
      if (!component.enabled) continue;

      buffer.writeln(_componentToYAML(component, i == 0));
    }

    return buffer.toString();
  }

  static String _componentToYAML(IntegrationComponent component, bool isFirst) {
    final indent = isFirst ? '      ' : '        ';

    switch (component.type) {
      case ComponentType.from:
        return '${indent}uri: ${component.properties['uri'] ?? 'direct:start'}';
      case ComponentType.to:
        return '${indent}- to:\n$indent    uri: ${component.properties['uri'] ?? 'direct:end'}';
      case ComponentType.log:
        return '${indent}- log: "${component.properties['message'] ?? 'Processing'}"';
      case ComponentType.setHeader:
        return '${indent}- setHeader:\n$indent    name: ${component.properties['name']}\n$indent    constant: ${component.properties['value']}';
      case ComponentType.setBody:
        return '${indent}- setBody:\n$indent    constant: ${component.properties['value']}';
      default:
        return '${indent}- # ${component.type.name}';
    }
  }
}

// ============================================================================
// ROUTE VALIDATOR
// ============================================================================

class RouteValidator {
  static ValidationResult validate(IntegrationRoute route) {
    final errors = <String>[];

    if (route.components.isEmpty) {
      errors.add('Route has no components');
      return ValidationResult(isValid: false, errors: errors);
    }

    // Check for "from" component
    final hasFrom = route.components.any((c) => c.type == ComponentType.from);
    if (!hasFrom) {
      errors.add('Route must have at least one "from" component');
    }

    // Check for orphaned components
    for (final component in route.components) {
      if (component.type != ComponentType.from) {
        final hasIncoming = route.connections.any(
          (c) => c.toId == component.id,
        );
        if (!hasIncoming) {
          errors.add(
            'Component "${component.label}" has no incoming connections',
          );
        }
      }
    }

    // Validate component properties
    for (final component in route.components) {
      switch (component.type) {
        case ComponentType.from:
        case ComponentType.to:
          if (component.properties['uri'] == null ||
              component.properties['uri'].isEmpty) {
            errors.add('Component "${component.label}" missing URI');
          }
          break;
        case ComponentType.setHeader:
          if (component.properties['name'] == null ||
              component.properties['name'].isEmpty) {
            errors.add('Component "${component.label}" missing header name');
          }
          break;
        case ComponentType.transform:
        case ComponentType.filter:
          if (component.properties['expression'] == null ||
              component.properties['expression'].isEmpty) {
            errors.add('Component "${component.label}" missing expression');
          }
          break;
        default:
          break;
      }
    }

    // Check for circular dependencies
    if (_hasCircularDependencies(route)) {
      errors.add('Route contains circular dependencies');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  static bool _hasCircularDependencies(IntegrationRoute route) {
    final visited = <String>{};
    final stack = <String>{};

    bool hasCycle(String componentId) {
      if (stack.contains(componentId)) return true;
      if (visited.contains(componentId)) return false;

      visited.add(componentId);
      stack.add(componentId);

      final outgoing = route.connections.where((c) => c.fromId == componentId);
      for (final conn in outgoing) {
        if (hasCycle(conn.toId)) return true;
      }

      stack.remove(componentId);
      return false;
    }

    for (final component in route.components) {
      if (hasCycle(component.id)) return true;
    }

    return false;
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({required this.isValid, required this.errors});
}
