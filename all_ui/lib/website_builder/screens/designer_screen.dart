import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/autosave_provider.dart';
import '../states/provider.dart';
import '../widgets/ai_assistant_fab.dart';
import '../widgets/animation_panel.dart';
import '../widgets/canvas_area.dart';
import '../widgets/code_panel.dart';
import '../widgets/component_palette.dart';
import '../widgets/component_tree_panel.dart';
import '../widgets/layers_panel.dart';
import '../widgets/modern_appbar.dart';
import '../widgets/properties_panel.dart';
import '../widgets/status_bar.dart';
import '../widgets/toolbar_panel.dart';

class DesignerScreen extends ConsumerWidget {
  const DesignerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(designerProvider);

    // Watch for auto-save
    ref.watch(autoSaveWatcherProvider);

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (event) => _handleKeyEvent(event, ref),
      child: Scaffold(
        backgroundColor:
            state.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        appBar: const ModernAppBar(),
        body: Row(
          children: [
            const ComponentPalette(),
            Expanded(
              child: Column(
                children: [
                  const ToolbarPanel(),
                  Expanded(child: const CanvasArea()),
                ],
              ),
            ),
            if (state.showAnimationPanel)
              const AnimationPanel()
            else
              const PropertiesPanel(),

            if (state.showPropertiesPanel) const PropertiesPanel(),
            if (state.showComponentTree) const ComponentTreePanel(),
            if (state.showLayersPanel) const LayersPanel(),
            if (state.showCodePanel) const CodePanel(),
          ],
        ),
        //floatingActionButton: const CloudSyncButton(),
        floatingActionButton:
            state.aiAssistEnabled ? const AIAssistantFAB() : null,
        bottomNavigationBar: const StatusBar(),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event, WidgetRef ref) {
    if (event is! KeyDownEvent) return;
    final notifier = ref.read(designerProvider.notifier);
    final isCtrl = HardwareKeyboard.instance.isControlPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;

    if (event.logicalKey == LogicalKeyboardKey.delete) {
      notifier.deleteSelectedComponents();
    } else if (isCtrl) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.keyZ:
          notifier.undo();
          break;
        case LogicalKeyboardKey.keyY:
          notifier.redo();
          break;
        case LogicalKeyboardKey.keyC:
          notifier.copyComponents();
          break;
        case LogicalKeyboardKey.keyV:
          notifier.pasteComponents();
          break;
        case LogicalKeyboardKey.keyD:
          notifier.duplicateComponents();
          break;
        case LogicalKeyboardKey.keyG:
          notifier.groupSelected();
          break;
        case LogicalKeyboardKey.keyS:
          ref.read(designerProvider.notifier).saveToCloud('Manual Save');
          break;

        case LogicalKeyboardKey.keyZ:
          notifier.undo();
          break;
        case LogicalKeyboardKey.keyY:
          notifier.redo();
          break;

        case LogicalKeyboardKey.keyV:
          notifier.pasteComponents();
          break;

        case LogicalKeyboardKey.keyA:
          notifier.selectAll();
          break;
        case LogicalKeyboardKey.keyG:
          notifier.groupSelected();
          break;
        case LogicalKeyboardKey.keyS:
          _saveProject(ref);
          break;
        case LogicalKeyboardKey.keyN:
          notifier.newProject();
          break;
      }
    } else if (isShift) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.keyG:
          notifier.ungroupSelected();
          break;
      }
    }
  }

  void _saveProject(WidgetRef ref) {
    final json = ref.read(designerProvider.notifier).saveProject();
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(content: Text('Project saved to clipboard!')),
    );
  }
}
