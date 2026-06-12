import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==================== INTEGRATIONS PAGE ====================

class IntegrationsPage extends ConsumerWidget {
  const IntegrationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final integrationsAsync = ref.watch(integrationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Integrations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: integrationsAsync.when(
        data: (integrations) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Connect your favorite tools',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ...integrations.map(
                (integration) => IntegrationCard(integration: integration),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class IntegrationCard extends ConsumerWidget {
  final Integration integration;

  const IntegrationCard({Key? key, required this.integration})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getIntegrationColor(integration.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIntegrationIcon(integration.type),
                color: _getIntegrationColor(integration.type),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    integration.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    integration.isConnected ? 'Connected' : 'Not connected',
                    style: TextStyle(
                      fontSize: 13,
                      color: integration.isConnected
                          ? Colors.green
                          : Colors.grey.shade600,
                    ),
                  ),
                  if (integration.lastSyncAt != null)
                    Text(
                      'Last synced: ${DateFormat('MMM dd, h:mm a').format(integration.lastSyncAt!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(integrationsProvider.notifier)
                    .toggleConnection(integration.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: integration.isConnected
                    ? Colors.red
                    : Colors.blue,
              ),
              child: Text(integration.isConnected ? 'Disconnect' : 'Connect'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIntegrationIcon(IntegrationType type) {
    switch (type) {
      case IntegrationType.slack:
        return Icons.chat;
      case IntegrationType.teams:
        return Icons.groups;
      case IntegrationType.zoom:
        return Icons.videocam;
      case IntegrationType.googleCalendar:
        return Icons.calendar_today;
      case IntegrationType.jira:
        return Icons.bug_report;
      case IntegrationType.github:
        return Icons.code;
    }
  }

  Color _getIntegrationColor(IntegrationType type) {
    switch (type) {
      case IntegrationType.slack:
        return Colors.purple;
      case IntegrationType.teams:
        return Colors.blue;
      case IntegrationType.zoom:
        return Colors.blue;
      case IntegrationType.googleCalendar:
        return Colors.red;
      case IntegrationType.jira:
        return Colors.indigo;
      case IntegrationType.github:
        return Colors.grey;
    }
  }
}

// ==================== ADVANCED SETTINGS PAGE ====================

class AdvancedSettingsPage extends ConsumerWidget {
  const AdvancedSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          currentUserAsync.when(
            data: (user) => _buildUserSection(user, context),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const Divider(),
          _buildSection(context, 'Access Control', [
            _buildMenuItem('User Management', Icons.people, Colors.blue, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserManagementPage()),
              );
            }),
            _buildMenuItem(
              'Roles & Permissions',
              Icons.security,
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RolesPermissionsPage(),
                  ),
                );
              },
            ),
            _buildMenuItem('Audit Logs', Icons.history, Colors.orange, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuditLogsPage()),
              );
            }),
          ]),
          const Divider(),
          _buildSection(context, 'Data & Export', [
            _buildMenuItem('Export Data', Icons.download, Colors.purple, () {
              _showExportOptions(context);
            }),
            _buildMenuItem('Import Data', Icons.upload, Colors.teal, () {}),
            _buildMenuItem(
              'Backup & Restore',
              Icons.backup,
              Colors.indigo,
              () {},
            ),
          ]),
          const Divider(),
          _buildSection(context, 'Advanced', [
            _buildMenuItem('API Settings', Icons.api, Colors.cyan, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const APISettingsPage()),
              );
            }),
            _buildMenuItem('Webhooks', Icons.webhook, Colors.pink, () {}),
            _buildMenuItem(
              'Custom Fields',
              Icons.edit_attributes,
              Colors.amber,
              () {},
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildUserSection(User? user, BuildContext context) {
    if (user == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              user.name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.role.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Export Data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting to PDF...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export as Excel'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting to Excel...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.code, color: Colors.blue),
              title: const Text('Export as JSON'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting to JSON...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download, color: Colors.purple),
              title: const Text('Full Backup'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Creating backup...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== USER MANAGEMENT PAGE ====================

class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: usersAsync.when(
        data: (users) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) => UserCard(user: users[index]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUser(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddUser(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            DropdownButtonFormField<UserRole>(
              decoration: const InputDecoration(labelText: 'Role'),
              items: UserRole.values.map((role) {
                return DropdownMenuItem(value: role, child: Text(role.name));
              }).toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Text(user.name[0].toUpperCase())),
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user.role.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              user.isActive ? Icons.check_circle : Icons.cancel,
              size: 16,
              color: user.isActive ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ROLES & PERMISSIONS PAGE ====================

class RolesPermissionsPage extends StatelessWidget {
  const RolesPermissionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Roles & Permissions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: UserRole.values
            .map((role) => _buildRoleCard(role, context))
            .toList(),
      ),
    );
  }

  Widget _buildRoleCard(UserRole role, BuildContext context) {
    final permissions = _getPermissionsForRole(role);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(_getRoleIcon(role), color: _getRoleColor(role)),
        title: Text(
          role.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${permissions.length} permissions'),
        children: permissions.map((permission) {
          return ListTile(
            dense: true,
            leading: const Icon(Icons.check, size: 16, color: Colors.green),
            title: Text(
              permission.name.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim(),
              style: const TextStyle(fontSize: 13),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Permission> _getPermissionsForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Permission.values;
      case UserRole.manager:
        return [
          Permission.createMeeting,
          Permission.editMeeting,
          Permission.viewMeeting,
          Permission.createProgram,
          Permission.editProgram,
          Permission.viewProgram,
          Permission.createTask,
          Permission.editTask,
          Permission.viewTask,
          Permission.viewAnalytics,
        ];
      case UserRole.member:
        return [
          Permission.createMeeting,
          Permission.viewMeeting,
          Permission.createTask,
          Permission.editTask,
          Permission.viewTask,
        ];
      case UserRole.guest:
        return [Permission.viewMeeting, Permission.viewTask];
      case UserRole.viewer:
        return [
          Permission.viewMeeting,
          Permission.viewProgram,
          Permission.viewTask,
        ];
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.manager:
        return Icons.manage_accounts;
      case UserRole.member:
        return Icons.person;
      case UserRole.guest:
        return Icons.person_outline;
      case UserRole.viewer:
        return Icons.visibility;
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.manager:
        return Colors.blue;
      case UserRole.member:
        return Colors.green;
      case UserRole.guest:
        return Colors.orange;
      case UserRole.viewer:
        return Colors.purple;
    }
  }
}

// ==================== AUDIT LOGS PAGE ====================

class AuditLogsPage extends ConsumerWidget {
  const AuditLogsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditLogsAsync = ref.watch(auditLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: auditLogsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('No audit logs available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) => AuditLogCard(log: logs[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class AuditLogCard extends StatelessWidget {
  final AuditLog log;

  const AuditLogCard({Key? key, required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getActionColor(log.action).withOpacity(0.2),
          child: Icon(
            _getActionIcon(log.action),
            color: _getActionColor(log.action),
            size: 20,
          ),
        ),
        title: Text('${log.userName} ${log.action} ${log.entityType}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM dd, yyyy h:mm a').format(log.timestamp)),
            if (log.ipAddress != null)
              Text(
                'IP: ${log.ipAddress}',
                style: const TextStyle(fontSize: 11),
              ),
          ],
        ),
        trailing: log.changes != null
            ? const Icon(Icons.info_outline, size: 20)
            : null,
      ),
    );
  }

  IconData _getActionIcon(String action) {
    if (action.contains('create')) return Icons.add_circle;
    if (action.contains('update')) return Icons.edit;
    if (action.contains('delete')) return Icons.delete;
    return Icons.info;
  }

  Color _getActionColor(String action) {
    if (action.contains('create')) return Colors.green;
    if (action.contains('update')) return Colors.blue;
    if (action.contains('delete')) return Colors.red;
    return Colors.grey;
  }
}

// ==================== API SETTINGS PAGE ====================

class APISettingsPage extends StatelessWidget {
  const APISettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'API Access',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'API Key',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'sk_live_************************',
                            style: TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('API Key copied')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh),
                    label: const Text('Regenerate Key'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'API Documentation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('View API Docs'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.integration_instructions),
            title: const Text('Integration Examples'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ==================== TEMPLATES PAGE ====================

class TemplatesPage extends ConsumerWidget {
  const TemplatesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Templates')),
      body: templatesAsync.when(
        data: (templates) {
          if (templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text('No templates yet'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showCreateTemplate(context, ref),
                    child: const Text('Create Template'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            itemBuilder: (context, index) =>
                TemplateCard(template: templates[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTemplate(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateTemplate(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Template'),
        content: const Text('Template creation feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class TemplateCard extends StatelessWidget {
  final Template template;

  const TemplateCard({Key? key, required this.template}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          _getTemplateIcon(template.type),
          color: _getTemplateColor(template.type),
        ),
        title: Text(template.name),
        subtitle: Text(
          '${template.description} • Used ${template.usageCount} times',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  IconData _getTemplateIcon(TemplateType type) {
    switch (type) {
      case TemplateType.meeting:
        return Icons.event;
      case TemplateType.program:
        return Icons.folder;
      case TemplateType.actionPlan:
        return Icons.assignment;
      case TemplateType.evaluation:
        return Icons.assessment;
    }
  }

  Color _getTemplateColor(TemplateType type) {
    switch (type) {
      case TemplateType.meeting:
        return Colors.blue;
      case TemplateType.program:
        return Colors.purple;
      case TemplateType.actionPlan:
        return Colors.orange;
      case TemplateType.evaluation:
        return Colors.green;
    }
  }
}

// ==================== ADVANCED SEARCH PAGE ====================

class AdvancedSearchPage extends StatefulWidget {
  final ScrollController controller;

  const AdvancedSearchPage({Key? key, required this.controller})
    : super(key: key);

  @override
  State<AdvancedSearchPage> createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends State<AdvancedSearchPage> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: ListView(
        controller: widget.controller,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Advanced Search',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search across all data...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),
          const Text(
            'Search In',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Meetings'),
                selected: true,
                onSelected: (v) {},
              ),
              FilterChip(
                label: const Text('Tasks'),
                selected: true,
                onSelected: (v) {},
              ),
              FilterChip(
                label: const Text('Programs'),
                selected: false,
                onSelected: (v) {},
              ),
              FilterChip(
                label: const Text('Notes'),
                selected: false,
                onSelected: (v) {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Filters',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date Range'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Created By'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.label),
            title: const Text('Tags'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search results coming soon')),
              );
            },
            icon: const Icon(Icons.search),
            label: const Text('Search'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Templates
class TemplatesNotifier extends StateNotifier<AsyncValue<List<Template>>> {
  final AdvancedRepository repository;

  TemplatesNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    state = const AsyncValue.loading();
    try {
      final templates = await repository.loadTemplates();
      state = AsyncValue.data(templates);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTemplate(Template template) async {
    final currentState = state.value ?? [];
    final newState = [...currentState, template];
    state = AsyncValue.data(newState);
    await repository.saveTemplates(newState);
  }
}

final templatesProvider =
    StateNotifierProvider<TemplatesNotifier, AsyncValue<List<Template>>>(
      (ref) => TemplatesNotifier(ref.watch(advancedRepositoryProvider)),
    );

// Audit Logs
final auditLogsProvider = FutureProvider<List<AuditLog>>((ref) async {
  final repo = ref.watch(advancedRepositoryProvider);
  return await repo.loadAuditLogs();
});

// AI Suggestions
final aiSuggestionsProvider = StateProvider<List<AISuggestion>>((ref) => []);

// ==================== MAIN APP ====================

void main() {
  runApp(const ProviderScope(child: MeetingManagementApp()));
}

class MeetingManagementApp extends StatelessWidget {
  const MeetingManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meeting Management Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationPage(),
    );
  }
}

// ==================== MAIN NAVIGATION ====================

class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          EnhancedDashboardPage(),
          AIAssistantPage(),
          WorkflowsPage(),
          IntegrationsPage(),
          AdvancedSettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: 'AI Assistant',
          ),
          NavigationDestination(
            icon: Icon(Icons.alt_route_outlined),
            selectedIcon: Icon(Icons.alt_route),
            label: 'Workflows',
          ),
          NavigationDestination(
            icon: Icon(Icons.integration_instructions_outlined),
            selectedIcon: Icon(Icons.integration_instructions),
            label: 'Integrations',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ==================== ENHANCED DASHBOARD ====================

class EnhancedDashboardPage extends ConsumerWidget {
  const EnhancedDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: currentUserAsync.when(
          data: (user) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${user?.name ?? "User"}!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user?.role.name.toUpperCase() ?? '',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          loading: () => const Text('Dashboard'),
          error: (_, __) => const Text('Dashboard'),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showAdvancedSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentUserProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildQuickActions(context, ref),
            const SizedBox(height: 24),
            _buildAISuggestions(ref),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSmartCreate(context, ref),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Smart Create'),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionChip(
                  'New Meeting',
                  Icons.event,
                  Colors.blue,
                  () {},
                ),
                _buildActionChip(
                  'Quick Task',
                  Icons.task,
                  Colors.orange,
                  () {},
                ),
                _buildActionChip(
                  'Start Timer',
                  Icons.timer,
                  Colors.green,
                  () {},
                ),
                _buildActionChip('Voice Note', Icons.mic, Colors.purple, () {}),
                _buildActionChip(
                  'Scan Document',
                  Icons.scanner,
                  Colors.teal,
                  () {},
                ),
                _buildActionChip(
                  'Templates',
                  Icons.library_books,
                  Colors.indigo,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TemplatesPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAISuggestions(WidgetRef ref) {
    final suggestions = ref.watch(aiSuggestionsProvider);

    if (suggestions.isEmpty) {
      // Generate some demo suggestions
      final demoSuggestions = AIService.generateSmartSuggestions(
        'meeting_title',
        {},
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(aiSuggestionsProvider.notifier).state = demoSuggestions;
      });
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'AI Suggestions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (suggestions.isEmpty)
              Text(
                'AI is analyzing your patterns...',
                style: TextStyle(color: Colors.grey.shade600),
              )
            else
              ...suggestions.map(
                (suggestion) => _buildSuggestionCard(suggestion, ref),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(AISuggestion suggestion, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  suggestion.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(suggestion.confidence * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            suggestion.description,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  final current = ref.read(aiSuggestionsProvider);
                  ref.read(aiSuggestionsProvider.notifier).state = current
                      .where((s) => s.id != suggestion.id)
                      .toList();
                },
                child: const Text('Dismiss'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Accept suggestion
                  final current = ref.read(aiSuggestionsProvider);
                  ref.read(aiSuggestionsProvider.notifier).state = current
                      .where((s) => s.id != suggestion.id)
                      .toList();
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              'Meeting created',
              'Q4 Planning Session',
              '10 minutes ago',
              Icons.event,
              Colors.blue,
            ),
            const Divider(),
            _buildActivityItem(
              'Workflow executed',
              'Auto-assign task to team lead',
              '1 hour ago',
              Icons.alt_route,
              Colors.green,
            ),
            const Divider(),
            _buildActivityItem(
              'Integration synced',
              'Synced with Google Calendar',
              '2 hours ago',
              Icons.sync,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _showAdvancedSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        builder: (context, controller) =>
            AdvancedSearchPage(controller: controller),
      ),
    );
  }

  void _showSmartCreate(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Smart Create',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'AI will help you create the best structure',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.event, color: Colors.blue),
              title: const Text('Smart Meeting'),
              subtitle: const Text('AI-generated agenda and structure'),
              trailing: const Icon(Icons.auto_awesome),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.task, color: Colors.orange),
              title: const Text('Smart Task'),
              subtitle: const Text('Auto-prioritize and assign'),
              trailing: const Icon(Icons.auto_awesome),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.folder, color: Colors.purple),
              title: const Text('Smart Program'),
              subtitle: const Text('Template-based with best practices'),
              trailing: const Icon(Icons.auto_awesome),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== AI ASSISTANT PAGE ====================

class AIAssistantPage extends ConsumerWidget {
  const AIAssistantPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Assistant',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFeatureCard(
            'Smart Suggestions',
            'Get AI-powered recommendations for meetings and tasks',
            Icons.lightbulb,
            Colors.amber,
            () {},
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'Sentiment Analysis',
            'Analyze team sentiment from meeting notes',
            Icons.sentiment_satisfied,
            Colors.green,
            () => _showSentimentAnalysis(context),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'Auto Summarization',
            'Generate summaries from your meeting notes',
            Icons.summarize,
            Colors.blue,
            () => _showAutoSummarization(context),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'Priority Prediction',
            'AI predicts task priority based on context',
            Icons.priority_high,
            Colors.red,
            () {},
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'Action Item Extraction',
            'Automatically extract action items from notes',
            Icons.auto_fix_high,
            Colors.purple,
            () => _showActionExtraction(context),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'Voice to Text',
            'Convert voice notes to text with AI',
            Icons.mic,
            Colors.teal,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _showSentimentAnalysis(BuildContext context) {
    final sampleText =
        'The meeting was great! Everyone participated well and we made excellent progress. However, some concerns were raised about the timeline.';
    final analysis = AIService.analyzeSentiment(sampleText);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sentiment Analysis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sample Text:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(sampleText, style: TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildSentimentResult('Sentiment', analysis['sentiment']),
            _buildSentimentResult(
              'Score',
              '${(analysis['score'] * 100).toInt()}%',
            ),
            _buildSentimentResult(
              'Confidence',
              '${(analysis['confidence'] * 100).toInt()}%',
            ),
            _buildSentimentResult(
              'Positive Words',
              '${analysis['positiveCount']}',
            ),
            _buildSentimentResult(
              'Negative Words',
              '${analysis['negativeCount']}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentResult(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAutoSummarization(BuildContext context) {
    final sampleNotes = [
      'We discussed the Q4 roadmap and priorities.',
      'Team capacity was reviewed and adjustments were made.',
      'Action items were assigned to respective team members.',
      'Next meeting scheduled for next week.',
    ];
    final summary = AIService.generateSummary(sampleNotes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto Summarization'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Original Notes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...sampleNotes.map(
              (note) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $note', style: const TextStyle(fontSize: 13)),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'AI Summary:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(summary, style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Copy Summary'),
          ),
        ],
      ),
    );
  }

  void _showActionExtraction(BuildContext context) {
    final sampleText = '''
      Meeting Notes:
      - TODO: Update the project documentation
      - Action: Schedule follow-up meeting with stakeholders
      - Need to review budget allocations
      - Task: Send meeting minutes to all attendees
    ''';
    final actionItems = AIService.extractActionItems(sampleText);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Action Item Extraction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Extracted Actions:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...actionItems.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.check_box_outline_blank, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(item, style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Action items created!')),
              );
            },
            child: const Text('Create Tasks'),
          ),
        ],
      ),
    );
  }
}

// ==================== WORKFLOWS PAGE ====================

// pubspec.yaml dependencies:
// flutter_riverpod: ^2.4.9
// uuid: ^4.2.1
// intl: ^0.18.1
// shared_preferences: ^2.2.2
// fl_chart: ^0.65.0
// file_picker: ^6.1.1
// path_provider: ^2.1.1
// dio: ^5.4.0
// flutter_quill: ^9.3.0
// image_picker: ^1.0.7
// permission_handler: ^11.2.0
// speech_to_text: ^6.6.0
// url_launcher: ^6.2.3
// share_plus: ^7.2.1

// ==================== ENUMS ====================

enum UserRole { admin, manager, member, guest, viewer }

enum Permission {
  createMeeting,
  editMeeting,
  deleteMeeting,
  viewMeeting,
  createProgram,
  editProgram,
  deleteProgram,
  viewProgram,
  createTask,
  editTask,
  deleteTask,
  viewTask,
  manageUsers,
  viewAnalytics,
  exportData,
  configureSystem,
}

enum WorkflowTrigger { onCreate, onUpdate, onDelete, onStatusChange, scheduled }

enum WorkflowAction { sendEmail, createTask, updateStatus, notify, webhook }

enum IntegrationType { slack, teams, zoom, googleCalendar, jira, github }

enum AIFeature {
  smartSuggestions,
  sentimentAnalysis,
  autoSummarize,
  priorityPrediction,
}

enum TemplateType { meeting, program, actionPlan, evaluation }

enum ExportFormat { pdf, excel, csv, json }

// ==================== ADVANCED MODELS ====================

class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final UserRole role;
  final List<Permission> permissions;
  final bool isActive;
  final DateTime createdAt;
  final Map<String, dynamic> preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
    required this.permissions,
    this.isActive = true,
    required this.createdAt,
    this.preferences = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
    'role': role.name,
    'permissions': permissions.map((p) => p.name).toList(),
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'preferences': preferences,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    avatarUrl: json['avatarUrl'],
    role: UserRole.values.firstWhere((e) => e.name == json['role']),
    permissions: (json['permissions'] as List)
        .map((p) => Permission.values.firstWhere((e) => e.name == p))
        .toList(),
    isActive: json['isActive'] ?? true,
    createdAt: DateTime.parse(json['createdAt']),
    preferences: json['preferences'] ?? {},
  );

  bool hasPermission(Permission permission) => permissions.contains(permission);

  bool canCreate(String entityType) {
    switch (entityType) {
      case 'meeting':
        return hasPermission(Permission.createMeeting);
      case 'program':
        return hasPermission(Permission.createProgram);
      case 'task':
        return hasPermission(Permission.createTask);
      default:
        return false;
    }
  }
}

class Workflow {
  final String id;
  final String name;
  final String description;
  final WorkflowTrigger trigger;
  final List<WorkflowCondition> conditions;
  final List<WorkflowAction> actions;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;

  Workflow({
    required this.id,
    required this.name,
    required this.description,
    required this.trigger,
    required this.conditions,
    required this.actions,
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'trigger': trigger.name,
    'conditions': conditions.map((c) => c.toJson()).toList(),
    'actions': actions.map((a) => a.name).toList(),
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'createdBy': createdBy,
  };

  factory Workflow.fromJson(Map<String, dynamic> json) => Workflow(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    trigger: WorkflowTrigger.values.firstWhere(
      (e) => e.name == json['trigger'],
    ),
    conditions: (json['conditions'] as List)
        .map((c) => WorkflowCondition.fromJson(c))
        .toList(),
    actions: (json['actions'] as List)
        .map((a) => WorkflowAction.values.firstWhere((e) => e.name == a))
        .toList(),
    isActive: json['isActive'] ?? true,
    createdAt: DateTime.parse(json['createdAt']),
    createdBy: json['createdBy'],
  );
}

class WorkflowCondition {
  final String field;
  final String operator;
  final dynamic value;

  WorkflowCondition({
    required this.field,
    required this.operator,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
    'field': field,
    'operator': operator,
    'value': value,
  };

  factory WorkflowCondition.fromJson(Map<String, dynamic> json) =>
      WorkflowCondition(
        field: json['field'],
        operator: json['operator'],
        value: json['value'],
      );
}

class Integration {
  final String id;
  final IntegrationType type;
  final String name;
  final bool isConnected;
  final Map<String, dynamic> config;
  final DateTime? lastSyncAt;

  Integration({
    required this.id,
    required this.type,
    required this.name,
    this.isConnected = false,
    required this.config,
    this.lastSyncAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'name': name,
    'isConnected': isConnected,
    'config': config,
    'lastSyncAt': lastSyncAt?.toIso8601String(),
  };

  factory Integration.fromJson(Map<String, dynamic> json) => Integration(
    id: json['id'],
    type: IntegrationType.values.firstWhere((e) => e.name == json['type']),
    name: json['name'],
    isConnected: json['isConnected'] ?? false,
    config: json['config'] ?? {},
    lastSyncAt: json['lastSyncAt'] != null
        ? DateTime.parse(json['lastSyncAt'])
        : null,
  );
}

class Template {
  final String id;
  final String name;
  final TemplateType type;
  final String description;
  final Map<String, dynamic> content;
  final List<String> tags;
  final bool isPublic;
  final String createdBy;
  final DateTime createdAt;
  final int usageCount;

  Template({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.content,
    required this.tags,
    this.isPublic = false,
    required this.createdBy,
    required this.createdAt,
    this.usageCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'description': description,
    'content': content,
    'tags': tags,
    'isPublic': isPublic,
    'createdBy': createdBy,
    'createdAt': createdAt.toIso8601String(),
    'usageCount': usageCount,
  };

  factory Template.fromJson(Map<String, dynamic> json) => Template(
    id: json['id'],
    name: json['name'],
    type: TemplateType.values.firstWhere((e) => e.name == json['type']),
    description: json['description'],
    content: json['content'],
    tags: List<String>.from(json['tags'] ?? []),
    isPublic: json['isPublic'] ?? false,
    createdBy: json['createdBy'],
    createdAt: DateTime.parse(json['createdAt']),
    usageCount: json['usageCount'] ?? 0,
  );
}

class AISuggestion {
  final String id;
  final AIFeature feature;
  final String title;
  final String description;
  final Map<String, dynamic> data;
  final double confidence;
  final DateTime generatedAt;
  final bool isAccepted;

  AISuggestion({
    required this.id,
    required this.feature,
    required this.title,
    required this.description,
    required this.data,
    required this.confidence,
    required this.generatedAt,
    this.isAccepted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'feature': feature.name,
    'title': title,
    'description': description,
    'data': data,
    'confidence': confidence,
    'generatedAt': generatedAt.toIso8601String(),
    'isAccepted': isAccepted,
  };

  factory AISuggestion.fromJson(Map<String, dynamic> json) => AISuggestion(
    id: json['id'],
    feature: AIFeature.values.firstWhere((e) => e.name == json['feature']),
    title: json['title'],
    description: json['description'],
    data: json['data'],
    confidence: json['confidence'],
    generatedAt: DateTime.parse(json['generatedAt']),
    isAccepted: json['isAccepted'] ?? false,
  );
}

class AuditLog {
  final String id;
  final String userId;
  final String userName;
  final String action;
  final String entityType;
  final String entityId;
  final Map<String, dynamic>? changes;
  final DateTime timestamp;
  final String? ipAddress;

  AuditLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.entityType,
    required this.entityId,
    this.changes,
    required this.timestamp,
    this.ipAddress,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'action': action,
    'entityType': entityType,
    'entityId': entityId,
    'changes': changes,
    'timestamp': timestamp.toIso8601String(),
    'ipAddress': ipAddress,
  };

  factory AuditLog.fromJson(Map<String, dynamic> json) => AuditLog(
    id: json['id'],
    userId: json['userId'],
    userName: json['userName'],
    action: json['action'],
    entityType: json['entityType'],
    entityId: json['entityId'],
    changes: json['changes'],
    timestamp: DateTime.parse(json['timestamp']),
    ipAddress: json['ipAddress'],
  );
}

class SmartSearch {
  final String query;
  final List<String> filters;
  final Map<String, dynamic> results;
  final DateTime searchedAt;

  SmartSearch({
    required this.query,
    required this.filters,
    required this.results,
    required this.searchedAt,
  });
}

// ==================== AI SERVICE ====================

class AIService {
  // Smart Suggestions
  static List<AISuggestion> generateSmartSuggestions(
    String context,
    Map<String, dynamic> data,
  ) {
    final suggestions = <AISuggestion>[];

    // Meeting title suggestions
    if (context == 'meeting_title') {
      suggestions.add(
        AISuggestion(
          id: const Uuid().v4(),
          feature: AIFeature.smartSuggestions,
          title: 'Suggested Meeting Title',
          description:
              'Q${(DateTime.now().month / 3).ceil()} Planning Session - ${DateTime.now().year}',
          data: {
            'type': 'title',
            'value': 'Q${(DateTime.now().month / 3).ceil()} Planning',
          },
          confidence: 0.85,
          generatedAt: DateTime.now(),
        ),
      );
    }

    // Action item priority prediction
    if (context == 'task_priority') {
      final dueDate = data['dueDate'] as DateTime?;
      final keywords = data['keywords'] as List<String>? ?? [];

      double urgencyScore = 0.5;
      if (dueDate != null) {
        final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
        if (daysUntilDue < 3)
          urgencyScore = 0.9;
        else if (daysUntilDue < 7)
          urgencyScore = 0.7;
      }

      if (keywords.any(
        (k) => ['urgent', 'critical', 'asap'].contains(k.toLowerCase()),
      )) {
        urgencyScore = 0.95;
      }

      suggestions.add(
        AISuggestion(
          id: const Uuid().v4(),
          feature: AIFeature.priorityPrediction,
          title: 'Recommended Priority',
          description: urgencyScore > 0.8
              ? 'High Priority'
              : urgencyScore > 0.6
              ? 'Medium Priority'
              : 'Low Priority',
          data: {
            'priority': urgencyScore > 0.8
                ? 'high'
                : urgencyScore > 0.6
                ? 'medium'
                : 'low',
          },
          confidence: urgencyScore,
          generatedAt: DateTime.now(),
        ),
      );
    }

    return suggestions;
  }

  // Sentiment Analysis
  static Map<String, dynamic> analyzeSentiment(String text) {
    final positiveWords = [
      'great',
      'excellent',
      'good',
      'amazing',
      'wonderful',
      'fantastic',
    ];
    final negativeWords = [
      'bad',
      'poor',
      'terrible',
      'awful',
      'disappointed',
      'frustrated',
    ];

    final words = text.toLowerCase().split(' ');
    int positiveCount = 0;
    int negativeCount = 0;

    for (final word in words) {
      if (positiveWords.contains(word)) positiveCount++;
      if (negativeWords.contains(word)) negativeCount++;
    }

    final total = positiveCount + negativeCount;
    if (total == 0) {
      return {'sentiment': 'neutral', 'score': 0.5, 'confidence': 0.5};
    }

    final score = positiveCount / total;
    String sentiment;
    if (score > 0.6)
      sentiment = 'positive';
    else if (score < 0.4)
      sentiment = 'negative';
    else
      sentiment = 'neutral';

    return {
      'sentiment': sentiment,
      'score': score,
      'confidence': total / words.length,
      'positiveCount': positiveCount,
      'negativeCount': negativeCount,
    };
  }

  // Auto-summarization
  static String generateSummary(List<String> notes) {
    if (notes.isEmpty) return 'No notes available for summary.';

    final allText = notes.join(' ');
    final sentences = allText
        .split(RegExp(r'[.!?]'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    if (sentences.length <= 3) return allText;

    // Take first and last sentence plus one from middle
    final summary =
        [
          sentences.first.trim(),
          if (sentences.length > 2) sentences[sentences.length ~/ 2].trim(),
          sentences.last.trim(),
        ].join('. ') +
        '.';

    return summary;
  }

  // Extract action items from text
  static List<String> extractActionItems(String text) {
    final actionKeywords = [
      'todo:',
      'action:',
      'task:',
      'follow up',
      'need to',
      'should',
      'must',
    ];
    final lines = text.split('\n');
    final actionItems = <String>[];

    for (final line in lines) {
      final lowerLine = line.toLowerCase();
      if (actionKeywords.any((keyword) => lowerLine.contains(keyword))) {
        actionItems.add(line.trim());
      }
    }

    return actionItems;
  }
}

// ==================== WORKFLOW ENGINE ====================

class WorkflowEngine {
  static Future<void> executeWorkflow(
    Workflow workflow,
    Map<String, dynamic> context,
  ) async {
    if (!workflow.isActive) return;

    // Check conditions
    bool conditionsMet = true;
    for (final condition in workflow.conditions) {
      if (!_evaluateCondition(condition, context)) {
        conditionsMet = false;
        break;
      }
    }

    if (!conditionsMet) return;

    // Execute actions
    for (final action in workflow.actions) {
      await _executeAction(action, context);
    }
  }

  static bool _evaluateCondition(
    WorkflowCondition condition,
    Map<String, dynamic> context,
  ) {
    final fieldValue = context[condition.field];

    switch (condition.operator) {
      case 'equals':
        return fieldValue == condition.value;
      case 'not_equals':
        return fieldValue != condition.value;
      case 'contains':
        return fieldValue.toString().contains(condition.value.toString());
      case 'greater_than':
        return (fieldValue as num) > (condition.value as num);
      case 'less_than':
        return (fieldValue as num) < (condition.value as num);
      default:
        return false;
    }
  }

  static Future<void> _executeAction(
    WorkflowAction action,
    Map<String, dynamic> context,
  ) async {
    switch (action) {
      case WorkflowAction.sendEmail:
        await _sendEmail(context);
        break;
      case WorkflowAction.createTask:
        await _createTask(context);
        break;
      case WorkflowAction.updateStatus:
        await _updateStatus(context);
        break;
      case WorkflowAction.notify:
        await _sendNotification(context);
        break;
      case WorkflowAction.webhook:
        await _callWebhook(context);
        break;
    }
  }

  static Future<void> _sendEmail(Map<String, dynamic> context) async {
    // Simulate email sending
    await Future.delayed(const Duration(milliseconds: 100));
    print('Email sent: ${context['subject']}');
  }

  static Future<void> _createTask(Map<String, dynamic> context) async {
    // Simulate task creation
    await Future.delayed(const Duration(milliseconds: 100));
    print('Task created: ${context['taskTitle']}');
  }

  static Future<void> _updateStatus(Map<String, dynamic> context) async {
    // Simulate status update
    await Future.delayed(const Duration(milliseconds: 100));
    print('Status updated to: ${context['newStatus']}');
  }

  static Future<void> _sendNotification(Map<String, dynamic> context) async {
    // Simulate notification
    await Future.delayed(const Duration(milliseconds: 100));
    print('Notification sent: ${context['message']}');
  }

  static Future<void> _callWebhook(Map<String, dynamic> context) async {
    // Simulate webhook call
    await Future.delayed(const Duration(milliseconds: 100));
    print('Webhook called: ${context['url']}');
  }
}

// ==================== REPOSITORY ====================

class AdvancedRepository {
  static const String _usersKey = 'users_data';
  static const String _workflowsKey = 'workflows_data';
  static const String _integrationsKey = 'integrations_data';
  static const String _templatesKey = 'templates_data';
  static const String _auditLogsKey = 'audit_logs_data';
  static const String _currentUserKey = 'current_user';

  Future<void> saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = users.map((u) => u.toJson()).toList();
    await prefs.setString(_usersKey, jsonEncode(jsonData));
  }

  Future<List<User>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_usersKey);
    if (jsonString == null) return _getDefaultUsers();
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((json) => User.fromJson(json)).toList();
  }

  List<User> _getDefaultUsers() {
    return [
      User(
        id: 'admin-1',
        name: 'Admin User',
        email: 'admin@company.com',
        role: UserRole.admin,
        permissions: Permission.values,
        createdAt: DateTime.now(),
      ),
      User(
        id: 'manager-1',
        name: 'Manager User',
        email: 'manager@company.com',
        role: UserRole.manager,
        permissions: [
          Permission.createMeeting,
          Permission.editMeeting,
          Permission.viewMeeting,
          Permission.createProgram,
          Permission.editProgram,
          Permission.viewProgram,
          Permission.createTask,
          Permission.editTask,
          Permission.viewTask,
          Permission.viewAnalytics,
        ],
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<void> setCurrentUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, userId);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserKey);
    if (userId == null) return null;

    final users = await loadUsers();
    return users.firstWhere((u) => u.id == userId, orElse: () => users.first);
  }

  Future<void> saveWorkflows(List<Workflow> workflows) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = workflows.map((w) => w.toJson()).toList();
    await prefs.setString(_workflowsKey, jsonEncode(jsonData));
  }

  Future<List<Workflow>> loadWorkflows() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_workflowsKey);
    if (jsonString == null) return [];
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((json) => Workflow.fromJson(json)).toList();
  }

  Future<void> saveIntegrations(List<Integration> integrations) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = integrations.map((i) => i.toJson()).toList();
    await prefs.setString(_integrationsKey, jsonEncode(jsonData));
  }

  Future<List<Integration>> loadIntegrations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_integrationsKey);
    if (jsonString == null) return _getDefaultIntegrations();
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((json) => Integration.fromJson(json)).toList();
  }

  List<Integration> _getDefaultIntegrations() {
    return [
      Integration(
        id: '1',
        type: IntegrationType.slack,
        name: 'Slack Workspace',
        config: {},
      ),
      Integration(
        id: '2',
        type: IntegrationType.zoom,
        name: 'Zoom Meetings',
        config: {},
      ),
      Integration(
        id: '3',
        type: IntegrationType.googleCalendar,
        name: 'Google Calendar',
        config: {},
      ),
    ];
  }

  Future<void> saveTemplates(List<Template> templates) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = templates.map((t) => t.toJson()).toList();
    await prefs.setString(_templatesKey, jsonEncode(jsonData));
  }

  Future<List<Template>> loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_templatesKey);
    if (jsonString == null) return [];
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((json) => Template.fromJson(json)).toList();
  }

  Future<void> saveAuditLogs(List<AuditLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = logs.map((l) => l.toJson()).toList();
    await prefs.setString(_auditLogsKey, jsonEncode(jsonData));
  }

  Future<List<AuditLog>> loadAuditLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_auditLogsKey);
    if (jsonString == null) return [];
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((json) => AuditLog.fromJson(json)).toList();
  }

  Future<void> addAuditLog(AuditLog log) async {
    final logs = await loadAuditLogs();
    logs.add(log);
    // Keep only last 1000 logs
    if (logs.length > 1000) {
      logs.removeRange(0, logs.length - 1000);
    }
    await saveAuditLogs(logs);
  }
}

// ==================== STATE MANAGEMENT ====================

final advancedRepositoryProvider = Provider((ref) => AdvancedRepository());

// Current User
final currentUserProvider = FutureProvider<User?>((ref) async {
  final repo = ref.watch(advancedRepositoryProvider);
  return await repo.getCurrentUser();
});

// Users
class UsersNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final AdvancedRepository repository;

  UsersNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = const AsyncValue.loading();
    try {
      final users = await repository.loadUsers();
      state = AsyncValue.data(users);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addUser(User user) async {
    final currentState = state.value ?? [];
    final newState = [...currentState, user];
    state = AsyncValue.data(newState);
    await repository.saveUsers(newState);
  }

  Future<void> updateUser(User updatedUser) async {
    final currentState = state.value ?? [];
    final newState = [
      for (final user in currentState)
        if (user.id == updatedUser.id) updatedUser else user,
    ];
    state = AsyncValue.data(newState);
    await repository.saveUsers(newState);
  }
}

final usersProvider =
    StateNotifierProvider<UsersNotifier, AsyncValue<List<User>>>(
      (ref) => UsersNotifier(ref.watch(advancedRepositoryProvider)),
    );

// Workflows
class WorkflowsNotifier extends StateNotifier<AsyncValue<List<Workflow>>> {
  final AdvancedRepository repository;

  WorkflowsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadWorkflows();
  }

  Future<void> loadWorkflows() async {
    state = const AsyncValue.loading();
    try {
      final workflows = await repository.loadWorkflows();
      state = AsyncValue.data(workflows);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addWorkflow(Workflow workflow) async {
    final currentState = state.value ?? [];
    final newState = [...currentState, workflow];
    state = AsyncValue.data(newState);
    await repository.saveWorkflows(newState);
  }

  Future<void> toggleWorkflow(String id) async {
    final currentState = state.value ?? [];
    final newState = [
      for (final workflow in currentState)
        if (workflow.id == id)
          Workflow(
            id: workflow.id,
            name: workflow.name,
            description: workflow.description,
            trigger: workflow.trigger,
            conditions: workflow.conditions,
            actions: workflow.actions,
            isActive: !workflow.isActive,
            createdAt: workflow.createdAt,
            createdBy: workflow.createdBy,
          )
        else
          workflow,
    ];
    state = AsyncValue.data(newState);
    await repository.saveWorkflows(newState);
  }
}

final workflowsProvider =
    StateNotifierProvider<WorkflowsNotifier, AsyncValue<List<Workflow>>>(
      (ref) => WorkflowsNotifier(ref.watch(advancedRepositoryProvider)),
    );

class WorkflowsPage extends ConsumerWidget {
  const WorkflowsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflowsAsync = ref.watch(workflowsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workflows',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showWorkflowHelp(context),
          ),
        ],
      ),
      body: workflowsAsync.when(
        data: (workflows) {
          if (workflows.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alt_route, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No workflows yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Create automated workflows to save time'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workflows.length,
            itemBuilder: (context, index) =>
                WorkflowCard(workflow: workflows[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateWorkflow(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Workflow'),
      ),
    );
  }

  void _showWorkflowHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Workflows'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workflows automate repetitive tasks and processes.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Examples:'),
            SizedBox(height: 8),
            Text('• Send email when meeting is created'),
            Text('• Create task when status changes'),
            Text('• Notify team when deadline approaches'),
            Text('• Auto-assign tasks based on rules'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showCreateWorkflow(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Workflow'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Meeting Created'),
              subtitle: const Text('Trigger when new meeting is created'),
              onTap: () {
                Navigator.pop(context);
                _createDemoWorkflow(ref, 'meeting_created');
              },
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Task Status Change'),
              subtitle: const Text('Trigger when task status updates'),
              onTap: () {
                Navigator.pop(context);
                _createDemoWorkflow(ref, 'task_status_change');
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Deadline Approaching'),
              subtitle: const Text('Trigger 24 hours before deadline'),
              onTap: () {
                Navigator.pop(context);
                _createDemoWorkflow(ref, 'deadline_approaching');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createDemoWorkflow(WidgetRef ref, String type) {
    final workflow = Workflow(
      id: const Uuid().v4(),
      name: type == 'meeting_created'
          ? 'Auto-notify team on meeting creation'
          : type == 'task_status_change'
          ? 'Send update when task completes'
          : 'Deadline reminder notification',
      description: 'Automatically created workflow',
      trigger: type == 'meeting_created'
          ? WorkflowTrigger.onCreate
          : type == 'task_status_change'
          ? WorkflowTrigger.onStatusChange
          : WorkflowTrigger.scheduled,
      conditions: [],
      actions: [WorkflowAction.notify],
      createdAt: DateTime.now(),
      createdBy: 'current-user',
    );

    ref.read(workflowsProvider.notifier).addWorkflow(workflow);
  }
}

final integrationsProvider =
    StateNotifierProvider<IntegrationsNotifier, AsyncValue<List<Integration>>>(
      (ref) => IntegrationsNotifier(ref.watch(advancedRepositoryProvider)),
    );

// Integrations
class IntegrationsNotifier
    extends StateNotifier<AsyncValue<List<Integration>>> {
  final AdvancedRepository repository;

  IntegrationsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadIntegrations();
  }

  Future<void> loadIntegrations() async {
    state = const AsyncValue.loading();
    try {
      final integrations = await repository.loadIntegrations();
      state = AsyncValue.data(integrations);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleConnection(String id) async {
    final currentState = state.value ?? [];
    final newState = [
      for (final integration in currentState)
        if (integration.id == id)
          Integration(
            id: integration.id,
            type: integration.type,
            name: integration.name,
            isConnected: !integration.isConnected,
            config: integration.config,
            lastSyncAt: !integration.isConnected ? DateTime.now() : null,
          )
        else
          integration,
    ];
    state = AsyncValue.data(newState);
    await repository.saveIntegrations(newState);
  }
}

class WorkflowCard extends ConsumerWidget {
  final Workflow workflow;

  const WorkflowCard({Key? key, required this.workflow}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: workflow.isActive
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.alt_route,
                    color: workflow.isActive
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workflow.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        workflow.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: workflow.isActive,
                  onChanged: (value) {
                    ref
                        .read(workflowsProvider.notifier)
                        .toggleWorkflow(workflow.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  'Trigger: ${workflow.trigger.name}',
                  Icons.flash_on,
                  Colors.blue,
                ),
                _buildInfoChip(
                  '${workflow.actions.length} actions',
                  Icons.play_arrow,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
