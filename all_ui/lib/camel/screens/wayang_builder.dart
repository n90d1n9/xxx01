import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/history_entry.dart';
import '../models/node.dart';
import '../services/node_selection_handler.dart';
import '../services/undo_redo_handler.dart';
import '../states/node_route_provider.dart';
import '../states/provider.dart';
import '../states/route_history_provider.dart';
import '../states/select_route_provider.dart';
import '../utils/convert_to_yaml.dart';
import '../widgets/canvas/canvas_area.dart';

import '../widgets/component_palette.dart';
//import '../widgets/component_palette2.dart';

import '../widgets/home/appbar.dart';
import '../widgets/home/yaml_dialog.dart';
import '../widgets/node_selector.dart';
import '../widgets/properties_panel.dart';

class WayangBuilder extends ConsumerStatefulWidget {
  const WayangBuilder({super.key});

  @override
  ConsumerState<WayangBuilder> createState() => _WayangBuilderState();
}

class _WayangBuilderState extends ConsumerState<WayangBuilder> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeRoute();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _initializeRoute() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = WNode(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'My First Route',
        description: 'A sample integration route',
      );
      ref.read(routesProvider.notifier).addRoute(route);
      ref.read(selectedRouteIdProvider.notifier).state = route.id;

      ref
          .read(routeHistoryProvider.notifier)
          .push(HistoryEntry(routes: [route], selectedRouteId: route.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: WayangAppBar(),
        body: Row(
          children: [
            SizedBox(width: 250, child: ComponentPalette()),
            Expanded(child: CanvasArea()),
            SizedBox(width: 320, child: PropertiesPanel()),
          ],
        ),
        bottomNavigationBar: const NodeSelector(),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final isControlPressed =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;

    if (isControlPressed && event.logicalKey == LogicalKeyboardKey.keyZ) {
      _handleUndo();
    } else if (isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyY) {
      _handleRedo();
    } else if (isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyS) {
      _handleExport('json');
    } else if (isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyA) {
      NodeSelectionHandler.selectAllNodes(ref);
    } else if (isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyC) {
      NodeSelectionHandler.copySelectedNodes(ref, context);
    } else if (isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyV) {
      NodeSelectionHandler.pasteNodes(ref, context);
    } else if (event.logicalKey == LogicalKeyboardKey.delete) {
      NodeSelectionHandler.deleteSelectedNodes(ref, context);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _moveSelectedNodesWithKeys(event.logicalKey);
    }
  }

  void _handleUndo() => UndoRedoHandler.handleUndo(ref);
  void _handleRedo() => UndoRedoHandler.handleRedo(ref);

  // Keep only the methods that need to stay in the main class
  void _moveSelectedNodesWithKeys(LogicalKeyboardKey key) {
    final routeId = ref.read(selectedRouteIdProvider);
    final selectedNodeIds = ref.read(selectedNodesProvider);

    if (routeId == null || selectedNodeIds.isEmpty) return;

    Offset delta = Offset.zero;
    final snapToGrid = ref.read(snapToGridProvider);
    final step = snapToGrid ? 20.0 : 10.0;

    if (key == LogicalKeyboardKey.arrowUp) {
      delta = Offset(0, -step);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      delta = Offset(0, step);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      delta = Offset(-step, 0);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      delta = Offset(step, 0);
    }
    ref
        .read(routesProvider.notifier)
        .moveNodes(routeId, selectedNodeIds, delta);
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

  void _showYamlDialog(BuildContext context) {
    final route = ref.read(selectedRouteProvider);
    if (route == null) return;

    final yaml = CodeConverter.toYaml(route);

    showDialog(context: context, builder: (context) => YamlDialog(yaml: yaml));
  }
}
