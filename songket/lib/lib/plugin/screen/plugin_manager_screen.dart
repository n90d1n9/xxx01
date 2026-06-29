// ==================== PLUGIN MANAGER UI ====================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/node_exceutor.dart';
import '../model/plugin_event.dart';
import '../model/plugin_health_status.dart';
import '../model/plugin_registry.dart';
import '../model/plugin_status.dart';
import '../model/registered_plugin.dart';

class PluginManagerScreen extends ConsumerStatefulWidget {
  const PluginManagerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PluginManagerScreen> createState() =>
      _PluginManagerScreenState();
}

class _PluginManagerScreenState extends ConsumerState<PluginManagerScreen>
    implements PluginRegistryListener {
  final _registry = PluginRegistry();
  final _searchController = TextEditingController();
  List<RegisteredPlugin> _filteredPlugins = [];
  String? _selectedPluginId;

  @override
  void initState() {
    super.initState();
    _registry.addListener(this);
    _loadPlugins();
  }

  @override
  void dispose() {
    _registry.removeListener(this);
    _searchController.dispose();
    super.dispose();
  }

  void _loadPlugins() {
    setState(() {
      _filteredPlugins = _registry.getAllPlugins();
    });
  }

  @override
  void onPluginEvent(PluginEvent event) {
    _loadPlugins();
    _showEventNotification(event);
  }

  void _showEventNotification(PluginEvent event) {
    String message = '';
    if (event is PluginRegisteredEvent) {
      message = 'Plugin ${event.pluginId} registered';
    } else if (event is PluginUnregisteredEvent) {
      message = 'Plugin ${event.pluginId} unregistered';
    } else if (event is PluginEnabledEvent) {
      message = 'Plugin ${event.pluginId} enabled';
    } else if (event is PluginDisabledEvent) {
      message = 'Plugin ${event.pluginId} disabled';
    }

    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Plugin Manager',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              final health = await _registry.healthCheckAll();
              _showHealthDialog(health);
            },
            tooltip: 'Health Check',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showInstallDialog,
            tooltip: 'Install Plugin',
          ),
        ],
      ),
      body: Row(
        children: [
          // Plugin List
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildSearchBar(),
                Expanded(child: _buildPluginList()),
              ],
            ),
          ),
          // Plugin Details
          if (_selectedPluginId != null)
            Expanded(flex: 3, child: _buildPluginDetails()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search plugins...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF2D2D2D),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (query) {
          setState(() {
            _filteredPlugins = query.isEmpty
                ? _registry.getAllPlugins()
                : _registry.searchPlugins(query);
          });
        },
      ),
    );
  }

  Widget _buildPluginList() {
    if (_filteredPlugins.isEmpty) {
      return const Center(
        child: Text(
          'No plugins installed',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredPlugins.length,
      itemBuilder: (context, index) {
        final registered = _filteredPlugins[index];
        final metadata = registered.plugin.metadata;
        final isSelected = _selectedPluginId == metadata.id;

        return Card(
          color: isSelected ? const Color(0xFF3D3D3D) : const Color(0xFF2D2D2D),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: _buildStatusIndicator(registered.status),
            title: Text(
              metadata.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metadata.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: [
                    _buildChip('v${metadata.version}', Colors.blue),
                    _buildChip(metadata.author, Colors.purple),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) => _handlePluginAction(metadata.id, value),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: registered.status == PluginStatus.active
                      ? 'disable'
                      : 'enable',
                  child: Text(
                    registered.status == PluginStatus.active
                        ? 'Disable'
                        : 'Enable',
                  ),
                ),
                const PopupMenuItem(value: 'update', child: Text('Update')),
                const PopupMenuItem(
                  value: 'uninstall',
                  child: Text('Uninstall'),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _selectedPluginId = metadata.id;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(PluginStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case PluginStatus.active:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case PluginStatus.disabled:
        color = Colors.orange;
        icon = Icons.pause_circle;
        break;
      case PluginStatus.error:
        color = Colors.red;
        icon = Icons.error;
        break;
    }

    return Icon(icon, color: color);
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10)),
    );
  }

  Widget _buildPluginDetails() {
    final registered = _registry.getPlugin(_selectedPluginId!);
    if (registered == null) return const SizedBox();

    final metadata = registered.plugin.metadata;
    final executors = registered.plugin.getExecutors();

    return Container(
      color: const Color(0xFF252525),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.extension,
                  color: Colors.blue,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metadata.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'by ${metadata.author}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Description
          _buildSection(
            'Description',
            Text(
              metadata.description,
              style: const TextStyle(color: Colors.white70),
            ),
          ),

          // Version & Date
          _buildSection(
            'Information',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Version', metadata.version),
                _buildInfoRow('Created', _formatDate(metadata.createdAt)),
                if (metadata.updatedAt != null)
                  _buildInfoRow('Updated', _formatDate(metadata.updatedAt!)),
                if (metadata.homepage != null)
                  _buildInfoRow('Homepage', metadata.homepage!),
              ],
            ),
          ),

          // Tags
          if (metadata.tags.isNotEmpty)
            _buildSection(
              'Tags',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: metadata.tags
                    .map((tag) => _buildChip(tag, Colors.blue))
                    .toList(),
              ),
            ),

          // Dependencies
          if (metadata.dependencies.isNotEmpty)
            _buildSection(
              'Dependencies',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: metadata.dependencies.map((dep) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.link, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${dep.pluginId} ${dep.versionConstraint}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // Capabilities
          _buildSection(
            'Capabilities',
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (metadata.capabilities.supportsAsync)
                  _buildCapabilityChip('Async', Icons.schedule),
                if (metadata.capabilities.supportsStreaming)
                  _buildCapabilityChip('Streaming', Icons.stream),
                if (metadata.capabilities.supportsBatch)
                  _buildCapabilityChip('Batch', Icons.layers),
                if (metadata.capabilities.requiresAuth)
                  _buildCapabilityChip('Auth Required', Icons.lock),
              ],
            ),
          ),

          // Node Executors
          _buildSection(
            'Node Executors (${executors.length})',
            Column(
              children: executors
                  .map((executor) => _buildExecutorCard(executor))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilityChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.green, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.green, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutorCard(NodeExecutor executor) {
    return Card(
      color: const Color(0xFF2D2D2D),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(executor.schema.icon, color: executor.schema.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        executor.schema.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        executor.schema.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildExecutorInfo(
                  'Inputs',
                  executor.schema.inputs.length.toString(),
                ),
                const SizedBox(width: 16),
                _buildExecutorInfo(
                  'Outputs',
                  executor.schema.outputs.length.toString(),
                ),
                const SizedBox(width: 16),
                _buildExecutorInfo('Category', executor.schema.category),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutorInfo(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _handlePluginAction(String pluginId, String action) async {
    try {
      switch (action) {
        case 'enable':
          await _registry.enablePlugin(pluginId);
          break;
        case 'disable':
          await _registry.disablePlugin(pluginId);
          break;
        case 'update':
          _showUpdateDialog(pluginId);
          break;
        case 'uninstall':
          _showUninstallDialog(pluginId);
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showInstallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Install Plugin',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Plugin URL or Path',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'https://example.com/plugin.zip',
                hintStyle: TextStyle(color: Colors.white54),
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
              // Install plugin logic
              Navigator.pop(context);
            },
            child: const Text('Install'),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(String pluginId) {
    // Implementation for update dialog
  }

  void _showUninstallDialog(String pluginId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Uninstall Plugin',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to uninstall this plugin? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _registry.unregisterPlugin(pluginId);
                Navigator.pop(context);
                setState(() {
                  _selectedPluginId = null;
                });
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Uninstall'),
          ),
        ],
      ),
    );
  }

  void _showHealthDialog(Map<String, PluginHealthStatus> health) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Plugin Health Check',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 400,
          child: ListView(
            shrinkWrap: true,
            children: health.entries.map((entry) {
              final status = entry.value;
              return ListTile(
                leading: Icon(
                  status.isHealthy ? Icons.check_circle : Icons.error,
                  color: status.isHealthy ? Colors.green : Colors.red,
                ),
                title: Text(
                  entry.key,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  status.message ?? 'No message',
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }).toList(),
          ),
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
}
