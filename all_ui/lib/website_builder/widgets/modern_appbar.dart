import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../states/component_provider.dart';
import '../states/provider.dart';

class ModernAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ModernAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(designerProvider);
    final notifier = ref.read(designerProvider.notifier);
    final canUndo = notifier.canUndo;
    final canRedo = notifier.canRedo;
    final componentCount = ref.watch(componentCountProvider);

    return AppBar(
      elevation: 0,
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient:
              state.isDarkMode
                  ? LinearGradient(
                    colors: [Colors.grey.shade900, Colors.grey.shade800],
                  )
                  : const LinearGradient(colors: [Colors.white, Colors.white]),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, size: 20, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Ultra Designer Pro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Text(state.currentProjectName, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 12),
          _buildStatChip('Components', componentCount.toString()),
          const SizedBox(width: 8),
          _buildStatChip(
            'Selected',
            state.selectedComponentIds.length.toString(),
          ),
          if (state.hasUnsavedChanges) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.orange),
                  SizedBox(width: 6),
                  Text(
                    'Unsaved',
                    style: TextStyle(fontSize: 11, color: Colors.orange),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.file_copy),
          onPressed: notifier.newProject,
          tooltip: 'New Project',
        ),
        IconButton(
          icon: const Icon(Icons.folder_open),
          onPressed: () => _showLoadDialog(context, ref),
          tooltip: 'Open',
        ),
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () => _saveProject(ref),
          tooltip: 'Save',
        ),
        const VerticalDivider(),
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: canUndo ? notifier.undo : null,
          tooltip: 'Undo',
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: canRedo ? notifier.redo : null,
          tooltip: 'Redo',
        ),
        const VerticalDivider(),
        IconButton(
          icon: Icon(state.showGrid ? Icons.grid_on : Icons.grid_off),
          onPressed: notifier.toggleGrid,
          tooltip: 'Grid',
        ),
        IconButton(
          icon: Icon(
            state.showComponentTree
                ? Icons.account_tree
                : Icons.account_tree_outlined,
          ),
          onPressed: notifier.toggleComponentTree,
          tooltip: 'Tree',
        ),
        IconButton(
          icon: Icon(state.showCodePanel ? Icons.code : Icons.code_outlined),
          onPressed: notifier.toggleCodePanel,
          tooltip: 'Code',
        ),
        const VerticalDivider(),
        _buildResponsiveButtons(ref),
        const VerticalDivider(),
        IconButton(
          icon: Icon(state.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: notifier.toggleDarkMode,
          tooltip: 'Theme',
        ),
        IconButton(
          icon: Icon(
            state.aiAssistEnabled ? Icons.auto_fix_high : Icons.auto_fix_off,
          ),
          onPressed: notifier.toggleAIAssist,
          tooltip: 'AI',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveButtons(WidgetRef ref) {
    final state = ref.watch(designerProvider);
    final notifier = ref.read(designerProvider.notifier);

    return Row(
      children:
          ResponsiveBreakpoint.values.map((bp) {
            final isActive = state.currentBreakpoint == bp;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                onTap: () => notifier.setBreakpoint(bp),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blue.shade100 : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getBreakpointIcon(bp),
                    size: 18,
                    color: isActive ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  IconData _getBreakpointIcon(ResponsiveBreakpoint bp) {
    switch (bp) {
      case ResponsiveBreakpoint.mobile:
        return Icons.phone_android;
      case ResponsiveBreakpoint.tablet:
        return Icons.tablet_mac;
      case ResponsiveBreakpoint.desktop:
        return Icons.desktop_windows;
      case ResponsiveBreakpoint.wide:
        return Icons.tv;
    }
  }

  void _saveProject(WidgetRef ref) {
    final json = ref.read(designerProvider.notifier).saveProject();
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(
        content: Text('Project saved to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLoadDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Load Project'),
            content: SizedBox(
              width: 500,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Paste JSON',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(designerProvider.notifier)
                      .loadProject(controller.text);
                  Navigator.pop(ctx);
                },
                child: const Text('Load'),
              ),
            ],
          ),
    );
  }
}
