import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/component_type.dart';

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
