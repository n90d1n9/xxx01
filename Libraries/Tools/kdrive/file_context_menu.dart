// lib/widgets/file_context_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';
import 'share_dialog.dart';
import 'move_dialog.dart';
import 'tag_manager_sheet.dart';

class FileContextMenuButton extends ConsumerWidget {
  final FileItem file;
  const FileContextMenuButton({super.key, required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.zero,
      itemBuilder: (context) => [
        PopupMenuItem(value: 'info',
          child: _MenuRow(Icons.info_outline_rounded, 'File info')),
        PopupMenuItem(value: 'open',
          child: _MenuRow(Icons.open_in_new_rounded, 'Open')),
        const PopupMenuDivider(),
        PopupMenuItem(value: 'star',
          child: _MenuRow(
            file.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
            file.isStarred ? 'Remove star' : 'Add to starred',
            color: file.isStarred ? Colors.amber : null,
          )),
        PopupMenuItem(value: 'share',
          child: _MenuRow(Icons.share_rounded, 'Share')),
        PopupMenuItem(value: 'download',
          child: _MenuRow(Icons.download_rounded, 'Download')),
        PopupMenuItem(value: 'rename',
          child: _MenuRow(Icons.drive_file_rename_outline_rounded, 'Rename')),
        PopupMenuItem(value: 'move',
          child: _MenuRow(Icons.drive_file_move_rounded, 'Move to')),
        PopupMenuItem(value: 'copy',
          child: _MenuRow(Icons.copy_rounded, 'Make a copy')),
        PopupMenuItem(value: 'tags',
          child: _MenuRow(Icons.tag_rounded, 'Manage tags')),
        const PopupMenuDivider(),
        PopupMenuItem(value: 'delete',
          child: _MenuRow(Icons.delete_outline_rounded, 'Move to trash',
            color: Colors.red.shade600)),
      ],
      onSelected: (value) => _handleAction(context, ref, value),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'info':
        ref.read(infoPanelFileProvider.notifier).state = file;
        ref.read(isInfoPanelOpenProvider.notifier).state = true;
        break;
      case 'star':
        ref.read(filesNotifierProvider.notifier).toggleStar(file.id);
        break;
      case 'share':
        showDialog(context: context,
          builder: (_) => ShareDialog(file: file));
        break;
      case 'rename':
        _showRenameDialog(context, ref);
        break;
      case 'move':
        showDialog(context: context,
          builder: (_) => MoveDialog(fileIds: [file.id]));
        break;
      case 'tags':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (_) => TagManagerSheet(file: file),
        );
        break;
      case 'delete':
        ref.read(filesNotifierProvider.notifier).trashFile(file.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('"${file.name}" moved to trash'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => ref.read(filesNotifierProvider.notifier).restoreFile(file.id),
          ),
        ));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$action — coming soon'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
    }
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: file.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            labelText: 'Name',
          ),
          onSubmitted: (_) {
            ref.read(filesNotifierProvider.notifier).renameFile(file.id, controller.text.trim());
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(filesNotifierProvider.notifier).renameFile(file.id, name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _MenuRow(this.icon, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Icon(icon, size: 18, color: effectiveColor),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: effectiveColor, fontSize: 14)),
      ],
    );
  }
}
