// lib/widgets/view_controls_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';
import 'move_dialog.dart';
import 'share_dialog.dart';

class ViewControlsBar extends ConsumerWidget {
  const ViewControlsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(viewModeProvider);
    final sortBy = ref.watch(sortByProvider);
    final sortOrder = ref.watch(sortOrderProvider);
    final selectedIds = ref.watch(selectedFilesProvider);
    final allFiles = ref.watch(filesNotifierProvider);
    final isInfoOpen = ref.watch(isInfoPanelOpenProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (selectedIds.isNotEmpty) {
      return _SelectionBar(selectedIds: selectedIds, allFiles: allFiles);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          // Sort dropdown
          PopupMenuButton<SortBy>(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sort_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(_sortLabel(sortBy),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant)),
                Icon(Icons.arrow_drop_down_rounded, size: 18, color: colorScheme.onSurfaceVariant),
              ],
            ),
            itemBuilder: (_) => SortBy.values.map((s) => PopupMenuItem(
              value: s,
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    child: sortBy == s
                        ? Icon(Icons.check_rounded, size: 16, color: colorScheme.primary)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(_sortLabel(s)),
                ],
              ),
            )).toList(),
            onSelected: (s) => ref.read(sortByProvider.notifier).state = s,
          ),

          // Sort order arrow
          IconButton(
            onPressed: () {
              ref.read(sortOrderProvider.notifier).state =
                  sortOrder == SortOrder.ascending ? SortOrder.descending : SortOrder.ascending;
            },
            icon: AnimatedRotation(
              turns: sortOrder == SortOrder.descending ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.arrow_upward_rounded, size: 16,
                color: colorScheme.onSurfaceVariant),
            ),
            visualDensity: VisualDensity.compact,
            tooltip: sortOrder == SortOrder.ascending ? 'Ascending' : 'Descending',
          ),

          const Spacer(),

          // Info panel toggle
          Tooltip(
            message: 'File info',
            child: InkWell(
              onTap: () {
                ref.read(isInfoPanelOpenProvider.notifier).state = !isInfoOpen;
              },
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isInfoOpen
                      ? colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline_rounded, size: 18,
                  color: isInfoOpen ? colorScheme.primary : colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // View mode toggles
          _ViewToggle(icon: Icons.grid_view_rounded, mode: ViewMode.grid,
            current: viewMode, tooltip: 'Grid view'),
          const SizedBox(width: 4),
          _ViewToggle(icon: Icons.view_list_rounded, mode: ViewMode.list,
            current: viewMode, tooltip: 'List view'),
          const SizedBox(width: 4),
          _ViewToggle(icon: Icons.table_rows_rounded, mode: ViewMode.detail,
            current: viewMode, tooltip: 'Detail view'),
        ],
      ),
    );
  }

  String _sortLabel(SortBy s) {
    switch (s) {
      case SortBy.name:         return 'Name';
      case SortBy.dateModified: return 'Modified';
      case SortBy.size:         return 'Size';
      case SortBy.type:         return 'Type';
    }
  }
}

class _ViewToggle extends ConsumerWidget {
  final IconData icon;
  final ViewMode mode;
  final ViewMode current;
  final String tooltip;
  const _ViewToggle({required this.icon, required this.mode,
    required this.current, required this.tooltip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = current == mode;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => ref.read(viewModeProvider.notifier).state = mode,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18,
            color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _SelectionBar extends ConsumerWidget {
  final Set<String> selectedIds;
  final List<FileItem> allFiles;
  const _SelectionBar({required this.selectedIds, required this.allFiles});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedFiles = allFiles.where((f) => selectedIds.contains(f.id)).toList();
    final hasOnlyFolders = selectedFiles.every((f) => f.isFolder);
    final currentFiles = ref.watch(currentFolderFilesProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: colorScheme.primaryContainer.withOpacity(0.5),
      child: Row(
        children: [
          IconButton(
            onPressed: () => ref.read(selectedFilesProvider.notifier).clearAll(),
            icon: const Icon(Icons.close_rounded),
            visualDensity: VisualDensity.compact,
          ),
          Text('${selectedIds.length} selected',
            style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.primary)),

          // Select all
          TextButton(
            onPressed: () => ref.read(selectedFilesProvider.notifier)
                .selectAll(currentFiles.map((f) => f.id).toList()),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: const Text('All', style: TextStyle(fontSize: 12)),
          ),

          const Spacer(),

          if (!hasOnlyFolders)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Download',
              visualDensity: VisualDensity.compact,
            ),
          IconButton(
            onPressed: () {
              if (selectedFiles.length == 1) {
                showDialog(context: context,
                  builder: (_) => ShareDialog(file: selectedFiles.first));
              }
            },
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share',
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: () {
              showDialog(context: context,
                builder: (_) => MoveDialog(fileIds: selectedIds.toList()));
            },
            icon: const Icon(Icons.drive_file_move_rounded),
            tooltip: 'Move',
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: () {
              for (final id in selectedIds) {
                ref.read(filesNotifierProvider.notifier).trashFile(id);
              }
              final count = selectedIds.length;
              ref.read(selectedFilesProvider.notifier).clearAll();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$count item${count > 1 ? 's' : ''} moved to trash'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ));
            },
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600),
            tooltip: 'Move to trash',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
