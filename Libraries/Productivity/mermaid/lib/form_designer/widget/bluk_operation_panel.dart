import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/form_theme.dart';
import '../states/bulk_operation_manager.dart';
import '../states/form_field_provider.dart';
import '../states/selection_provider.dart';

class BulkOperationsPanel extends ConsumerWidget {
  final FormTheme? theme;
  const BulkOperationsPanel({super.key, this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(selectionManagerProvider);
    final fields = ref.watch(formFieldsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: Colors.blue.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          const Icon(Icons.layers, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Text(
            '${selectionState.count} field${selectionState.count != 1 ? 's' : ''} selected',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          const VerticalDivider(),
          const SizedBox(width: 16),
          // Bulk actions
          _BulkActionButton(
            icon: Icons.content_copy,
            label: 'Duplicate',
            onPressed: () {
              BulkOperationsManager.duplicateSelected(
                ref,
                fields,
                selectionState.selectedIds,
              );
            },
          ),
          const SizedBox(width: 8),
          _BulkActionButton(
            icon: Icons.delete,
            label: 'Delete',
            color: Colors.red,
            onPressed: () {
              BulkOperationsManager.deleteSelected(
                ref,
                selectionState.selectedIds,
              );
            },
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: const [
                  Icon(Icons.more_horiz, size: 16),
                  SizedBox(width: 4),
                  Text('More', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_required',
                child: Row(
                  children: [
                    Icon(Icons.star, size: 16),
                    SizedBox(width: 8),
                    Text('Mark as Required'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'mark_optional',
                child: Row(
                  children: [
                    Icon(Icons.star_border, size: 16),
                    SizedBox(width: 8),
                    Text('Mark as Optional'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'invert',
                child: Row(
                  children: [
                    Icon(Icons.flip, size: 16),
                    SizedBox(width: 8),
                    Text('Invert Selection'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'deselect',
                child: Row(
                  children: [
                    Icon(Icons.clear, size: 16),
                    SizedBox(width: 8),
                    Text('Deselect All'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'mark_required':
                  BulkOperationsManager.bulkUpdateRequired(
                    ref,
                    fields,
                    selectionState.selectedIds,
                    true,
                  );
                  break;
                case 'mark_optional':
                  BulkOperationsManager.bulkUpdateRequired(
                    ref,
                    fields,
                    selectionState.selectedIds,
                    false,
                  );
                  break;
                case 'invert':
                  ref
                      .read(selectionManagerProvider.notifier)
                      .invertSelection(fields);
                  break;
                case 'deselect':
                  ref.read(selectionManagerProvider.notifier).clearSelection();
                  break;
              }
            },
          ),
          const Spacer(),
          TextButton.icon(
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Clear Selection'),
            onPressed: () {
              ref.read(selectionManagerProvider.notifier).clearSelection();
            },
          ),
        ],
      ),
    );
  }
}

class _BulkActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _BulkActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
