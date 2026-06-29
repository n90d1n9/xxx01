import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/command.dart';
import '../schema/node/node_type.dart';
import '../state/canvas_provider.dart';
import '../state/command_palette_provider.dart';

class CommandPalette extends ConsumerStatefulWidget {
  const CommandPalette({super.key});

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<CommandPalette> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _registerCommands();
  }

  void _registerCommands() {
    ref.read(commandPaletteProvider.notifier).registerCommands([
      Command(
        id: 'new_workflow',
        title: 'New Workflow',
        subtitle: 'Create a new workflow',
        icon: Icons.add_circle,
        keywords: ['create', 'new', 'workflow'],
        action: () => _createNewWorkflow(),
        shortcut: 'Ctrl+N',
      ),
      Command(
        id: 'save',
        title: 'Save Workflow',
        subtitle: 'Save current workflow',
        icon: Icons.save,
        keywords: ['save', 'store'],
        action: () => _saveWorkflow(),
        shortcut: 'Ctrl+S',
      ),
      Command(
        id: 'generate_code',
        title: 'Generate Code',
        subtitle: 'Generate code from workflow',
        icon: Icons.code,
        keywords: ['generate', 'export', 'code'],
        action: () => _generateCode(),
        shortcut: 'Ctrl+G',
      ),
      Command(
        id: 'add_llm_node',
        title: 'Add LLM Node',
        subtitle: 'Add AI processing node',
        icon: Icons.psychology,
        keywords: ['llm', 'ai', 'node', 'add'],
        action: () => _addNode(NodeType.llm),
      ),
      Command(
        id: 'add_splitter',
        title: 'Add Splitter',
        subtitle: 'Split messages',
        icon: Icons.splitscreen,
        keywords: ['splitter', 'split', 'node'],
        action: () => _addNode(NodeType.splitter),
      ),
      Command(
        id: 'test_workflow',
        title: 'Test Workflow',
        subtitle: 'Run workflow test',
        icon: Icons.play_arrow,
        keywords: ['test', 'run', 'execute'],
        action: () => _testWorkflow(),
        shortcut: 'Ctrl+T',
      ),
      Command(
        id: 'toggle_minimap',
        title: 'Toggle Minimap',
        subtitle: 'Show/hide minimap',
        icon: Icons.map,
        keywords: ['minimap', 'map', 'overview'],
        action: () => _toggleMinimap(),
      ),
      Command(
        id: 'zoom_in',
        title: 'Zoom In',
        icon: Icons.zoom_in,
        keywords: ['zoom', 'in', 'magnify'],
        action: () => _zoom(0.1),
        shortcut: 'Ctrl+=',
      ),
      Command(
        id: 'zoom_out',
        title: 'Zoom Out',
        icon: Icons.zoom_out,
        keywords: ['zoom', 'out'],
        action: () => _zoom(-0.1),
        shortcut: 'Ctrl+-',
      ),
      Command(
        id: 'fit_screen',
        title: 'Fit to Screen',
        icon: Icons.fit_screen,
        keywords: ['fit', 'screen', 'view', 'all'],
        action: () => _fitToScreen(),
        shortcut: 'Ctrl+0',
      ),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commandPaletteProvider);

    if (!state.isVisible) return const SizedBox.shrink();

    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: () => ref.read(commandPaletteProvider.notifier).hide(),
          child: Container(color: Colors.black.withOpacity(0.5)),
        ),

        // Command Palette
        Center(
          child: Container(
            width: 600,
            constraints: const BoxConstraints(maxHeight: 500),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search input
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Type a command or search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (query) {
                      ref.read(commandPaletteProvider.notifier).search(query);
                    },
                  ),
                ),

                const Divider(height: 1),

                // Commands list
                Flexible(
                  child: state.filteredCommands.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No commands found'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.filteredCommands.length,
                          itemBuilder: (context, index) {
                            final command = state.filteredCommands[index];
                            final isSelected = index == state.selectedIndex;

                            return InkWell(
                              onTap: () {
                                command.action();
                                ref
                                    .read(commandPaletteProvider.notifier)
                                    .hide();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                color: isSelected
                                    ? Colors.blue.withOpacity(0.1)
                                    : null,
                                child: Row(
                                  children: [
                                    Icon(command.icon, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            command.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (command.subtitle != null)
                                            Text(
                                              command.subtitle!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (command.shortcut != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          command.shortcut!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _createNewWorkflow() {
    // Implementation
  }

  void _saveWorkflow() {
    // Implementation
  }

  void _generateCode() {
    // Implementation
  }

  void _addNode(NodeType type) {
    // Implementation
  }

  void _testWorkflow() {
    // Implementation
  }

  void _toggleMinimap() {
    // Implementation
  }

  void _zoom(double delta) {
    ref.read(canvasProvider.notifier).zoom(delta, Offset.zero);
  }

  void _fitToScreen() {
    // Implementation
  }
}
