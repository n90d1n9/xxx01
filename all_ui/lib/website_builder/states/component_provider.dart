// ============================================================================
// COMPUTED PROVIDERS
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/design_component.dart';
import '../services/alignment_service.dart';
import '../services/component_service.dart';
import 'provider.dart';

final sortedComponentsProvider = Provider<List<DesignComponent>>((ref) {
  final state = ref.watch(designerProvider);
  return List<DesignComponent>.from(state.components)
    ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
});

final hasUnsavedChangesProvider = Provider<bool>((ref) {
  final state = ref.watch(designerProvider);
  return state.hasUnsavedChanges;
});

final componentCountProvider = Provider<int>((ref) {
  return ref.watch(designerProvider).components.length;
});

final selectedCountProvider = Provider<int>((ref) {
  return ref.watch(designerProvider).selectedComponentIds.length;
});

final selectedComponentProvider = Provider<DesignComponent?>((ref) {
  return ref.watch(designerProvider).selectedComponent;
});

final alignmentServiceProvider = Provider((ref) => AlignmentService());

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

final componentServiceProvider = Provider((ref) => ComponentService());
