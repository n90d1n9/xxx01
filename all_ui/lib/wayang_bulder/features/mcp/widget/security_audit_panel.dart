import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/mcp_security_audit.dart';
import '../states/mcp_provider.dart';

class SecurityAuditPanel extends ConsumerWidget {
  const SecurityAuditPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditLogs = ref.watch(auditLogsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Security & Audit Logs',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('Export Logs'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSecuritySummary(context, auditLogs),
          const SizedBox(height: 24),
          _buildAuditLogsTable(context, auditLogs),
        ],
      ),
    );
  }

  Widget _buildSecuritySummary(
    BuildContext context,
    List<MCPSecurityAudit> logs,
  ) {
    final successCount = logs.where((l) => l.success).length;
    final failureCount = logs.where((l) => !l.success).length;

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.check_circle, size: 32, color: Colors.green),
                  const SizedBox(height: 8),
                  Text(
                    successCount.toString(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Successful Actions',
                    style: Theme.of(context).textTheme.bodySmall,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 32, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    failureCount.toString(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Failed Actions',
                    style: Theme.of(context).textTheme.bodySmall,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.security, size: 32, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(
                    '${(successCount / (successCount + failureCount) * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Success Rate',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuditLogsTable(
    BuildContext context,
    List<MCPSecurityAudit> logs,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Audit Log Entries',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Timestamp')),
                  DataColumn(label: Text('Action')),
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Details')),
                  DataColumn(label: Text('Status')),
                ],
                rows: logs.map((log) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          _formatTime(log.timestamp),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(
                          log.action.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(log.userId, style: const TextStyle(fontSize: 12)),
                      ),
                      DataCell(
                        Text(
                          log.details,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: log.success
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            log.success ? 'Success' : 'Failed',
                            style: TextStyle(
                              fontSize: 12,
                              color: log.success
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final duration = DateTime.now().difference(time);
    if (duration.inMinutes < 1) return 'Now';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
    if (duration.inHours < 24) return '${duration.inHours}h ago';
    return '${duration.inDays}d ago';
  }
}
