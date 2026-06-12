// lib/providers/file_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../models/mock_data.dart';

// ─── View Mode ────────────────────────────────────────────────────────────────

final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.grid);
final gridColumnCountProvider = StateProvider<int>((ref) => 2); // user-adjustable

// ─── Sort ─────────────────────────────────────────────────────────────────────

final sortByProvider = StateProvider<SortBy>((ref) => SortBy.name);
final sortOrderProvider = StateProvider<SortOrder>((ref) => SortOrder.ascending);

// ─── Search ───────────────────────────────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');
final isSearchActiveProvider = StateProvider<bool>((ref) => false);

// Search history (in-memory)
final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]);
  void add(String query) {
    if (query.trim().isEmpty) return;
    final updated = [query, ...state.where((q) => q != query)].take(10).toList();
    state = updated;
  }
  void remove(String query) => state = state.where((q) => q != query).toList();
  void clear() => state = [];
}

// ─── Type Filter ──────────────────────────────────────────────────────────────

final typeFilterProvider = StateProvider<FileType?>((ref) => null);

// ─── Navigation / Path ────────────────────────────────────────────────────────

final navigationStackProvider =
    StateNotifierProvider<NavigationStackNotifier, List<String?>>((ref) {
  return NavigationStackNotifier();
});

class NavigationStackNotifier extends StateNotifier<List<String?>> {
  NavigationStackNotifier() : super([null]);

  String? get currentFolderId => state.last;

  void navigateTo(String? folderId) {
    state = [...state, folderId];
  }

  void navigateBack() {
    if (state.length > 1) state = state.sublist(0, state.length - 1);
  }

  void navigateToIndex(int index) {
    state = state.sublist(0, index + 1);
  }

  bool get canGoBack => state.length > 1;
}

final currentFolderIdProvider = Provider<String?>((ref) {
  return ref.watch(navigationStackProvider).last;
});

// ─── Files Notifier ───────────────────────────────────────────────────────────

final filesNotifierProvider =
    StateNotifierProvider<FilesNotifier, List<FileItem>>((ref) {
  return FilesNotifier(List.from(mockFiles));
});

class FilesNotifier extends StateNotifier<List<FileItem>> {
  FilesNotifier(List<FileItem> initialFiles) : super(initialFiles);

  void toggleStar(String id) {
    state = state.map((f) {
      if (f.id == id) return f.copyWith(isStarred: !f.isStarred);
      return f;
    }).toList();
  }

  /// Soft-delete: move to trash
  void trashFile(String id) {
    state = state.map((f) {
      if (f.id == id) {
        return f.copyWith(isTrashed: true, trashedAt: DateTime.now());
      }
      return f;
    }).toList();
  }

  /// Permanently delete
  void deleteFilePermanently(String id) {
    state = state.where((f) => f.id != id).toList();
  }

  /// Restore from trash
  void restoreFile(String id) {
    state = state.map((f) {
      if (f.id == id) {
        return FileItem(
          id: f.id, name: f.name, type: f.type, sizeBytes: f.sizeBytes,
          dateModified: f.dateModified, dateCreated: f.dateCreated,
          parentId: f.parentId, thumbnailUrl: f.thumbnailUrl,
          isStarred: f.isStarred, isShared: f.isShared,
          owner: f.owner, folderColor: f.folderColor, tags: f.tags,
          isTrashed: false, trashedAt: null,
          description: f.description, sharedWith: f.sharedWith,
          lastOpenedAt: f.lastOpenedAt, itemCount: f.itemCount,
        );
      }
      return f;
    }).toList();
  }

  void emptyTrash() {
    state = state.where((f) => !f.isTrashed).toList();
  }

  void renameFile(String id, String newName) {
    final old = state.firstWhere((f) => f.id == id, orElse: () => state.first);
    state = state.map((f) {
      if (f.id == id) return f.copyWith(name: newName, dateModified: DateTime.now());
      return f;
    }).toList();
    _pendingActivity = (old.name, id, ActivityType.renamed, 'Renamed to "$newName"');
  }

