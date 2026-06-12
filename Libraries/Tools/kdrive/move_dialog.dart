// lib/widgets/move_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';
import '../utils/file_utils.dart';

class MoveDialog extends ConsumerStatefulWidget {
  final List<String> fileIds;
  const MoveDialog({super.key, required this.fileIds});

  @override
  ConsumerState<MoveDialog> createState() => _MoveDialogState();
}

class _MoveDialogState extends ConsumerState<MoveDialog> {
  String? _selectedFolderId;
  String? _browseFolderId; // null = root

  @override
  Widget build(BuildContext context) {
    final allFiles = ref.watch(filesNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Folders visible at current browse level (excluding moved files)
    final folders = allFiles
        .where((f) =>
            f.isFolder &&
            f.parentId == _browseFolderId &&
            !f.isTrashed &&
            !widget.fileIds.contains(f.id))
        .toList();

    // Build breadcrumb for browse path
    List<FileItem?> crumbs = [null];
    if (_browseFolderId != null) {
      String? id = _browseFolderId;
      final trail = <FileItem>[];
      while (id != null) {
        final f = allFiles.firstWhere((x) => x.id == id,
            orElse: () => FileItem(id: id!, name: '?', type: FileType.folder,
                dateModified: DateTime.now(), dateCreated: DateTime.now()));
        trail.insert(0, f);
        id = f.parentId;
      }
      crumbs = [null, ...trail];
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Move to',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),

              // Breadcrumb
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < crumbs.length; i++) ...[
                      if (i > 0)
                        Icon(Icons.chevron_right_rounded, size: 14,
                          color: colorScheme.onSurfaceVariant),
                      GestureDetector(
                        onTap: () => setState(() {
                          _browseFolderId = crumbs[i]?.id;
                          _selectedFolderId = crumbs[i]?.id;
                        }),
                        child: Text(
                          i == 0 ? 'My Drive' : crumbs[i]!.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: i == crumbs.length - 1
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: i == crumbs.length - 1 ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Expanded(
                child: folders.isEmpty
                    ? Center(
                        child: Text('No subfolders here',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                      )
                    : ListView.builder(
                        itemCount: folders.length,
                        itemBuilder: (_, i) {
                          final folder = folders[i];
                          final isSelected = _selectedFolderId == folder.id;
                          final fColor = folder.folderColor ?? FileUtils.getFileColor(FileType.folder);
                          return InkWell(
                            onTap: () => setState(() => _selectedFolderId = folder.id),
                            onDoubleTap: () => setState(() {
                              _browseFolderId = folder.id;
                              _selectedFolderId = folder.id;
                            }),
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? colorScheme.primaryContainer.withOpacity(0.5) : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.folder_rounded, color: fColor, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(folder.name,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        fontSize: 14,
                                      )),
                                  ),
                                  Icon(Icons.chevron_right_rounded, size: 16,
                                    color: colorScheme.onSurfaceVariant),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Selected destination
              if (_selectedFolderId != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.folder_rounded,
                        color: colorScheme.primary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Moving to: ${allFiles.firstWhere((f) => f.id == _selectedFolderId).name}',
                          style: TextStyle(fontSize: 12, color: colorScheme.primary,
                            fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _selectedFolderId == null
                        ? null
                        : () {
                            for (final id in widget.fileIds) {
                              ref.read(filesNotifierProvider.notifier)
                                  .moveFile(id, _selectedFolderId);
                            }
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Moved ${widget.fileIds.length} item${widget.fileIds.length > 1 ? 's' : ''}'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ));
                          },
                    child: const Text('Move here'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
