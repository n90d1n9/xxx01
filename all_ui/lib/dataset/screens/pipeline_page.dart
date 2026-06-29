import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/job_status.dart';
import '../models/pipeline_stage.dart';
import '../states/provider.dart';
import '../widgets/status_badge.dart';

class PipelinesPage extends ConsumerWidget {
  const PipelinesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Pipelines'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'End-to-end ML pipelines for your models',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _PipelineCard(
                    name: 'Medical QA Pipeline',
                    stage: PipelineStage.deployment,
                    lastRun: '2 hours ago',
                    status: JobStatus.deployed,
                    progress: 1.0,
                  ),
                  _PipelineCard(
                    name: 'Legal Assistant',
                    stage: PipelineStage.training,
                    lastRun: '4 hours ago',
                    status: JobStatus.training,
                    progress: 0.65,
                  ),
                  _PipelineCard(
                    name: 'Customer Support Bot',
                    stage: PipelineStage.evaluation,
                    lastRun: '1 day ago',
                    status: JobStatus.evaluating,
                    progress: 0.85,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewPipelineDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Pipeline'),
      ),
    );
  }

  void _showNewPipelineDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New Pipeline'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Pipeline Name',
                    hintText: 'e.g., Medical QA v2',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'A complete pipeline includes:\n'
                  '• Data Preparation\n'
                  '• Model Training\n'
                  '• Evaluation\n'
                  '• Deployment\n'
                  '• Monitoring',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(selectedTabProvider.notifier).state = 2;
                },
                child: const Text('Create & Configure'),
              ),
            ],
          ),
    );
  }
}

class _PipelineCard extends StatelessWidget {
  final String name;
  final PipelineStage stage;
  final String lastRun;
  final JobStatus status;
  final double progress;

  const _PipelineCard({
    required this.name,
    required this.stage,
    required this.lastRun,
    required this.status,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
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
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    _getStageIcon(stage),
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStageName(stage),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(value: progress, minHeight: 6),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    lastRun,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow, size: 20),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop, size: 20),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStageIcon(PipelineStage stage) {
    switch (stage) {
      case PipelineStage.dataPreparation:
        return Icons.storage;
      case PipelineStage.training:
        return Icons.model_training;
      case PipelineStage.evaluation:
        return Icons.assessment;
      case PipelineStage.deployment:
        return Icons.rocket_launch;
      case PipelineStage.monitoring:
        return Icons.monitor_heart;
    }
  }

  String _getStageName(PipelineStage stage) {
    switch (stage) {
      case PipelineStage.dataPreparation:
        return 'Data Preparation';
      case PipelineStage.training:
        return 'Training';
      case PipelineStage.evaluation:
        return 'Evaluation';
      case PipelineStage.deployment:
        return 'Deployment';
      case PipelineStage.monitoring:
        return 'Monitoring';
    }
  }
}
