import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/enums.dart';
import '../states/component_provider.dart';
import '../states/provider.dart';

class DesignerAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DesignerAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(designerProvider);
    final notifier = ref.read(designerProvider.notifier);
    final canUndo = notifier.canUndo;
    final canRedo = notifier.canRedo;
    final componentCount = ref.watch(componentCountProvider);
    final selectedCount = ref.watch(selectedCountProvider);

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Website Designer Pro - Riverpod Advanced'),
          Text(
            'Components: $componentCount | Selected: $selectedCount',
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
      actions: [
        // Collaboration Status
        if (state.collaborationStatus == CollaborationStatus.connected)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              avatar: const Icon(Icons.people, size: 16),
              label: Text('${state.collaborators.length}'),
              backgroundColor: Colors.green,
            ),
          ),

        // Undo/Redo
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: canUndo ? notifier.undo : null,
          tooltip: 'Undo (Ctrl+Z)',
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: canRedo ? notifier.redo : null,
          tooltip: 'Redo (Ctrl+Y)',
        ),
        const VerticalDivider(),

        // Edit Actions
        IconButton(
          icon: const Icon(Icons.content_copy),
          onPressed: selectedCount > 0 ? notifier.copyComponents : null,
          tooltip: 'Copy',
        ),
        IconButton(
          icon: const Icon(Icons.content_paste),
          onPressed: state.clipboard.isNotEmpty
              ? notifier.pasteComponents
              : null,
          tooltip: 'Paste',
        ),
        IconButton(
          icon: const Icon(Icons.control_point_duplicate),
          onPressed: selectedCount > 0 ? notifier.duplicateComponents : null,
          tooltip: 'Duplicate',
        ),
        const VerticalDivider(),

        // View Options
        IconButton(
          icon: Icon(state.showGrid ? Icons.grid_on : Icons.grid_off),
          onPressed: notifier.toggleGrid,
          tooltip: 'Toggle Grid',
        ),
        IconButton(
          icon: Icon(
            state.showComponentTree
                ? Icons.account_tree
                : Icons.account_tree_outlined,
          ),
          onPressed: notifier.toggleComponentTree,
          tooltip: 'Component Tree',
        ),
        IconButton(
          icon: Icon(
            state.showAnimationPanel
                ? Icons.animation
                : Icons.animation_outlined,
          ),
          onPressed: notifier.toggleAnimationPanel,
          tooltip: 'Animations',
        ),
        const VerticalDivider(),

        // Theme
        IconButton(
          icon: Icon(state.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: notifier.toggleDarkMode,
          tooltip: 'Toggle Theme',
        ),

        // Code Generator
        IconButton(
          icon: const Icon(Icons.code),
          onPressed: () => _showCodeDialog(context, ref),
          tooltip: 'Generate Code',
        ),

        // Delete
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: selectedCount > 0
              ? notifier.deleteSelectedComponents
              : null,
          tooltip: 'Delete',
          color: Colors.red,
        ),
      ],
    );
  }

  void _showCodeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const Text(''), //CodeGeneratorDialog(),
    );
  }
}
