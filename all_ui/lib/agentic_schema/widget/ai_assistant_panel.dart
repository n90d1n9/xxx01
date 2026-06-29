import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/ai/node_suggestion.dart';
import '../model/ai/workflow_optimization.dart';
import '../service/ai_workflow_suggestion.dart';
import '../state/workflow/workflow_provider.dart';

class AIAssistantPanel extends ConsumerStatefulWidget {
  const AIAssistantPanel({super.key});

  @override
  ConsumerState<AIAssistantPanel> createState() => _AIAssistantPanelState();
}

class _AIAssistantPanelState extends ConsumerState<AIAssistantPanel> {
  final _assistant = AIWorkflowAssistant(apiKey: 'your-api-key');
  final _promptController = TextEditingController();
  bool _isGenerating = false;
  List<NodeSuggestion>? _suggestions;
  List<WorkflowOptimization>? _optimizations;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.psychology, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Generate from description
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Generate Workflow',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _promptController,
                          decoration: const InputDecoration(
                            hintText:
                                'Describe your workflow in natural language...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generateWorkflow,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(
                            _isGenerating ? 'Generating...' : 'Generate',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Suggestions
                if (_suggestions != null) ...[
                  const Text(
                    'Suggested Next Nodes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ..._suggestions!.map((suggestion) {
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          suggestion.type.icon,
                          color: suggestion.type.color,
                        ),
                        title: Text(suggestion.type.displayName),
                        subtitle: Text(suggestion.reason),
                        trailing: Chip(
                          label: Text(
                            '${(suggestion.confidence * 100).toInt()}%',
                          ),
                          backgroundColor: Colors.green.withOpacity(0.2),
                        ),
                        onTap: () => _applySuggestion(suggestion),
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 16),

                // Optimizations
                if (_optimizations != null) ...[
                  const Text(
                    'Optimization Suggestions',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ..._optimizations!.map((opt) {
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.lightbulb,
                          color: opt.impact == 'high'
                              ? Colors.orange
                              : Colors.blue,
                        ),
                        title: Text(opt.title),
                        subtitle: Text(opt.description),
                        trailing: Chip(
                          label: Text(opt.impact.toUpperCase()),
                          backgroundColor: opt.impact == 'high'
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.2),
                        ),
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 16),

                // Actions
                ElevatedButton.icon(
                  onPressed: _analyzeWorkflow,
                  icon: const Icon(Icons.analytics),
                  label: const Text('Analyze Workflow'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _getSuggestions,
                  icon: const Icon(Icons.tips_and_updates),
                  label: const Text('Get Suggestions'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateWorkflow() async {
    if (_promptController.text.trim().isEmpty) return;

    setState(() => _isGenerating = true);

    try {
      final workflow = await _assistant.generateWorkflowFromDescription(
        _promptController.text.trim(),
      );

      ref.read(workflowProvider.notifier).loadWorkflow(workflow);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workflow generated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _getSuggestions() async {
    final workflowState = ref.read(workflowProvider);
    if (workflowState.currentWorkflow == null ||
        workflowState.selectedNodes.isEmpty) {
      return;
    }

    final currentNode = workflowState.selectedNodes.first;
    final suggestions = await _assistant.suggestNextNode(
      workflowState.currentWorkflow!,
      currentNode,
    );

    setState(() => _suggestions = suggestions);
  }

  Future<void> _analyzeWorkflow() async {
    final workflowState = ref.read(workflowProvider);
    if (workflowState.currentWorkflow == null) return;

    final optimizations = await _assistant.analyzeWorkflow(
      workflowState.currentWorkflow!,
    );

    setState(() => _optimizations = optimizations);
  }

  void _applySuggestion(NodeSuggestion suggestion) {
    // Add the suggested node to the workflow
    final workflowState = ref.read(workflowProvider);
    if (workflowState.selectedNodes.isEmpty) return;

    final currentNode = workflowState.selectedNodes.first;
    final newPosition = Offset(
      currentNode.position.x + 250,
      currentNode.position.y,
    );

    ref.read(workflowProvider.notifier).addNode(suggestion.type, newPosition);
  }
}
