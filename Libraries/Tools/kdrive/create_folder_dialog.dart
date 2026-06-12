// lib/widgets/create_folder_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';
import '../utils/file_utils.dart';

class CreateFolderDialog extends ConsumerStatefulWidget {
  const CreateFolderDialog({super.key});

  @override
  ConsumerState<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends ConsumerState<CreateFolderDialog> {
  final _nameController = TextEditingController(text: 'New folder');
  Color _selectedColor = FileUtils.folderColors.last;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('New folder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Folder name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: Icon(Icons.folder_rounded, color: _selectedColor),
            ),
            onSubmitted: (_) => _create(context),
          ),
          const SizedBox(height: 20),
          Text('Color', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FileUtils.folderColors.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? colorScheme.onSurface : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                        : [],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.folder_rounded, color: _selectedColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _nameController.text.isEmpty ? 'New folder' : _nameController.text,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => _create(context), child: const Text('Create')),
      ],
    );
  }

  void _create(BuildContext context) {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final currentFolderId = ref.read(currentFolderIdProvider);
    final newFolder = FileItem(
      id: 'folder-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: FileType.folder,
      dateModified: DateTime.now(),
      dateCreated: DateTime.now(),
      parentId: currentFolderId,
      folderColor: _selectedColor,
      owner: 'me',
      itemCount: 0,
    );
    ref.read(filesNotifierProvider.notifier).addFile(newFolder);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('"$name" created'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}
