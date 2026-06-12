// lib/widgets/file_detail_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';
import '../utils/file_utils.dart';
import 'file_context_menu.dart';

class FileDetailRow extends ConsumerWidget {
  final FileItem file;
  final VoidCallback onTap;

  const FileDetailRow({super.key, required this.file, required this.onTap});

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: isSelected ? colorScheme.primaryContainer.withOpacity(0.4) : Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Checkbox / Icon
                  GestureDetector(
                    onTap: () => ref.read(selectedFilesProvider.notifier).toggle(file.id),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: isSelectionMode
                          ? SizedBox(
                              key: const ValueKey('cb'),
                              width: 32, height: 32,
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (_) => ref.read(selectedFilesProvider.notifier).toggle(file.id),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            )
                          : Container(
                              key: const ValueKey('ic'),
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: fileColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(FileUtils.getFileIcon(file.type), color: fileColor, size: 18),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name column
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            file.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (file.isStarred)
                          Icon(Icons.star_rounded, size: 13, color: Colors.amber.shade600),
                        if (file.isShared)
                          Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: Icon(Icons.people_rounded, size: 13, color: colorScheme.primary),
                          ),
                      ],
                    ),
                  ),

                  // Owner column
                  Expanded(
                    flex: 2,
                    child: Text(
                      file.owner == 'me' ? 'Me' : (file.owner ?? '--'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Date column
                  Expanded(
                    flex: 2,
                    child: Text(
                      FileUtils.formatDate(file.dateModified),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  // Size column
                  SizedBox(
                    width: 72,
                    child: Text(
                      file.displaySize,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),

                  const SizedBox(width: 4),
                  FileContextMenuButton(file: file),
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}

class FileDetailHeader extends StatelessWidget {
  const FileDetailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.4),
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('Name',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600,
              )),
          ),
          Expanded(
            flex: 2,
            child: Text('Owner',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600,
              )),
          ),
          Expanded(
            flex: 2,
            child: Text('Last modified',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600,
              )),
          ),
          SizedBox(
            width: 72,
            child: Text('Size',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
