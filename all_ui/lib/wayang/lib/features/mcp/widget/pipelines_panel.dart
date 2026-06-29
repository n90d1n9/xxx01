import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/deployment_pipeline.dart';
import '../model/deployment_status.dart';
import '../states/mcp_provider.dart';

class PipelinesPanel extends ConsumerWidget {
  const PipelinesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pipelines = ref.watch(deploymentPipelinesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CI/CD Pipelines',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('New Pipeline'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...pipelines.map((pipeline) {
            return _buildPipelineCard(context, pipeline);
          }),
        ],
      ),
    );
  }

  Widget _buildPipelineCard(
    BuildContext context,
    MCPDeploymentPipeline pipeline,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pipeline.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        pipeline.cicdProvider ?? 'Custom',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      pipeline.status,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pipeline.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(pipeline.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...pipeline.stages.asMap().entries.map((entry) {
              final index = entry.key;
              final stage = entry.value;
              final isLast = index == pipeline.stages.length - 1;

              return Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: Text('${index + 1}')),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 30,
                          color: Theme.of(context).dividerColor,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          stage.environment.name,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (stage.requiresApproval)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Chip(
                              label: const Text('Requires Approval'),
                              labelStyle: const TextStyle(fontSize: 11),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (stage.requiresApproval)
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Approve'),
                        ),
                      ],
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(MCPDeploymentStatus status) {
    switch (status) {
      case MCPDeploymentStatus.idle:
        return Colors.grey;
      case MCPDeploymentStatus.running:
        return Colors.blue;
      case MCPDeploymentStatus.succeeded:
        return Colors.green;
      case MCPDeploymentStatus.failed:
        return Colors.red;
      case MCPDeploymentStatus.cancelled:
        return Colors.orange;
    }
  }
}