  // Buffer for activity — consumed by UI layer via activityLogProvider
  (String, String, ActivityType, String?)? _pendingActivity;

  void addFile(FileItem file) {
    state = [...state, file];
  }

  void moveFile(String id, String? targetFolderId) {
    state = state.map((f) {
      if (f.id == id) return f.copyWith(parentId: targetFolderId, dateModified: DateTime.now());
      return f;
    }).toList();
  }

  void updateLastOpened(String id) {
    state = state.map((f) {
      if (f.id == id) return f.copyWith(lastOpenedAt: DateTime.now());
      return f;
    }).toList();
  }

  void updateDescription(String id, String desc) {
    state = state.map((f) {
      if (f.id == id) return f.copyWith(description: desc);
      return f;
    }).toList();
  }

  void addTag(String id, String tag) {
    state = state.map((f) {
      if (f.id == id && !f.tags.contains(tag)) {
        return f.copyWith(tags: [...f.tags, tag]);
      }
      return f;
    }).toList();
  }

  void removeTag(String id, String tag) {
    state = state.map((f) {
      if (f.id == id) {
        return f.copyWith(tags: f.tags.where((t) => t != tag).toList());
      }
      return f;
    }).toList();
  }

  void updateFolderColor(String id, Color color) {
    state = state.map((f) {
      if (f.id == id) return f.copyWith(folderColor: color);
      return f;
    }).toList();
  }
}

// ─── Derived file lists ───────────────────────────────────────────────────────

List<FileItem> _sortFiles(List<FileItem> files, SortBy sortBy, SortOrder sortOrder) {
  files.sort((a, b) {
    if (a.isFolder && !b.isFolder) return -1;
    if (!a.isFolder && b.isFolder) return 1;
    int cmp;
    switch (sortBy) {
      case SortBy.name:
        cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        break;
      case SortBy.dateModified:
        cmp = a.dateModified.compareTo(b.dateModified);
        break;
      case SortBy.size:
        cmp = (a.sizeBytes ?? 0).compareTo(b.sizeBytes ?? 0);
        break;
      case SortBy.type:
        cmp = a.type.index.compareTo(b.type.index);
        break;
    }
    return sortOrder == SortOrder.ascending ? cmp : -cmp;
  });
  return files;
}

