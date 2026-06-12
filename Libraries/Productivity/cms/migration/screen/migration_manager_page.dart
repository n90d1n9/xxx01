import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../../content/contents_type_provider.dart';
import '../../content/model/content_type_schema.dart';
import '../../schema/model/schema_migration.dart';
import '../../schema/model/schema_version.dart';
import '../../schema/state/schema_version_provider.dart';
import '../../services/migration_generator.dart';
import '../model/migration_status.dart';
import '../state/migration_provider.dart';

class MigrationManagerPage extends ConsumerStatefulWidget {
  const MigrationManagerPage({super.key});
  @override
  ConsumerState<MigrationManagerPage> createState() =>
      _MigrationManagerPageState();
}

class _MigrationManagerPageState extends ConsumerState<MigrationManagerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final migrations = ref.watch(migrationsProvider);
    final versions = ref.watch(schemaVersionsProvider);
    final schemas = ref.watch(contentTypesProvider).value ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migration Manager'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pending_actions), text: 'Pending'),
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.account_tree), text: 'Versions'),
          ],
        ),
        actions: [
          FilledButton.icon(
            onPressed: () => _generateMigration(schemas),
            icon: const Icon(Icons.add),
            label: const Text('New Migration'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(migrations),
          _buildHistoryTab(migrations),
          _buildVersionsTab(versions),
        ],
      ),
    );
  }

  Widget _buildPendingTab(List<SchemaMigration> migrations) {
    final pending = migrations
        .where((m) => m.status == MigrationStatus.pending)
        .toList();
    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green.shade300),
            const SizedBox(height: 16),
            const Text('No pending migrations'),
            const SizedBox(height: 8),
            Text(
              'All schemas are up to date',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (context, index) {
        final migration = pending[index];
        return _buildMigrationCard(migration, isPending: true);
      },
    );
  }

  Widget _buildHistoryTab(List<SchemaMigration> migrations) {
    final history =
        migrations.where((m) => m.status != MigrationStatus.pending).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (history.isEmpty) {
      return const Center(child: Text('No migration history'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final migration = history[index];
        return _buildMigrationCard(migration, isPending: false);
      },
    );
  }

  Widget _buildVersionsTab(List<SchemaVersion> versions) {
    if (versions.isEmpty) {
      return const Center(child: Text('No version history'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: versions.length,
      itemBuilder: (context, index) {
        final version = versions[index];
        return _buildVersionCard(version);
      },
    );
  }

  Widget _buildMigrationCard(
    SchemaMigration migration, {
    required bool isPending,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getMigrationStatusColor(migration.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getMigrationStatusIcon(migration.status),
            color: _getMigrationStatusColor(migration.status),
          ),
        ),
        title: Text(
          migration.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(migration.description),
            const SizedBox(height: 4),
            Text(
              'v${migration.version} • ${DateFormat('MMM d, y HH:mm').format(migration.timestamp)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: isPending
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.green),
                    onPressed: () => _applyMigration(migration),
                    tooltip: 'Apply',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteMigration(migration),
                    tooltip: 'Delete',
                  ),
                ],
              )
            : migration.status == MigrationStatus.applied
            ? IconButton(
                icon: const Icon(Icons.undo, color: Colors.orange),
                onPressed: () => _rollbackMigration(migration),
                tooltip: 'Rollback',
              )
            : null,
        children: [
          Padding(
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
                          Row(
                            children: [
                              const Icon(
                                Icons.arrow_upward,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Up Migration',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              migration.upSQL,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.arrow_downward,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Down Migration',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              migration.downSQL,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: migration.upSQL));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Up migration copied')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Up'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: migration.downSQL),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Down migration copied'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Down'),
                    ),
                    if (migration.beforeSchema != null &&
                        migration.afterSchema != null)
                      TextButton.icon(
                        onPressed: () => _showSchemaDiff(migration),
                        icon: const Icon(Icons.compare_arrows, size: 16),
                        label: const Text('View Diff'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard(SchemaVersion version) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            'v${version.version}',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        title: Text('Version ${version.version}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(version.description),
            const SizedBox(height: 4),
            Text(
              '${version.schemas.length} schemas • ${DateFormat('MMM d, y').format(version.timestamp)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.restore),
                  SizedBox(width: 8),
                  Text('Restore'),
                ],
              ),
              onTap: () => _restoreVersion(version),
            ),
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Export'),
                ],
              ),
              onTap: () => _exportVersion(version),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMigrationStatusColor(MigrationStatus status) {
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

  IconData _getMigrationStatusIcon(MigrationStatus status) {
    switch (status) {
      case MigrationStatus.pending:
        return Icons.pending;
      case MigrationStatus.applied:
        return Icons.check_circle;
      case MigrationStatus.failed:
        return Icons.error;
      case MigrationStatus.rolledBack:
        return Icons.undo;
    }
  }

  void _generateMigration(List<ContentTypeSchema> schemas) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Migration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a schema that has changed:'),
            const SizedBox(height: 16),
            ...schemas.map((schema) {
              return ListTile(
                leading: Icon(_getIconData(schema.icon)),
                title: Text(schema.name),
                subtitle: Text('v${schema.version}'),
                onTap: () {
                  Navigator.pop(context);
                  _createMigrationForSchema(schema);
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _createMigrationForSchema(ContentTypeSchema schema) {
    final migrations = ref.read(migrationsProvider);
    final version = migrations.length + 1;
    final migration = MigrationGenerator.generateMigration(
      beforeSchema: null,
      afterSchema: schema,
      version: version,
    );
    ref.read(migrationsProvider.notifier).addMigration(migration);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Migration created: ${migration.name}')),
    );
  }

  void _applyMigration(SchemaMigration migration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Migration'),
        content: Text(
          'Apply migration "${migration.name}"?\n\nThis will execute the SQL changes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(migrationsProvider.notifier)
                  .updateMigrationStatus(migration.id, MigrationStatus.applied);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Migration applied successfully')),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _rollbackMigration(SchemaMigration migration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rollback Migration'),
        content: Text(
          'Rollback migration "${migration.name}"?\n\nThis will execute the down migration.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(migrationsProvider.notifier)
                  .updateMigrationStatus(
                    migration.id,
                    MigrationStatus.rolledBack,
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Migration rolled back')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Rollback'),
          ),
        ],
      ),
    );
  }

  void _deleteMigration(SchemaMigration migration) {}
  void _showSchemaDiff(SchemaMigration migration) {}
  void _restoreVersion(SchemaVersion version) {}
  void _exportVersion(SchemaVersion version) {}
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'article':
        return Icons.article;
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_library;
      case 'person':
        return Icons.person;
      case 'category':
        return Icons.category;
      default:
        return Icons.folder;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
