// lib/utils/file_utils.dart
import 'package:flutter/material.dart';
import '../models/file_item.dart';

class FileUtils {
  static Color getFileColor(FileType type) {
    switch (type) {
      case FileType.folder:        return const Color(0xFF5F6368);
      case FileType.document:      return const Color(0xFF4285F4);
      case FileType.spreadsheet:   return const Color(0xFF34A853);
      case FileType.presentation:  return const Color(0xFFFBBC04);
      case FileType.image:         return const Color(0xFF9C27B0);
      case FileType.video:         return const Color(0xFFEA4335);
      case FileType.audio:         return const Color(0xFFFF6D00);
      case FileType.pdf:           return const Color(0xFFEA4335);
      case FileType.archive:       return const Color(0xFF795548);
      case FileType.code:          return const Color(0xFF009688);
      case FileType.other:         return const Color(0xFF9E9E9E);
    }
  }

  static IconData getFileIcon(FileType type) {
    switch (type) {
      case FileType.folder:        return Icons.folder_rounded;
      case FileType.document:      return Icons.description_rounded;
      case FileType.spreadsheet:   return Icons.table_chart_rounded;
      case FileType.presentation:  return Icons.slideshow_rounded;
      case FileType.image:         return Icons.image_rounded;
      case FileType.video:         return Icons.videocam_rounded;
      case FileType.audio:         return Icons.audiotrack_rounded;
      case FileType.pdf:           return Icons.picture_as_pdf_rounded;
      case FileType.archive:       return Icons.archive_rounded;
      case FileType.code:          return Icons.code_rounded;
      case FileType.other:         return Icons.insert_drive_file_rounded;
    }
  }

  static String getFileTypeName(FileType type) {
    switch (type) {
      case FileType.folder:        return 'Folder';
      case FileType.document:      return 'Document';
      case FileType.spreadsheet:   return 'Spreadsheet';
      case FileType.presentation:  return 'Presentation';
      case FileType.image:         return 'Image';
      case FileType.video:         return 'Video';
      case FileType.audio:         return 'Audio';
      case FileType.pdf:           return 'PDF';
      case FileType.archive:       return 'Archive';
      case FileType.code:          return 'Code / Script';
      case FileType.other:         return 'File';
    }
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60)  return 'Just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)    return '${diff.inHours}h ago';
    if (diff.inDays == 1)     return 'Yesterday';
    if (diff.inDays < 7)      return '${diff.inDays} days ago';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    if (date.year == now.year) return '${months[date.month - 1]} ${date.day}';
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String formatFullDate(DateTime date) {
    const months = ['January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    return '${months[date.month-1]} ${date.day}, ${date.year} · '
           '${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
  }

  static Color typeFilterColor(FileType type) => getFileColor(type);

  static final List<FileType> filterableTypes = [
    FileType.folder,
    FileType.document,
    FileType.spreadsheet,
    FileType.presentation,
    FileType.image,
    FileType.video,
    FileType.pdf,
    FileType.audio,
    FileType.code,
    FileType.archive,
  ];

  static final List<Color> folderColors = [
    const Color(0xFF4285F4), // blue
    const Color(0xFF34A853), // green
    const Color(0xFFFBBC04), // yellow
    const Color(0xFFEA4335), // red
    const Color(0xFF9C27B0), // purple
    const Color(0xFFFF6D00), // orange
    const Color(0xFF009688), // teal
    const Color(0xFF795548), // brown
    const Color(0xFF607D8B), // blue-grey
    const Color(0xFF5F6368), // default grey
  ];
}