final currentFolderFilesProvider = Provider<List<FileItem>>((ref) {
  final allFiles = ref.watch(filesNotifierProvider);
  final currentFolderId = ref.watch(currentFolderIdProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase().trim();
  final sortBy = ref.watch(sortByProvider);
  final sortOrder = ref.watch(sortOrderProvider);
  final isSearchActive = ref.watch(isSearchActiveProvider);
  final typeFilter = ref.watch(typeFilterProvider);

  List<FileItem> files;

  if (isSearchActive && searchQuery.isNotEmpty) {
    files = allFiles
        .where((f) => !f.isTrashed && f.name.toLowerCase().contains(searchQuery))
        .toList();
  } else {
    files = allFiles
        .where((f) => f.parentId == currentFolderId && !f.isTrashed)
        .toList();
  }

  if (typeFilter != null) {
    files = files.where((f) => f.type == typeFilter).toList();
  }

  return _sortFiles(files, sortBy, sortOrder);
});

final starredFilesProvider = Provider<List<FileItem>>((ref) {
  final files = ref.watch(filesNotifierProvider)
      .where((f) => f.isStarred && !f.isTrashed)
      .toList();
  return _sortFiles(files, ref.watch(sortByProvider), ref.watch(sortOrderProvider));
});

final recentFilesProvider = Provider<List<FileItem>>((ref) {
  final files = ref.watch(filesNotifierProvider)
      .where((f) => !f.isFolder && !f.isTrashed && f.lastOpenedAt != null)
      .toList();
  files.sort((a, b) => b.lastOpenedAt!.compareTo(a.lastOpenedAt!));
  return files.take(30).toList();
});

final sharedFilesProvider = Provider<List<FileItem>>((ref) {
  return ref.watch(filesNotifierProvider)
      .where((f) => f.isShared && !f.isTrashed)
      .toList();
});

final trashedFilesProvider = Provider<List<FileItem>>((ref) {
  final files = ref.watch(filesNotifierProvider).where((f) => f.isTrashed).toList();
  files.sort((a, b) => (b.trashedAt ?? DateTime.now()).compareTo(a.trashedAt ?? DateTime.now()));
  return files;
});

// ─── Selection ────────────────────────────────────────────────────────────────

final selectedFilesProvider =
    StateNotifierProvider<SelectedFilesNotifier, Set<String>>((ref) {
  return SelectedFilesNotifier();
});

class SelectedFilesNotifier extends StateNotifier<Set<String>> {
  SelectedFilesNotifier() : super({});

  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void selectAll(List<String> ids) => state = ids.toSet();
  void clearAll() => state = {};
  bool isSelected(String id) => state.contains(id);
}

// ─── Breadcrumb ───────────────────────────────────────────────────────────────

final breadcrumbProvider = Provider<List<FileItem?>>((ref) {
  final stack = ref.watch(navigationStackProvider);
  final allFiles = ref.watch(filesNotifierProvider);
  return stack.map((id) {
    if (id == null) return null;
    return allFiles.firstWhere(
      (f) => f.id == id,
      orElse: () => FileItem(
        id: id, name: 'Unknown', type: FileType.folder,
        dateModified: DateTime.now(), dateCreated: DateTime.now(),
      ),
    );
  }).toList();
});

// ─── Drawer Section ───────────────────────────────────────────────────────────

enum DrawerSection { myDrive, recent, starred, shared, trash }

final drawerSectionProvider =
    StateProvider<DrawerSection>((ref) => DrawerSection.myDrive);

// ─── Upload Tasks ─────────────────────────────────────────────────────────────

final uploadTasksProvider =
    StateNotifierProvider<UploadTasksNotifier, List<UploadTask>>((ref) {
  return UploadTasksNotifier();
});

class UploadTasksNotifier extends StateNotifier<List<UploadTask>> {
  UploadTasksNotifier() : super([]);

  Timer? _timer;

  void startFakeUpload(String fileName, FileType type, String? targetFolderId) {
    final task = UploadTask(
      id: 'upload-${DateTime.now().millisecondsSinceEpoch}',
      fileName: fileName,
      fileType: type,
      targetFolderId: targetFolderId,
    );
    state = [...state, task];
    _simulateProgress(task.id);
  }

  void _simulateProgress(String id) {
    int ticks = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      ticks++;
      final progress = (ticks / 25).clamp(0.0, 1.0);
      state = state.map((t) {
        if (t.id == id) return t.copyWith(progress: progress, isComplete: progress >= 1.0);
        return t;
      }).toList();
      if (progress >= 1.0) {
        timer.cancel();
        Future.delayed(const Duration(seconds: 2), () {
          state = state.where((t) => t.id != id).toList();
        });
      }
    });
  }

  void cancelUpload(String id) {
    _timer?.cancel();
    state = state.where((t) => t.id != id).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ─── Storage Stats ────────────────────────────────────────────────────────────

class StorageStats {
  final Map<FileType, int> bytesByType;
  final int totalBytes;
  const StorageStats({required this.bytesByType, required this.totalBytes});
}

final storageStatsProvider = Provider<StorageStats>((ref) {
  final files = ref.watch(filesNotifierProvider).where((f) => !f.isFolder && !f.isTrashed);
  final Map<FileType, int> byType = {};
  int total = 0;
  for (final f in files) {
    final bytes = f.sizeBytes ?? 0;
    byType[f.type] = (byType[f.type] ?? 0) + bytes;
    total += bytes;
  }
  return StorageStats(bytesByType: byType, totalBytes: total);
});

// ─── Theme ────────────────────────────────────────────────────────────────────

final isDarkModeProvider = StateProvider<bool>((ref) => false);

// ─── File Info Panel ──────────────────────────────────────────────────────────

final infoPanelFileProvider = StateProvider<FileItem?>((ref) => null);
final isInfoPanelOpenProvider = StateProvider<bool>((ref) => false);

// ─── Activity Log ─────────────────────────────────────────────────────────────

enum ActivityType { created, modified, deleted, moved, shared, renamed, trashed, restored }

class ActivityEntry {
  final String id;
  final String fileName;
  final String? fileId;
  final ActivityType activity;
  final DateTime timestamp;
  final String? detail;

  const ActivityEntry({
    required this.id,
    required this.fileName,
    this.fileId,
    required this.activity,
    required this.timestamp,
    this.detail,
  });
}

final activityLogProvider =
    StateNotifierProvider<ActivityLogNotifier, List<ActivityEntry>>((ref) {
  return ActivityLogNotifier();
});

class ActivityLogNotifier extends StateNotifier<List<ActivityEntry>> {
  ActivityLogNotifier() : super(_seedLog());

  void log(String fileName, String? fileId, ActivityType type, {String? detail}) {
    final entry = ActivityEntry(
      id: 'act-${DateTime.now().millisecondsSinceEpoch}',
      fileName: fileName,
      fileId: fileId,
      activity: type,
      timestamp: DateTime.now(),
      detail: detail,
    );
    state = [entry, ...state].take(200).toList();
  }

  void clear() => state = [];

  static List<ActivityEntry> _seedLog() {
    final now = DateTime.now();
    return [
      ActivityEntry(id: 'a1', fileName: 'Project Proposal.docx', fileId: 'doc-1',
        activity: ActivityType.modified, timestamp: now.subtract(const Duration(hours: 1))),
      ActivityEntry(id: 'a2', fileName: 'Budget 2024.xlsx', fileId: 'sheet-1',
        activity: ActivityType.shared, timestamp: now.subtract(const Duration(hours: 3)),
        detail: 'Shared with finance@co.com'),
      ActivityEntry(id: 'a3', fileName: 'Meeting Notes.docx', fileId: 'doc-2',
        activity: ActivityType.created, timestamp: now.subtract(const Duration(hours: 6))),
      ActivityEntry(id: 'a4', fileName: 'Logo_Final.png', fileId: 'img-2',
        activity: ActivityType.modified, timestamp: now.subtract(const Duration(days: 1))),
      ActivityEntry(id: 'a5', fileName: 'Q1 Reports', fileId: 'folder-1-1',
        activity: ActivityType.created, timestamp: now.subtract(const Duration(days: 2))),
      ActivityEntry(id: 'a6', fileName: 'Old Draft.docx',
        activity: ActivityType.trashed, timestamp: now.subtract(const Duration(days: 5)),
        detail: 'Moved to trash'),
      ActivityEntry(id: 'a7', fileName: 'Brand Guidelines.pdf', fileId: 'pdf-2',
        activity: ActivityType.shared, timestamp: now.subtract(const Duration(days: 6)),
        detail: 'Shared via link'),
      ActivityEntry(id: 'a8', fileName: 'Annual Report 2023.pdf', fileId: 'pdf-1',
        activity: ActivityType.modified, timestamp: now.subtract(const Duration(days: 7))),
      ActivityEntry(id: 'a9', fileName: 'Product Demo.mp4', fileId: 'video-1',
        activity: ActivityType.shared, timestamp: now.subtract(const Duration(days: 8)),
        detail: 'Shared with marketing@co.com'),
      ActivityEntry(id: 'a10', fileName: 'Work Projects', fileId: 'folder-1',
        activity: ActivityType.created, timestamp: now.subtract(const Duration(days: 60))),
    ];
  }
}

// ─── Clipboard (cut/copy/paste) ───────────────────────────────────────────────

enum ClipboardOperation { copy, cut }

class ClipboardState {
  final List<String> fileIds;
  final ClipboardOperation operation;
  const ClipboardState({required this.fileIds, required this.operation});
}

final fileClipboardProvider =
    StateNotifierProvider<FileClipboardNotifier, ClipboardState?>((ref) {
  return FileClipboardNotifier();
});

class FileClipboardNotifier extends StateNotifier<ClipboardState?> {
  FileClipboardNotifier() : super(null);

  void copy(List<String> ids) =>
      state = ClipboardState(fileIds: ids, operation: ClipboardOperation.copy);

  void cut(List<String> ids) =>
      state = ClipboardState(fileIds: ids, operation: ClipboardOperation.cut);

  void paste(WidgetRef ref, String? targetFolderId) {
    if (state == null) return;
    final notifier = ref.read(filesNotifierProvider.notifier);
    for (final id in state!.fileIds) {
      if (state!.operation == ClipboardOperation.cut) {
        notifier.moveFile(id, targetFolderId);
      }
      // copy = would duplicate — add duplicate logic if needed
    }
    if (state!.operation == ClipboardOperation.cut) state = null;
  }

  void clear() => state = null;
}

// ─── Settings / Preferences ───────────────────────────────────────────────────

class AppPreferences {
  final bool isDarkMode;
  final int gridColumns;
  final bool showHiddenFiles;
  final bool confirmBeforeDelete;
  final bool autoOpenOnSingleTap;
  final String defaultView; // 'grid' | 'list' | 'detail'
  final bool showFileExtensions;
  final bool groupFoldersFirst;
  final double thumbnailSize; // 0.5–2.0 scale

  const AppPreferences({
    this.isDarkMode = false,
    this.gridColumns = 2,
    this.showHiddenFiles = false,
    this.confirmBeforeDelete = true,
    this.autoOpenOnSingleTap = true,
    this.defaultView = 'grid',
    this.showFileExtensions = true,
    this.groupFoldersFirst = true,
    this.thumbnailSize = 1.0,
  });

  AppPreferences copyWith({
    bool? isDarkMode,
    int? gridColumns,
    bool? showHiddenFiles,
    bool? confirmBeforeDelete,
    bool? autoOpenOnSingleTap,
    String? defaultView,
    bool? showFileExtensions,
    bool? groupFoldersFirst,
    double? thumbnailSize,
  }) => AppPreferences(
    isDarkMode: isDarkMode ?? this.isDarkMode,
    gridColumns: gridColumns ?? this.gridColumns,
    showHiddenFiles: showHiddenFiles ?? this.showHiddenFiles,
    confirmBeforeDelete: confirmBeforeDelete ?? this.confirmBeforeDelete,
    autoOpenOnSingleTap: autoOpenOnSingleTap ?? this.autoOpenOnSingleTap,
    defaultView: defaultView ?? this.defaultView,
    showFileExtensions: showFileExtensions ?? this.showFileExtensions,
    groupFoldersFirst: groupFoldersFirst ?? this.groupFoldersFirst,
    thumbnailSize: thumbnailSize ?? this.thumbnailSize,
  );
}

final appPreferencesProvider =
    StateNotifierProvider<AppPreferencesNotifier, AppPreferences>((ref) {
  return AppPreferencesNotifier();
});

class AppPreferencesNotifier extends StateNotifier<AppPreferences> {
  AppPreferencesNotifier() : super(const AppPreferences());

  void update(AppPreferences Function(AppPreferences) fn) {
    state = fn(state);
  }
}

// ─── Tag Registry ─────────────────────────────────────────────────────────────

final allTagsProvider = Provider<List<String>>((ref) {
  final files = ref.watch(filesNotifierProvider);
  final tags = <String>{};
  for (final f in files) {
    tags.addAll(f.tags);
  }
  return tags.toList()..sort();
});

final tagFilterProvider = StateProvider<String?>((ref) => null);
