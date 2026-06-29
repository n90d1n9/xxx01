import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/connection.dart';
import '../model/integration_component.dart';
import '../model/integration_route.dart';

final currentRouteProvider =
    StateNotifierProvider<CurrentRouteNotifier, IntegrationRoute?>((ref) {
      return CurrentRouteNotifier();
    });

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
