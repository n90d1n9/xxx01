import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/mcp.dart';
import '../model/mcp_tool.dart';
import '../states/mcp_provider.dart';
import '../states/mcp_tool_notifier.dart';
import '../widget/empty_selection_panel.dart';
import '../widget/tool_detail_panel.dart';
import '../widget/tool_list_tile.dart';

class MCPToolRegistryScreen extends ConsumerWidget {
  const MCPToolRegistryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tools = ref.watch(mcpToolsProvider);
    final selectedTool = ref.watch(selectedToolProvider);

    return Row(
      children: [
        Container(
          width: 450,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Column(
            children: [
              _buildToolListHeader(context, tools),
              Expanded(
                child: ListView.builder(
                  itemCount: tools.length,
                  itemBuilder: (context, index) {
                    final tool = tools[index];
                    final isSelected = selectedTool?.id == tool.id;

                    return ToolListTile(
                      tool: tool,
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(selectedToolProvider.notifier).state = tool;
                      },
                      onDelete: () {
                        ref.read(mcpToolsProvider.notifier).deleteTool(tool.id);
                        ref.read(selectedToolProvider.notifier).state = null;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: selectedTool != null
              ? ToolDetailsPanel(tool: selectedTool)
              : const EmptySelectionPanel(),
        ),
      ],
    );
  }

  Widget _buildToolListHeader(BuildContext context, List<MCPTool> tools) {
    final activTools = tools
        .where((t) => t.status == MCPToolStatus.active)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.build, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Tools (${tools.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$activTools Active',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
