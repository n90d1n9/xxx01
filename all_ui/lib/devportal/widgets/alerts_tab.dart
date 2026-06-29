import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/alert.dart';
import '../states/provider.dart';

class AlertsTab extends ConsumerWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);
    final theme = Theme.of(context);

    return alerts.when(
      data: (alertsList) {
        if (alertsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text('No alerts to display', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'System notifications will appear here',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        // Group alerts by date
        final groupedAlerts = <String, List<Alert>>{};
        for (var alert in alertsList) {
          final dateStr = DateFormat('MMM d, yyyy').format(alert.timestamp);
          if (!groupedAlerts.containsKey(dateStr)) {
            groupedAlerts[dateStr] = [];
          }
          groupedAlerts[dateStr]!.add(alert);
        }

        return ListView.builder(
          itemCount: groupedAlerts.keys.length,
          itemBuilder: (context, index) {
            final dateStr = groupedAlerts.keys.elementAt(index);
            final dateAlerts = groupedAlerts[dateStr]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    dateStr,
                    style: theme.textTheme.titleSmall!.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...dateAlerts.map(
                  (alert) => _buildAlertTile(context, alert, ref),
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(child: Text('Error loading alerts: $error')),
    );
  }

  Widget _buildAlertTile(BuildContext context, Alert alert, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color:
          alert.isRead
              ? theme.colorScheme.surface
              : theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
      child: InkWell(
        onTap: () {
          _showAlertDetails(context, alert, ref);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(alert.severityIcon, color: alert.severityColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontWeight:
                                  alert.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(alert.timestamp),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (alert.projectId != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            size: 16,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Project: ${alert.projectId}',
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlertDetails(BuildContext context, Alert alert, WidgetRef ref) {
    // Mark as read
    // This would call a method in your provider to update the alert status

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(alert.severityIcon, color: alert.severityColor),
                const SizedBox(width: 8),
                Expanded(child: Text(alert.title)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMM d, yyyy · h:mm a').format(alert.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(alert.message),
                  if (alert.projectId != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Project: '),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Navigate to project details
                          },
                          child: Text(alert.projectId!),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
