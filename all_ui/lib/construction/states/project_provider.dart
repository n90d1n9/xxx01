// Selected Project Provider
import 'package:flutter_riverpod/legacy.dart';

import '../models/project.dart';

final selectedProjectProvider = StateProvider<Project?>((ref) => null);

// Projects Provider
final projectsProvider = StateNotifierProvider<ProjectsNotifier, List<Project>>(
  (ref) => ProjectsNotifier(),
);

class ProjectsNotifier extends StateNotifier<List<Project>> {
  ProjectsNotifier() : super([]);

  void addProject(Project project) {
    state = [...state, project];
  }

  void updateProject(Project project) {
    state = [
      for (final p in state)
        if (p.id == project.id) project else p,
    ];
  }

  void deleteProject(String id) {
    state = state.where((p) => p.id != id).toList();
  }
}
