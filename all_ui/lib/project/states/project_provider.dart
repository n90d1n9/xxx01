// SearchProvider for filtering projects
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../project.dart';

final projectSearchQueryProvider = StateProvider<String>((ref) => '');
final filteredProjectsProvider = Provider<List<Project>>((ref) {
  final projects = ref.watch(projectsProvider);
  final searchQuery = ref.watch(projectSearchQueryProvider).toLowerCase();

  if (searchQuery.isEmpty) {
    return projects;
  }

  return projects.where((project) {
    return project.name.toLowerCase().contains(searchQuery) ||
        project.manager.toLowerCase().contains(searchQuery) ||
        project.status.toLowerCase().contains(searchQuery);
  }).toList();
});
