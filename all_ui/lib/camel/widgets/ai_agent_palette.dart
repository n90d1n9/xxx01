import 'package:flutter/material.dart';

import 'ai_agent_dialog.dart';

class AIAgentPalette extends StatelessWidget {
  const AIAgentPalette({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy),
              const SizedBox(width: 8),
              Text('AI Agents', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAgentBuilder(context),
                tooltip: 'Create Agent',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildAgentCard(
                  context,
                  'Orchestrator',
                  Icons.hub,
                  Colors.blue,
                  'Coordinate multiple agents',
                ),
                _buildAgentCard(
                  context,
                  'Planner',
                  Icons.calendar_view_day,
                  Colors.green,
                  'Create execution plans',
                ),
                _buildAgentCard(
                  context,
                  'Analytics',
                  Icons.analytics,
                  Colors.orange,
                  'Analyze data and generate insights',
                ),
                _buildAgentCard(
                  context,
                  'Guardrail',
                  Icons.shield,
                  Colors.red,
                  'Enforce safety and compliance',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(
    BuildContext context,
    String name,
    IconData icon,
    Color color,
    String description,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(name),
        subtitle: Text(description),
        trailing: const Icon(Icons.drag_indicator),
      ),
    );
  }

  void _showAgentBuilder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AIAgentBuilderDialog(),
    );
  }
}
