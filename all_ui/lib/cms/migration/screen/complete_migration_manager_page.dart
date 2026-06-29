import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../content/contents_type_provider.dart';
import '../../content/model/content_type_schema.dart';
import '../../schema/model/schema_diff_viewer.dart';
import '../../schema/state/schema_version_provider.dart';
import '../state/migration_provider.dart';
import '../widget/migration_dry_run_dialog.dart';
import '../widget/migration_timeline.dart';
import '../../schema/model/schema_migration.dart';
import '../model/migration_status.dart';
import '../../schema/model/schema_version.dart';
import '../../services/migration_generator.dart';

class CompleteMigrationManagerPage extends ConsumerStatefulWidget {
  const CompleteMigrationManagerPage({super.key});
  @override
  ConsumerState<CompleteMigrationManagerPage> createState() =>
      _CompleteMigrationManagerPageState();
}

class _CompleteMigrationManagerPageState
    extends ConsumerState<CompleteMigrationManagerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final migrations = ref.watch(migrationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migration Manager'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pending_actions), text: 'Pending'),
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
            Tab(icon: Icon(Icons.account_tree), text: 'Versions'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportAllMigrations,
            tooltip: 'Export All',
          ),
          FilledButton.icon(
            onPressed: _generateMigration,
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
          MigrationTimeline(migrations: migrations),
          _buildVersionsTab(),
        ],
      ),
    );
  }

  Widget _buildPendingTab(List<SchemaMigration> migrations) {
    final pending =
        migrations.where((m) => m.status == MigrationStatus.pending).toList();
    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green.shade300),
            const SizedBox(height: 16),
            const Text('No pending migrations', style: TextStyle(fontSize: 18)),
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
      itemBuilder:
          (context, index) =>
              _buildMigrationCard(pending[index], isPending: true),
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
      itemBuilder:
          (context, index) =>
              _buildMigrationCard(history[index], isPending: false),
    );
  }

  Widget _buildVersionsTab() {
    final versions = ref.watch(schemaVersionsProvider);
    if (versions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No version snapshots yet'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _createSnapshot,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Create Snapshot'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: versions.length,
      itemBuilder: (context, index) => _buildVersionCard(versions[index]),
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
        trailing:
            isPending
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.science, color: Colors.blue),
                      onPressed: () => _showDryRun(migration),
                      tooltip: 'Dry Run',
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.green),
                      onPressed: () => _applyMigration(migration),
                      tooltip: 'Apply',
                    ),
                  ],
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
                      child: _buildSQLPanel(
                        'Up Migration',
                        migration.upSQL,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSQLPanel(
                        'Down Migration',
                        migration.downSQL,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed:
                          () => _copySQLToClipboard(migration.upSQL, 'Up'),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Up'),
                    ),
                    TextButton.icon(
                      onPressed:
                          () => _copySQLToClipboard(migration.downSQL, 'Down'),
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

  Widget _buildSQLPanel(String title, String sql, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              title.contains('Up') ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              sql,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: color,
              ),
            ),
          ),
        ),
      ],
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
        subtitle: Text(
          '${version.schemas.length} schemas • ${DateFormat('MMM d, y').format(version.timestamp)}',
        ),
        trailing: PopupMenuButton(
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'restore',
                  child: Row(
                    children: [
                      Icon(Icons.restore),
                      SizedBox(width: 8),
                      Text('Restore'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text('Export'),
                    ],
                  ),
                ),
              ],
          onSelected: (value) {
            if (value == 'restore') _restoreVersion(version);
            if (value == 'export') _exportVersion(version);
          },
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

  void _generateMigration() {
    final schemas = ref.read(contentTypesProvider).value ?? [];
    if (schemas.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No schemas available')));
      return;
    }
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Generate Migration'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  schemas.map((schema) {
                    return ListTile(
                      title: Text(schema.name),
                      subtitle: Text('v${schema.version}'),
                      onTap: () {
                        Navigator.pop(context);
                        _createMigrationForSchema(schema);
                      },
                    );
                  }).toList(),
            ),
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

  void _showDryRun(SchemaMigration migration) {
    showDialog(
      context: context,
      builder: (context) => MigrationDryRunDialog(migration: migration),
    );
  }

  void _applyMigration(SchemaMigration migration) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Apply Migration'),
            content: Text('Apply migration "${migration.name}"?'),
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
                        MigrationStatus.applied,
                      );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Migration applied successfully'),
                    ),
                  );
                },
                child: const Text('Apply'),
              ),
            ],
          ),
    );
  }

  void _copySQLToClipboard(String sql, String type) {
    Clipboard.setData(ClipboardData(text: sql));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$type migration SQL copied to clipboard')),
    );
  }

  void _showSchemaDiff(SchemaMigration migration) {
    showDialog(
      context: context,
      builder:
          (context) => SchemaDiffViewer(
            beforeSchema: migration.beforeSchema,
            afterSchema: migration.afterSchema!,
          ),
    );
  }

  void _createSnapshot() {
    final schemas = ref.read(contentTypesProvider).value ?? [];
    final versions = ref.read(schemaVersionsProvider);
    final version = SchemaVersion(
      version: versions.length + 1,
      timestamp: DateTime.now(),
      description: 'Snapshot of ${schemas.length} schemas',
      schemas: {for (var s in schemas) s.id: s},
      changes: ['Snapshot created'],
    );
    ref.read(schemaVersionsProvider.notifier).addVersion(version);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Version ${version.version} snapshot created')),
    );
  }

  void _restoreVersion(SchemaVersion version) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Restore Version'),
            content: Text(
              'Restore to version ${version.version}?\n\nThis will replace all current schemas.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  ref
                      .read(schemaVersionsProvider.notifier)
                      .restoreVersion(version.version);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Restored to version ${version.version}'),
                    ),
                  );
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Restore'),
              ),
            ],
          ),
    );
  }

  void _exportVersion(SchemaVersion version) {
    final json = jsonEncode({
      'version': version.version,
      'timestamp': version.timestamp.toIso8601String(),
      'description': version.description,
      'schemas': version.schemas.map(
        (id, schema) => MapEntry(id, schema.toJson()),
      ),
    });
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Version exported to clipboard')),
    );
  }

  void _exportAllMigrations() {
    final migrations = ref.read(migrationsProvider);
    final buffer = StringBuffer();
    for (var migration in migrations) {
      buffer.writeln('-- Migration: ${migration.name}');
      buffer.writeln('-- Version: ${migration.version}');
      buffer.writeln('-- Status: ${migration.status.name}');
      buffer.writeln();
      buffer.writeln(migration.upSQL);
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All migrations exported to clipboard')),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
