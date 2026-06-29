import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/provider.dart';

class EvaluationPage extends ConsumerWidget {
  const EvaluationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Model Evaluation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evaluate model performance and quality',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),

            // Select Model
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Model',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      value: 'Medical QA v2.0',
                      items:
                          [
                                'Medical QA v2.0',
                                'Legal Assistant v1.5',
                                'Code Generator v3.0',
                              ]
                              .map(
                                (m) =>
                                    DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Metrics Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evaluation Metrics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: Text('Perplexity'),
                          selected: true,
                          onSelected: (_) {},
                        ),
                        FilterChip(
                          label: Text('BLEU Score'),
                          selected: true,
                          onSelected: (_) {},
                        ),
                        FilterChip(
                          label: Text('ROUGE Score'),
                          selected: true,
                          onSelected: (_) {},
                        ),
                        FilterChip(
                          label: Text('Accuracy'),
                          selected: false,
                          onSelected: (_) {},
                        ),
                        FilterChip(
                          label: Text('F1 Score'),
                          selected: false,
                          onSelected: (_) {},
                        ),
                        FilterChip(
                          label: Text('BERTScore'),
                          selected: false,
                          onSelected: (_) {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Evaluation Results
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Results',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    _MetricRow(
                      name: 'Perplexity',
                      value: '12.4',
                      change: '-8.2%',
                      improved: true,
                    ),
                    const SizedBox(height: 16),
                    _MetricRow(
                      name: 'BLEU Score',
                      value: '0.82',
                      change: '+12.5%',
                      improved: true,
                    ),
                    const SizedBox(height: 16),
                    _MetricRow(
                      name: 'ROUGE-L',
                      value: '0.78',
                      change: '+9.1%',
                      improved: true,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _exportEvaluationReport(context),
                            icon: const Icon(Icons.download),
                            label: const Text('Export Report'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _compareModels(context),
                            icon: const Icon(Icons.compare),
                            label: const Text('Compare Models'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Safety Checks
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safety & Bias Checks',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _SafetyCheckItem(
                      name: 'Toxicity Detection',
                      status: 'Passed',
                      score: 0.02,
                      threshold: 0.05,
                    ),
                    const SizedBox(height: 12),
                    _SafetyCheckItem(
                      name: 'Bias Analysis',
                      status: 'Passed',
                      score: 0.08,
                      threshold: 0.15,
                    ),
                    const SizedBox(height: 12),
                    _SafetyCheckItem(
                      name: 'Hallucination Rate',
                      status: 'Warning',
                      score: 0.12,
                      threshold: 0.10,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () => ref.read(selectedTabProvider.notifier).state = 5,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Proceed to Deployment'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportEvaluationReport(BuildContext context) {
    final report = {
      'modelName': 'Medical QA v2.0',
      'evaluationDate': DateTime.now().toIso8601String(),
      'metrics': {
        'perplexity': 12.4,
        'bleuScore': 0.82,
        'rougeL': 0.78,
        'accuracy': 0.94,
      },
      'safetyChecks': {
        'toxicityDetection': {
          'status': 'Passed',
          'score': 0.02,
          'threshold': 0.05,
        },
        'biasAnalysis': {'status': 'Passed', 'score': 0.08, 'threshold': 0.15},
        'hallucinationRate': {
          'status': 'Warning',
          'score': 0.12,
          'threshold': 0.10,
        },
      },
      'improvements': {
        'perplexity': '-8.2%',
        'bleuScore': '+12.5%',
        'rougeL': '+9.1%',
      },
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(report);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Evaluation Report'),
            content: SizedBox(
              width: 600,
              height: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Comprehensive evaluation report',
                    style: TextStyle(color: Colors.grey.shade600),
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
                      content: Text('✓ Report saved as evaluation_report.json'),
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

  void _compareModels(BuildContext context) {
    final comparisonData = {
      'comparisonDate': DateTime.now().toIso8601String(),
      'models': [
        {
          'name': 'Medical QA v2.0',
          'accuracy': 0.94,
          'perplexity': 12.4,
          'bleuScore': 0.82,
          'latency': '45ms',
          'modelSize': '3.2 GB',
        },
        {
          'name': 'Medical QA v1.5',
          'accuracy': 0.89,
          'perplexity': 13.5,
          'bleuScore': 0.73,
          'latency': '38ms',
          'modelSize': '2.8 GB',
        },
        {
          'name': 'Baseline Model',
          'accuracy': 0.85,
          'perplexity': 15.2,
          'bleuScore': 0.68,
          'latency': '35ms',
          'modelSize': '2.5 GB',
        },
      ],
      'winner': 'Medical QA v2.0',
      'bestMetrics': {
        'accuracy': 'Medical QA v2.0',
        'latency': 'Baseline Model',
        'modelSize': 'Baseline Model',
      },
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(comparisonData);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Model Comparison'),
            content: SizedBox(
              width: 600,
              height: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Side-by-side model comparison',
                    style: TextStyle(color: Colors.grey.shade600),
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
                        '✓ Comparison saved as model_comparison.json',
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
}

class _MetricRow extends StatelessWidget {
  final String name;
  final String value;
  final String change;
  final bool improved;

  const _MetricRow({
    required this.name,
    required this.value,
    required this.change,
    required this.improved,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: TextStyle(fontSize: 16)),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    improved
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    improved ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: improved ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    change,
                    style: TextStyle(
                      color: improved ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SafetyCheckItem extends StatelessWidget {
  final String name;
  final String status;
  final double score;
  final double threshold;

  const _SafetyCheckItem({
    required this.name,
    required this.status,
    required this.score,
    required this.threshold,
  });

  @override
  Widget build(BuildContext context) {
    final isPassed = score < threshold;
    final color = isPassed ? Colors.green : Colors.orange;

    return Row(
      children: [
        Icon(isPassed ? Icons.check_circle : Icons.warning, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                'Score: ${score.toStringAsFixed(2)} (threshold: ${threshold.toStringAsFixed(2)})',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
