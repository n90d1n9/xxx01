import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/provider.dart';

class TrainingConfigPage extends ConsumerStatefulWidget {
  const TrainingConfigPage({super.key});

  @override
  ConsumerState<TrainingConfigPage> createState() => _TrainingConfigPageState();
}

class _TrainingConfigPageState extends ConsumerState<TrainingConfigPage> {
  int currentStep = 0;
  String selectedModel = 'Llama 2 7B';
  String selectedMethod = 'LoRA';
  int epochs = 3;
  double learningRate = 0.00002;
  int batchSize = 4;
  int maxSeqLength = 512;

  final List<String> steps = [
    'Select Model',
    'Choose Method',
    'Set Parameters',
    'Review & Start',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Training Configuration')),
      body: Column(
        children: [
          // Step Indicator
          Container(
            padding: const EdgeInsets.all(24),
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.3),
            child: Row(
              children: List.generate(steps.length, (index) {
                return Expanded(
                  child: _StepIndicator(
                    stepNumber: index + 1,
                    label: steps[index],
                    isActive: currentStep == index,
                    isCompleted: currentStep > index,
                    isLast: index == steps.length - 1,
                  ),
                );
              }),
            ),
          ),

          // Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStepContent(),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentStep > 0)
                  OutlinedButton.icon(
                    onPressed: () => setState(() => currentStep--),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed:
                        () => ref.read(selectedTabProvider.notifier).state = 2,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Data Prep'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                if (currentStep < steps.length - 1)
                  FilledButton.icon(
                    onPressed: () => setState(() => currentStep++),
                    label: const Text('Next'),
                    icon: const Icon(Icons.arrow_forward),
                    iconAlignment: IconAlignment.end,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  )
                else
                  FilledButton.icon(
                    onPressed: () => _startTraining(context, ref),
                    icon: const Icon(Icons.rocket_launch),
                    label: const Text('Start Training'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildModelSelection();
      case 1:
        return _buildMethodSelection();
      case 2:
        return _buildParameterConfiguration();
      case 3:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildModelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Base Model',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the foundation model for fine-tuning',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children:
              [
                'Llama 2 7B',
                'Llama 3 8B',
                'Mistral 7B',
                'Phi-3 Mini',
                'Gemma 7B',
              ].map((model) {
                return _SelectableCard(
                  title: model,
                  description: _getModelDescription(model),
                  isSelected: selectedModel == model,
                  onTap: () => setState(() => selectedModel = model),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Training Method',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Select the fine-tuning technique',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children:
              [
                'LoRA',
                'QLoRA',
                'Full Fine-tuning',
                'DPO',
                'Chain of Thought',
              ].map((method) {
                return _SelectableCard(
                  title: method,
                  description: _getMethodDescription(method),
                  isSelected: selectedMethod == method,
                  onTap: () => setState(() => selectedMethod = method),
                  width: 300,
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildParameterConfiguration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configure Hyperparameters',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 32),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSlider(
                  'Epochs',
                  epochs.toDouble(),
                  1,
                  10,
                  (v) => setState(() => epochs = v.toInt()),
                ),
                _buildSlider(
                  'Batch Size',
                  batchSize.toDouble(),
                  1,
                  32,
                  (v) => setState(() => batchSize = v.toInt()),
                ),
                _buildSlider(
                  'Max Sequence Length',
                  maxSeqLength.toDouble(),
                  128,
                  4096,
                  (v) => setState(() => maxSeqLength = v.toInt()),
                  divisions: 15,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Learning Rate',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      learningRate.toStringAsExponential(1),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: learningRate,
                  min: 0.000001,
                  max: 0.001,
                  divisions: 100,
                  onChanged: (v) => setState(() => learningRate = v),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Configuration',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Review your settings before starting training',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReviewItem(label: 'Base Model', value: selectedModel),
                _ReviewItem(label: 'Training Method', value: selectedMethod),
                _ReviewItem(label: 'Epochs', value: epochs.toString()),
                _ReviewItem(
                  label: 'Learning Rate',
                  value: learningRate.toStringAsExponential(1),
                ),
                _ReviewItem(label: 'Batch Size', value: batchSize.toString()),
                _ReviewItem(
                  label: 'Max Sequence Length',
                  value: maxSeqLength.toString(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportConfiguration(),
                icon: const Icon(Icons.download),
                label: const Text('Export as JSON'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportAsJSONL(),
                icon: const Icon(Icons.file_download),
                label: const Text('Export as JSONL'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged, {
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
            Text(
              value.toStringAsFixed(0),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions ?? (max - min).toInt(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getModelDescription(String model) {
    switch (model) {
      case 'Llama 2 7B':
        return '7B parameters • Meta AI';
      case 'Llama 3 8B':
        return '8B parameters • Latest version';
      case 'Mistral 7B':
        return '7B parameters • High performance';
      case 'Phi-3 Mini':
        return '3.8B parameters • Microsoft';
      case 'Gemma 7B':
        return '7B parameters • Google';
      default:
        return 'Foundation model';
    }
  }

  String _getMethodDescription(String method) {
    switch (method) {
      case 'LoRA':
        return 'Efficient low-rank adaptation';
      case 'QLoRA':
        return '4-bit quantized LoRA';
      case 'Full Fine-tuning':
        return 'Train all parameters';
      case 'DPO':
        return 'Direct preference optimization';
      case 'Chain of Thought':
        return 'Step-by-step reasoning';
      default:
        return 'Training technique';
    }
  }

  void _exportConfiguration() {
    final config = {
      'name': 'Training Configuration',
      'baseModel': selectedModel,
      'method': selectedMethod,
      'hyperparameters': {
        'epochs': epochs,
        'learningRate': learningRate,
        'batchSize': batchSize,
        'maxSeqLength': maxSeqLength,
      },
      'createdAt': DateTime.now().toIso8601String(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(config);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Configuration'),
            content: SizedBox(
              width: 600,
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Configuration exported as JSON',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          jsonStr,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '✓ Configuration saved as training_config.json',
                      ),
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text('Save File'),
              ),
            ],
          ),
    );
  }

  void _exportAsJSONL() {
    // Sample training data in JSONL format
    final sampleData = [
      {
        'instruction': 'Explain what machine learning is',
        'input': '',
        'output':
            'Machine learning is a subset of artificial intelligence that enables computers to learn and improve from experience without being explicitly programmed.',
      },
      {
        'instruction': 'What is the capital of France?',
        'input': '',
        'output': 'The capital of France is Paris.',
      },
      {
        'instruction': 'Solve the math problem',
        'input': '23 + 47',
        'output':
            'Let me solve this step by step:\n1. Add the ones place: 3 + 7 = 10\n2. Carry 1 to tens place\n3. Add tens: 2 + 4 + 1 = 7\n4. Result: 70',
      },
    ];

    final jsonlStr = sampleData.map((item) => jsonEncode(item)).join('\n');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Training Data (JSONL)'),
            content: SizedBox(
              width: 600,
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sample training data in JSONL format',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Each line is a separate JSON object',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          jsonlStr,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '✓ Training data saved as training_data.jsonl',
                      ),
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text('Save File'),
              ),
            ],
          ),
    );
  }

  void _startTraining(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.rocket_launch, color: Colors.green),
                SizedBox(width: 12),
                Text('Training Started'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your training job has been submitted successfully!',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job ID: train_${DateTime.now().millisecondsSinceEpoch}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Model: $selectedModel'),
                      Text('Method: $selectedMethod'),
                      Text('Epochs: $epochs'),
                      const SizedBox(height: 8),
                      const Text('Estimated time: 2-4 hours'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('You can monitor progress from the Dashboard.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(selectedTabProvider.notifier).state = 0;
                },
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int stepNumber;
  final String label;
  final bool isActive;
  final bool isCompleted;
  final bool isLast;

  const _StepIndicator({
    required this.stepNumber,
    required this.label,
    required this.isActive,
    required this.isCompleted,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isCompleted || isActive
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade400;

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      isCompleted || isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border:
                      isActive && !isCompleted
                          ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          )
                          : null,
                ),
                child: Center(
                  child:
                      isCompleted
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                          : Text(
                            stepNumber.toString(),
                            style: TextStyle(
                              color:
                                  isActive || isCompleted
                                      ? Colors.white
                                      : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive || isCompleted ? color : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? color : Colors.grey.shade300,
              margin: const EdgeInsets.only(bottom: 40),
            ),
          ),
      ],
    );
  }
}

class _SelectableCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final double? width;

  const _SelectableCard({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 250,
      child: Card(
        elevation: isSelected ? 8 : 2,
        color:
            isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
