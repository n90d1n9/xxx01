import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/validation_error.dart';
import 'select_route_provider.dart';

final validationErrorsProvider = Provider<List<ValidationError>>((ref) {
  final route = ref.watch(selectedRouteProvider);
  if (route == null) return [];

  final errors = <ValidationError>[];

  for (final node in route.nodes) {
    // Check for empty required fields
    for (final entry in node.config.entries) {
      if (entry.value.toString().isEmpty) {
        errors.add(
          ValidationError(
            nodeId: node.id,
            message: 'Field "${entry.key}" is empty',
            severity: 'warning',
          ),
        );
      }
    }

    // Check for disconnected nodes (except last ones)
    final hasOutgoing = node.connections.isNotEmpty;
    final hasIncoming = route.nodes.any((n) => n.connections.contains(node.id));

    if (!hasOutgoing && !hasIncoming && route.nodes.length > 1) {
      errors.add(
        ValidationError(
          nodeId: node.id,
          message: 'Node is not connected to the flow',
          severity: 'error',
        ),
      );
    }
  }

  return errors;
});
