// Filtered Components based on search
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/component_library.dart';
import '../models/component_template.dart';
import 'provider.dart';

final filteredComponentsProvider = Provider<List<ComponentTemplate>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final allComponents = ComponentLibrary.allComponents;

  if (query.isEmpty) return allComponents;

  return allComponents.where((comp) {
    return comp.name.toLowerCase().contains(query) ||
        comp.description.toLowerCase().contains(query) ||
        comp.tags.any((tag) => tag.toLowerCase().contains(query));
  }).toList();
});
