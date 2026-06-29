import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connector_library_state.dart';
import '../connector_registry_provider.dart';
import '../model/connector_action.dart';
import '../model/connector_category.dart';
import '../model/connector_trigger.dart';
import '../model/prebuilt_connector.dart';

class ConnectorLibraryDialog extends ConsumerStatefulWidget {
  const ConnectorLibraryDialog({super.key});

  @override
  ConsumerState<ConnectorLibraryDialog> createState() =>
      _ConnectorLibraryDialogState();
}

class _ConnectorLibraryDialogState
    extends ConsumerState<ConnectorLibraryDialog> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(connectorLibraryProvider);

    return Dialog(
      child: Container(
        width: 1000,
        height: 700,
        child: Row(
          children: [
            // Left sidebar - Categories
            Container(
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Categories',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildCategoryItem(null, 'All', Icons.apps, state),
                        ...ConnectorCategory.values.map((category) {
                          return _buildCategoryItem(
                            category,
                            _getCategoryName(category),
                            _getCategoryIcon(category),
                            state,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            // Main content
            Expanded(
              child: Column(
                children: [
                  // Header with search
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Connector Library',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search connectors...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                          onChanged: (value) {
                            ref
                                .read(connectorLibraryProvider.notifier)
                                .search(value);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Connector grid
                  Expanded(
                    child:
                        state.selectedConnector == null
                            ? _buildConnectorGrid(state)
                            : _buildConnectorDetails(state.selectedConnector!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    ConnectorCategory? category,
    String name,
    IconData icon,
    ConnectorLibraryState state,
  ) {
    final isSelected = state.selectedCategory == category;

    return ListTile(
      leading: Icon(
        icon,
        color:
            isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600,
      ),
      title: Text(
        name,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        ref.read(connectorLibraryProvider.notifier).filterByCategory(category);
      },
    );
  }

  Widget _buildConnectorGrid(ConnectorLibraryState state) {
    if (state.filteredConnectors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No connectors found',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: state.filteredConnectors.length,
      itemBuilder: (context, index) {
        final connector = state.filteredConnectors[index];
        return _buildConnectorCard(connector);
      },
    );
  }

  Widget _buildConnectorCard(PrebuiltConnector connector) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          ref
              .read(connectorLibraryProvider.notifier)
              .selectConnector(connector);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(connector.category),
                      size: 24,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  if (connector.featured)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Featured',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.amber.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                connector.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                connector.description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                  const SizedBox(width: 4),
                  Text(
                    connector.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '${connector.usageCount}+ uses',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectorDetails(PrebuiltConnector connector) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          TextButton.icon(
            onPressed: () {
              ref.read(connectorLibraryProvider.notifier).selectConnector(null);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to library'),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(connector.category),
                  size: 32,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          connector.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            connector.version,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      connector.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Add connector to workflow
                  Navigator.of(context).pop(connector);
                },
                child: const Text('Add to Workflow'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
              _buildStatCard(
                icon: Icons.star,
                label: 'Rating',
                value: connector.rating.toStringAsFixed(1),
                color: Colors.amber,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                icon: Icons.people,
                label: 'Users',
                value: '${connector.usageCount}+',
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                icon: Icons.security,
                label: 'Auth',
                value: connector.authMethod.name,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Actions
          Text(
            'Actions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...connector.actions.map((action) => _buildActionCard(action)),

          if (connector.triggers.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              'Triggers',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...connector.triggers.map((trigger) => _buildTriggerCard(trigger)),
          ],

          if (connector.documentationUrl != null) ...[
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                // Open documentation
              },
              icon: const Icon(Icons.book),
              label: const Text('View Documentation'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(ConnectorAction action) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.flash_on, color: Colors.purple.shade700),
        ),
        title: Text(
          action.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(action.description),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (action.inputFields.isNotEmpty) ...[
                  const Text(
                    'Input Fields:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...action.inputFields.map(
                    (field) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            field.required
                                ? Icons.circle
                                : Icons.circle_outlined,
                            size: 8,
                            color: field.required ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(field.label),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              field.type.name,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (action.sampleRequest != null) ...[
                  const Text(
                    'Sample Request:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      action.sampleRequest!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerCard(ConnectorTrigger trigger) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.notifications_active, color: Colors.green.shade700),
        ),
        title: Text(
          trigger.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(trigger.description),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            trigger.type.name,
            style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
          ),
        ),
      ),
    );
  }

  String _getCategoryName(ConnectorCategory category) {
    switch (category) {
      case ConnectorCategory.crm:
        return 'CRM';
      case ConnectorCategory.payment:
        return 'Payment';
      case ConnectorCategory.communication:
        return 'Communication';
      case ConnectorCategory.cloud:
        return 'Cloud';
      case ConnectorCategory.database:
        return 'Database';
      case ConnectorCategory.marketing:
        return 'Marketing';
      case ConnectorCategory.productivity:
        return 'Productivity';
      case ConnectorCategory.ecommerce:
        return 'E-commerce';
      case ConnectorCategory.analytics:
        return 'Analytics';
      case ConnectorCategory.storage:
        return 'Storage';
      case ConnectorCategory.messaging:
        return 'Messaging';
      case ConnectorCategory.ai:
        return 'AI';
      case ConnectorCategory.social:
        return 'Social Media';
      case ConnectorCategory.project:
        return 'Project Mgmt';
      case ConnectorCategory.automation:
        return 'Automation';
    }
  }

  IconData _getCategoryIcon(ConnectorCategory category) {
    switch (category) {
      case ConnectorCategory.crm:
        return Icons.people;
      case ConnectorCategory.payment:
        return Icons.payment;
      case ConnectorCategory.communication:
        return Icons.chat;
      case ConnectorCategory.cloud:
        return Icons.cloud;
      case ConnectorCategory.database:
        return Icons.storage;
      case ConnectorCategory.marketing:
        return Icons.campaign;
      case ConnectorCategory.productivity:
        return Icons.work;
      case ConnectorCategory.ecommerce:
        return Icons.shopping_cart;
      case ConnectorCategory.analytics:
        return Icons.analytics;
      case ConnectorCategory.storage:
        return Icons.folder;
      case ConnectorCategory.messaging:
        return Icons.message;
      case ConnectorCategory.ai:
        return Icons.psychology;
      case ConnectorCategory.social:
        return Icons.share;
      case ConnectorCategory.project:
        return Icons.assignment;
      case ConnectorCategory.automation:
        return Icons.auto_awesome;
    }
  }
}
