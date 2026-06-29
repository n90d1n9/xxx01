import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../schema/model/schema_migration.dart';
import '../model/migration_status.dart';

class MigrationTimeline extends StatelessWidget {
  final List<SchemaMigration> migrations;
  const MigrationTimeline({super.key, required this.migrations});
  @override
  Widget build(BuildContext context) {
    final sortedMigrations =
        migrations.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: sortedMigrations.length,
      itemBuilder: (context, index) {
        final migration = sortedMigrations[index];
        final isLast = index == sortedMigrations.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusColor(migration.status),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(migration.status),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                if (!isLast)
                  Container(width: 2, height: 80, color: Colors.grey.shade300),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              migration.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                migration.status,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              migration.status.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(migration.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        migration.description,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat(
                              'MMM d, y • HH:mm',
                            ).format(migration.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'v${migration.version}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(MigrationStatus status) {
    switch (status) {
      case MigrationStatus.pending:
        return Colors.orange;
      case MigrationStatus.applied:
        return Colors.green;
      case MigrationStatus.failed:
        return Colors.red;
      case MigrationStatus.rolledBack:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(MigrationStatus status) {
    switch (status) {
      case MigrationStatus.pending:
        return Icons.pending;
      case MigrationStatus.applied:
        return Icons.check;
      case MigrationStatus.failed:
        return Icons.error;
      case MigrationStatus.rolledBack:
        return Icons.undo;
    }
  }
}
