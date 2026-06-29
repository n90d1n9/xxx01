import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExperimentsPage extends ConsumerStatefulWidget {
  const ExperimentsPage({super.key});

  @override
  ConsumerState<ExperimentsPage> createState() => _ExperimentsPageState();
}

class _ExperimentsPageState extends ConsumerState<ExperimentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Experiments & A/B Testing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createExperiment(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track experiments, compare models, and optimize hyperparameters',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),

            // Active Experiments
            Text(
              'Active Experiments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _ExperimentCard(
                      name: 'LoRA vs QLoRA Comparison',
                      description: 'Comparing efficiency and accuracy',
                      variants: ['LoRA-r16', 'LoRA-r32', 'QLoRA-r16'],
                      status: 'Running',
                      progress: 0.65,
                      bestVariant: 'LoRA-r32',
                      metric: 'Accuracy: 0.94',
                    ),
                    const Divider(),
                    _ExperimentCard(
                      name: 'Learning Rate Sweep',
                      description: 'Finding optimal learning rate',
                      variants: ['1e-5', '2e-5', '5e-5', '1e-4'],
                      status: 'Completed',
                      progress: 1.0,
                      bestVariant: '2e-5',
                      metric: 'Loss: 0.234',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Hyperparameter Optimization
            Text(
              'Hyperparameter Optimization',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_fix_high,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Auto-tuning',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Use Optuna/Ray Tune for automated hyperparameter search',
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Search Strategy',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            value: 'Bayesian Optimization',
                            items:
                                [
                                      'Bayesian Optimization',
                                      'Grid Search',
                                      'Random Search',
                                      'Hyperband',
                                      'ASHA',
                                    ]
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (_) {},
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Auto-tuning'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.track_changes,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Experiment Tracking',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Integration with MLflow, Weights & Biases',
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('MLflow'),
                            value: true,
                            onChanged: (_) {},
                            dense: true,
                          ),
                          SwitchListTile(
                            title: const Text('Weights & Biases'),
                            value: false,
                            onChanged: (_) {},
                            dense: true,
                          ),
                          SwitchListTile(
                            title: const Text('TensorBoard'),
                            value: true,
                            onChanged: (_) {},
                            dense: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Model Comparison
            Text(
              'Model Comparison',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Model',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Accuracy',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Latency',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Size',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Cost/1K',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    _ModelComparisonRow(
                      name: 'Medical QA v2.0',
                      accuracy: 0.94,
                      latency: '45ms',
                      size: '3.2 GB',
                      cost: '\$0.12',
                      isBest: true,
                    ),
                    _ModelComparisonRow(
                      name: 'Medical QA v1.5',
                      accuracy: 0.89,
                      latency: '38ms',
                      size: '2.8 GB',
                      cost: '\$0.10',
                      isBest: false,
                    ),
                    _ModelComparisonRow(
                      name: 'Medical QA v1.0',
                      accuracy: 0.85,
                      latency: '35ms',
                      size: '2.5 GB',
                      cost: '\$0.09',
                      isBest: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createExperiment(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New Experiment'),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Experiment Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Experiment Type',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                              'A/B Testing',
                              'Hyperparameter Sweep',
                              'Model Comparison',
                              'Dataset Comparison',
                            ]
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }
}

class _ExperimentCard extends StatelessWidget {
  final String name;
  final String description;
  final List<String> variants;
  final String status;
  final double progress;
  final String bestVariant;
  final String metric;

  const _ExperimentCard({
    required this.name,
    required this.description,
    required this.variants,
    required this.status,
    required this.progress,
    required this.bestVariant,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      status == 'Running'
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: status == 'Running' ? Colors.blue : Colors.green,
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: status == 'Running' ? Colors.blue : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children:
                variants
                    .map(
                      (v) => Chip(
                        label: Text(v, style: TextStyle(fontSize: 11)),
                        backgroundColor:
                            v == bestVariant ? Colors.green.shade100 : null,
                        side:
                            v == bestVariant
                                ? BorderSide(color: Colors.green)
                                : null,
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Best: $bestVariant',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(metric, style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModelComparisonRow extends StatelessWidget {
  final String name;
  final double accuracy;
  final String latency;
  final String size;
  final String cost;
  final bool isBest;

  const _ModelComparisonRow({
    required this.name,
    required this.accuracy,
    required this.latency,
    required this.size,
    required this.cost,
    required this.isBest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isBest ? Colors.green.shade50 : null,
        border: isBest ? Border.all(color: Colors.green, width: 2) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(name),
                if (isBest) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.star, size: 16, color: Colors.green),
                ],
              ],
            ),
          ),
          Expanded(child: Text('${(accuracy * 100).toStringAsFixed(1)}%')),
          Expanded(child: Text(latency)),
          Expanded(child: Text(size)),
          Expanded(child: Text(cost)),
        ],
      ),
    );
  }
}
