import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/test_case.dart';
import '../states/mcp_provider.dart';

class TestingPanel extends ConsumerWidget {
  const TestingPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testCases = ref.watch(testCasesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Test Management',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('New Test Case'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
                label: const Text('Run All Tests'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTestSummary(context, testCases),
          const SizedBox(height: 24),
          _buildTestCasesTable(context, testCases),
        ],
      ),
    );
  }

  Widget _buildTestSummary(BuildContext context, List<MCPTestCase> tests) {
    final passed = tests.where((t) => t.lastResult?.passed == true).length;
    final failed = tests.where((t) => t.lastResult?.passed == false).length;

    return Row(
      children: [
        Expanded(
          child: _buildTestMetricCard(
            context,
            'Total Tests',
            tests.length.toString(),
            Icons.bug_report,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTestMetricCard(
            context,
            'Passed',
            passed.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTestMetricCard(
            context,
            'Failed',
            failed.toString(),
            Icons.error,
            Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTestMetricCard(
            context,
            'Coverage',
            '${((passed / tests.length) * 100).toStringAsFixed(0)}%',
            Icons.trending_up,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildTestMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, [
    Color? color,
  ]) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCasesTable(BuildContext context, List<MCPTestCase> tests) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Test Cases', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...tests.map((test) {
              final passed = test.lastResult?.passed ?? false;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      passed ? Icons.check_circle : Icons.error,
                      color: passed ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            test.description,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (test.lastResult != null) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${test.lastResult!.executionTime}ms',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            _formatTestTime(test.lastResult!.executedAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {},
                        child: const Text(
                          'Run',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatTestTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}
