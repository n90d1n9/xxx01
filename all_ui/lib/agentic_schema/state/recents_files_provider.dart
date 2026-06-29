import 'package:flutter_riverpod/legacy.dart';

import '../model/recent_file.dart';

final recentFilesProvider =
    StateNotifierProvider<RecentFilesNotifier, List<RecentFile>>(
      (ref) => RecentFilesNotifier(),
    );

class RecentFilesNotifier extends StateNotifier<List<RecentFile>> {
  RecentFilesNotifier() : super([]) {
    _loadRecentFiles();
  }

  Future<void> _loadRecentFiles() async {
    // Load from shared preferences
    state = []; // Placeholder
  }

  void addFile(String id, String name, String path) {
    final file = RecentFile(
      id: id,
      name: name,
      lastOpened: DateTime.now(),
      path: path,
    );

    // Remove if already exists
    state = state.where((f) => f.id != id).toList();

    // Add to beginning
    state = [file, ...state];

    // Keep only last 10
    if (state.length > 10) {
      state = state.sublist(0, 10);
    }

    // Save to preferences
  }

  void clear() {
    state = [];
  }
}
