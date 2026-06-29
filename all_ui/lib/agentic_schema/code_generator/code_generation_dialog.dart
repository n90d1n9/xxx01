import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../schema/agent/agent.dart';
import '../schema/common/ai_agen_builder_model.dart';
import '../schema/common/project.dart';
import '../schema/model/llm_config.dart';
import '../state/workflow/workflow_provider.dart';
import 'state/code_generation_provider.dart';

class CodeGenerationDialog extends ConsumerStatefulWidget {
  const CodeGenerationDialog({super.key});

  @override
  ConsumerState<CodeGenerationDialog> createState() =>
      _CodeGenerationDialogState();
}

class _CodeGenerationDialogState extends ConsumerState<CodeGenerationDialog> {
  String _selectedGenerator = 'camel_xml';
  final _outputController = TextEditingController(text: './output');

  @override
  void dispose() {
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final generationState = ref.watch(codeGenerationProvider);
    final workflowState = ref.watch(workflowProvider);

    return AlertDialog(
      title: const Text('Generate Code'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Target Platform:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedGenerator,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'camel_xml',
                  child: Text('Apache Camel (XML)'),
                ),
                DropdownMenuItem(
                  value: 'camel_yaml',
                  child: Text('Apache Camel (YAML)'),
                ),
                DropdownMenuItem(
                  value: 'spring_boot',
                  child: Text('Spring Boot + Camel'),
                ),
                DropdownMenuItem(value: 'flutter', child: Text('Flutter/Dart')),
                DropdownMenuItem(value: 'nodejs', child: Text('Node.js')),
                DropdownMenuItem(value: 'python', child: Text('Python')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedGenerator = value);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Output Directory:'),
            const SizedBox(height: 8),
            TextField(
              controller: _outputController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: () async {
                    // Open directory picker
                  },
                ),
              ),
            ),
            if (generationState.isGenerating) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: generationState.progress),
              const SizedBox(height: 8),
              Text(
                'Generating... ${(generationState.progress * 100).toInt()}%',
              ),
            ],
            if (generationState.error != null) ...[
              const SizedBox(height: 16),
              Text(
                'Error: ${generationState.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (generationState.generatedFiles != null) ...[
              const SizedBox(height: 16),
              Text(
                'Generated ${generationState.generatedFiles!.length} files successfully!',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(codeGenerationProvider.notifier).reset();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: generationState.isGenerating
              ? null
              : () async {
                  if (workflowState.currentWorkflow == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No workflow loaded')),
                    );
                    return;
                  }

                  // Create a minimal model for testing
                  final model = AIAgentBuilderModel(
                    project: Project(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: 'Test Project',
                    ),
                    agents: [
                      Agent(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: 'Test Agent',
                        type: AgentType.task,
                        llmConfig: LLMConfig(
                          provider: LLMProvider.openai,
                          model: 'gpt-4',
                        ),
                        workflows: [workflowState.currentWorkflow!],
                      ),
                    ],
                  );

                  await ref
                      .read(codeGenerationProvider.notifier)
                      .generate(
                        model: model,
                        generatorType: _selectedGenerator,
                        outputDirectory: _outputController.text,
                      );
                },
          child: const Text('Generate'),
        ),
      ],
    );
  }
}
