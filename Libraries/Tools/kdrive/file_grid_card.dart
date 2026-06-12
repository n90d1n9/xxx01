// lib/widgets/file_grid_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';
import '../utils/file_utils.dart';
import 'file_context_menu.dart';

class FileGridCard extends ConsumerWidget {
  final FileItem file;
  final VoidCallback onTap;
  const FileGridCard({super.key, required this.file, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(selectedFilesProvider.select((s) => s.contains(file.id)));
    final isSelectionMode = ref.watch(selectedFilesProvider).isNotEmpty;
    final isInfoFile = ref.watch(infoPanelFileProvider.select((f) => f?.id == file.id));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fileColor = file.isFolder
        ? (file.folderColor ?? const Color(0xFF5F6368))
        : FileUtils.getFileColor(file.type);

    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          ref.read(selectedFilesProvider.notifier).toggle(file.id);
        } else {
          onTap();
        }
      },
      onLongPress: () => ref.read(selectedFilesProvider.notifier).toggle(file.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : isInfoFile
                  ? colorScheme.secondaryContainer.withOpacity(0.4)
                  : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : isInfoFile
                    ? colorScheme.secondary.withOpacity(0.5)
                    : colorScheme.outlineVariant.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.08 : 0.04),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: fileColor.withOpacity(0.08),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    ),
                    child: Center(
                      child: file.isFolder
                          ? _FolderThumbnail(color: fileColor, file: file)
                          : _FileThumbnail(file: file, color: fileColor),
                    ),
                  ),
                  // Selection checkbox
                  Positioned(
                    top: 8, left: 8,
                    child: AnimatedOpacity(
                      opacity: isSelectionMode ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          color: isSelected ? colorScheme.primary : Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? colorScheme.primary : Colors.grey.shade400,
                            width: 2),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)],
                        ),
                        child: isSelected
                            ? Icon(Icons.check_rounded, size: 14, color: colorScheme.onPrimary)
                            : null,
                      ),
                    ),
                  ),
                  // Badges top-right
                  Positioned(
                    top: 6, right: 6,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (file.isShared)
                          Container(
                            margin: const EdgeInsets.only(right: 3),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.people_rounded,
                              size: 10, color: colorScheme.primary),
                          ),
                        if (file.isStarred)
                          Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade600),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Info row
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 7, 4, 7),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(file.name,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 1),
                        Text(
                          file.isFolder
                              ? (file.itemCount > 0
                                  ? '${file.itemCount} items'
                                  : FileUtils.formatDate(file.dateModified))
                              : file.displaySize,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  FileContextMenuButton(file: file),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FolderThumbnail extends StatelessWidget {
  final Color color;
  final FileItem file;
  const _FolderThumbnail({required this.color, required this.file});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64, height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 14,
            child: Container(
              width: 58, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.55),
                borderRadius: BorderRadius.circular(6)),
            ),
          ),
          Positioned(
            top: 10, left: 0,
            child: Container(
              width: 24, height: 9,
              decoration: BoxDecoration(
                color: color.withOpacity(0.55),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5))),
            ),
          ),
          Positioned(
            top: 19,
            child: Container(
              width: 58, height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5)),
              child: file.isShared
                  ? const Center(
                      child: Icon(Icons.people_rounded, color: Colors.white, size: 18))
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _FileThumbnail extends StatelessWidget {
  final FileItem file;
  final Color color;
  const _FileThumbnail({required this.file, required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(FileUtils.getFileIcon(file.type), size: 48, color: color);
  }
}
