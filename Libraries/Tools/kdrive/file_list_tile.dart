// lib/widgets/file_list_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';
import '../utils/file_utils.dart';
import 'file_context_menu.dart';

class FileListTile extends ConsumerWidget {
  final FileItem file;
  final VoidCallback onTap;

  const FileListTile({super.key, required this.file, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(selectedFilesProvider.select((s) => s.contains(file.id)));
    final selectedCount = ref.watch(selectedFilesProvider).length;
    final isSelectionMode = selectedCount > 0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fileColor = file.isFolder
        ? (file.folderColor ?? const Color(0xFF5F6368))
        : FileUtils.getFileColor(file.type);

    return InkWell(
      onTap: () {
        if (isSelectionMode) {
          ref.read(selectedFilesProvider.notifier).toggle(file.id);
        } else {
          onTap();
        }
      },
      onLongPress: () => ref.read(selectedFilesProvider.notifier).toggle(file.id),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer.withOpacity(0.6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colorScheme.primary.withOpacity(0.4) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Leading icon / checkbox
            GestureDetector(
              onTap: () => ref.read(selectedFilesProvider.notifier).toggle(file.id),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelectionMode
                    ? Container(
                        key: const ValueKey('checkbox'),
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: isSelected ? colorScheme.primary : colorScheme.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSelected ? Icons.check_rounded : Icons.circle_outlined,
                          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      )
                    : Container(
                        key: const ValueKey('icon'),
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: fileColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          FileUtils.getFileIcon(file.type),
                          color: fileColor,
                          size: 20,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // File name and meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          file.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (file.isStarred)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade600),
                        ),
                      if (file.isShared)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.people_rounded, size: 14, color: colorScheme.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${FileUtils.formatDate(file.dateModified)}${file.isFolder ? '' : ' · ${file.displaySize}'}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            FileContextMenuButton(file: file),
          ],
        ),
      ),
    );
  }
}
