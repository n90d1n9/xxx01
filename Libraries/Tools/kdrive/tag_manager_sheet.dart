// lib/widgets/tag_manager_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/file_provider.dart';
import '../utils/file_utils.dart';
import '../models/file_item.dart';

class TagManagerSheet extends ConsumerStatefulWidget {
  final FileItem file;
  const TagManagerSheet({super.key, required this.file});

  @override
  ConsumerState<TagManagerSheet> createState() => _TagManagerSheetState();
}

class _TagManagerSheetState extends ConsumerState<TagManagerSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTags = ref.watch(allTagsProvider);
    final file = ref.watch(filesNotifierProvider)
        .firstWhere((f) => f.id == widget.file.id, orElse: () => widget.file);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final suggestedTags = allTags.where((t) => !file.tags.contains(t)).toList();

    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Text('Manage tags', style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700)),
          Text(file.name,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 16),

          // Current tags
          if (file.tags.isNotEmpty) ...[
            Text('Current tags',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: file.tags.map((tag) => _TagChip(
                tag: tag, 
                onDelete: () => ref.read(filesNotifierProvider.notifier)
                    .removeTag(file.id, tag),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Add new tag
          Text('Add tag',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Enter tag name...',
                    prefixIcon: const Icon(Icons.tag_rounded, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (v) => _addTag(v, file),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => _addTag(_controller.text, file),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Add'),
              ),
            ],
          ),

          // Suggested tags
          if (suggestedTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Suggested',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: suggestedTags.take(12).map((tag) => ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 14),
                label: Text(tag, style: const TextStyle(fontSize: 12)),
                onPressed: () => ref.read(filesNotifierProvider.notifier)
                    .addTag(file.id, tag),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              )).toList(),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _addTag(String tag, FileItem file) {
    final trimmed = tag.trim().toLowerCase().replaceAll(' ', '-');
    if (trimmed.isEmpty) return;
    ref.read(filesNotifierProvider.notifier).addTag(file.id, trimmed);
    _controller.clear();
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback onDelete;
  const _TagChip({required this.tag, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tag_rounded, size: 12, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(tag, style: TextStyle(
            fontSize: 12, color: colorScheme.primary, fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close_rounded, size: 14, color: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
