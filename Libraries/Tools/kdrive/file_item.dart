// lib/models/file_item.dart
import 'package:flutter/material.dart';

enum FileType {
  folder,
  document,
  spreadsheet,
  presentation,
  image,
  video,
  audio,
  pdf,
  archive,
  code,
  other,
}

enum ViewMode { grid, list, detail }
enum SortBy { name, dateModified, size, type }
enum SortOrder { ascending, descending }

class FileItem {
  final String id;
  final String name;
  final FileType type;
  final int? sizeBytes;
  final DateTime dateModified;
  final DateTime dateCreated;
  final String? parentId;
  final String? thumbnailUrl;
  final bool isStarred;
  final bool isShared;
  final String? owner;
  final Color? folderColor;
  final List<String> tags;
  final bool isTrashed;
  final DateTime? trashedAt;
  final String? description;
  final List<String> sharedWith;
  final DateTime? lastOpenedAt;
  final int itemCount; // for folders: number of direct children

  const FileItem({
    required this.id,
    required this.name,
    required this.type,
    this.sizeBytes,
    required this.dateModified,
    required this.dateCreated,
    this.parentId,
    this.thumbnailUrl,
    this.isStarred = false,
    this.isShared = false,
    this.owner,
    this.folderColor,
    this.tags = const [],
    this.isTrashed = false,
    this.trashedAt,
    this.description,
    this.sharedWith = const [],
    this.lastOpenedAt,
    this.itemCount = 0,
  });

  bool get isFolder => type == FileType.folder;

  String get extension {
    if (isFolder) return '';
    final parts = name.split('.');
    return parts.length > 1 ? '.${parts.last.toLowerCase()}' : '';
  }

  String get displaySize {
    if (sizeBytes == null || isFolder) return '--';
    if (sizeBytes! < 1024) return '${sizeBytes} B';
    if (sizeBytes! < 1024 * 1024) return '${(sizeBytes! / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes! < 1024 * 1024 * 1024) return '${(sizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(sizeBytes! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  int get daysUntilPermanentDelete {
    if (trashedAt == null) return 30;
    final diff = DateTime.now().difference(trashedAt!).inDays;
    return (30 - diff).clamp(0, 30);
  }

  FileItem copyWith({
    String? id,
    String? name,
    FileType? type,
    int? sizeBytes,
    DateTime? dateModified,
    DateTime? dateCreated,
    String? parentId,
    String? thumbnailUrl,
    bool? isStarred,
    bool? isShared,
    String? owner,
    Color? folderColor,
    List<String>? tags,
    bool? isTrashed,
    DateTime? trashedAt,
    String? description,
    List<String>? sharedWith,
    DateTime? lastOpenedAt,
    int? itemCount,
  }) {
    return FileItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      dateModified: dateModified ?? this.dateModified,
      dateCreated: dateCreated ?? this.dateCreated,
      parentId: parentId ?? this.parentId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isStarred: isStarred ?? this.isStarred,
      isShared: isShared ?? this.isShared,
      owner: owner ?? this.owner,
      folderColor: folderColor ?? this.folderColor,
      tags: tags ?? this.tags,
      isTrashed: isTrashed ?? this.isTrashed,
      trashedAt: trashedAt ?? this.trashedAt,
      description: description ?? this.description,
      sharedWith: sharedWith ?? this.sharedWith,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}

class UploadTask {
  final String id;
  final String fileName;
  final FileType fileType;
  final double progress; // 0.0 - 1.0
  final bool isComplete;
  final bool isFailed;
  final String? targetFolderId;

  const UploadTask({
    required this.id,
    required this.fileName,
    required this.fileType,
    this.progress = 0.0,
    this.isComplete = false,
    this.isFailed = false,
    this.targetFolderId,
  });

  UploadTask copyWith({
    double? progress,
    bool? isComplete,
    bool? isFailed,
  }) => UploadTask(
    id: id, fileName: fileName, fileType: fileType,
    targetFolderId: targetFolderId,
    progress: progress ?? this.progress,
    isComplete: isComplete ?? this.isComplete,
    isFailed: isFailed ?? this.isFailed,
  );
}
