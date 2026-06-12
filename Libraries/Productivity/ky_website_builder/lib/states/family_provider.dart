// Get specific component by ID
import 'package:flutter_riverpod/legacy.dart';

import '../models/design_component.dart';
import 'provider.dart';

final componentByIdProvider = Provider.family<DesignComponent?, String>((
  ref,
  id,
) {
  final state = ref.watch(designerProvider);
  try {
    return state.components.firstWhere((c) => c.id == id);
  } catch (e) {
    return null;
  }
});

// Check if component is selected
final isComponentSelectedProvider = Provider.family<bool, String>((ref, id) {
  final state = ref.watch(designerProvider);
  return state.selectedComponentIds.contains(id);
});

// Get component children
final componentChildrenProvider =
    Provider.family<List<DesignComponent>, String>((ref, id) {
      final state = ref.watch(designerProvider);
      return state.components.where((c) => c.parentId == id).toList();
    });

// Get components in a group
final groupComponentsProvider = Provider.family<List<DesignComponent>, String>((
  ref,
  groupId,
) {
  final state = ref.watch(designerProvider);
  return state.components.where((c) => c.groupId == groupId).toList();
});

// Component property provider
final componentPropertyProvider =
    Provider.family<dynamic, ({String id, String property})>((ref, params) {
      final component = ref.watch(componentByIdProvider(params.id));
      return component?.properties[params.property];
    });
