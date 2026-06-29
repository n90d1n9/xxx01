import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../schema/endpoint.dart';
import '../schema/error_handler.dart';
import '../schema/integration_route.dart';
import '../schema/monitoring_config.dart';
import '../schema/routing_rule.dart';
import '../schema/transformation_step.dart';
import '../utils/route_validator.dart';
import 'data_mapper_dialog.dart';
import 'route_test_dialog.dart';
import 'validation_result_dialog.dart';

/// Main route configuration dialog
class RouteConfigurationDialog extends ConsumerStatefulWidget {
  final IntegrationRoute route;

  const RouteConfigurationDialog({super.key, required this.route});

  @override
  ConsumerState<RouteConfigurationDialog> createState() =>
      _RouteConfigurationDialogState();
}

class _RouteConfigurationDialogState
    extends ConsumerState<RouteConfigurationDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late IntegrationRoute _route;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _route = widget.route;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(child: _buildTabView()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.settings),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _route.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _route.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabs: const [
        Tab(text: 'General', icon: Icon(Icons.info_outline, size: 16)),
        Tab(text: 'Endpoints', icon: Icon(Icons.link, size: 16)),
        Tab(text: 'Transformation', icon: Icon(Icons.transform, size: 16)),
        Tab(text: 'Routing', icon: Icon(Icons.alt_route, size: 16)),
        Tab(text: 'Error Handling', icon: Icon(Icons.error_outline, size: 16)),
        Tab(text: 'Monitoring', icon: Icon(Icons.analytics, size: 16)),
        Tab(text: 'Advanced', icon: Icon(Icons.tune, size: 16)),
      ],
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _GeneralTab(route: _route, onUpdate: _updateRoute),
        _EndpointsTab(route: _route, onUpdate: _updateRoute),
        _TransformationTab(route: _route, onUpdate: _updateRoute),
        _RoutingTab(route: _route, onUpdate: _updateRoute),
        _ErrorHandlingTab(route: _route, onUpdate: _updateRoute),
        _MonitoringTab(route: _route, onUpdate: _updateRoute),
        _AdvancedTab(route: _route, onUpdate: _updateRoute),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: _validateRoute,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Validate'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _testRoute,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Test'),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: _saveRoute, child: const Text('Save')),
        ],
      ),
    );
  }

  void _updateRoute(IntegrationRoute route) {
    setState(() => _route = route);
  }

  void _validateRoute() {
    final result = RouteValidator.validateRoute(_route);

    showDialog(
      context: context,
      builder: (context) => ValidationResultDialog(result: result),
    );
  }

  void _testRoute() {
    showDialog(
      context: context,
      builder: (context) => RouteTestDialog(route: _route),
    );
  }

  void _saveRoute() {
    // Save route logic
    Navigator.pop(context, _route);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _GeneralTab extends StatefulWidget {
  final IntegrationRoute route;
  final ValueChanged<IntegrationRoute> onUpdate;

  const _GeneralTab({required this.route, required this.onUpdate});

  @override
  State<_GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<_GeneralTab> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.route.name);
    _descriptionController = TextEditingController(
      text: widget.route.description,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Route Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Route Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.label),
          ),
          onChanged: (_) => _update(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
          onChanged: (_) => _update(),
        ),
        const SizedBox(height: 24),
        Text('Metadata', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        _buildMetadataField('Route ID', widget.route.id, false),
        const SizedBox(height: 8),
        _buildMetadataField('Nodes', '${widget.route.nodes.length}', false),
        const SizedBox(height: 8),
        _buildMetadataField(
          'Connections',
          '${widget.route.connections.length}',
          false,
        ),
      ],
    );
  }

  Widget _buildMetadataField(String label, String value, bool editable) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  void _update() {
    // Update route with new values
    // widget.onUpdate(updatedRoute);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// ============================================================================
// ENDPOINTS TAB
// ============================================================================

class _EndpointsTab extends StatelessWidget {
  final IntegrationRoute route;
  final ValueChanged<IntegrationRoute> onUpdate;

  const _EndpointsTab({required this.route, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSection(
          context,
          'Source Endpoint',
          route.sourceEndpoint != null
              ? _buildEndpointCard(context, route.sourceEndpoint!)
              : _buildEmptyState(context, 'No source endpoint configured'),
          () => _configureSourceEndpoint(context),
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Target Endpoints',
          route.targetEndpoints.isNotEmpty
              ? Column(
                children:
                    route.targetEndpoints
                        .map((e) => _buildEndpointCard(context, e))
                        .toList(),
              )
              : _buildEmptyState(context, 'No target endpoints configured'),
          () => _addTargetEndpoint(context),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    Widget content,
    VoidCallback onAdd,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Configure'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildEndpointCard(BuildContext context, EndpointDefinition endpoint) {
    return Card(
      child: ListTile(
        leading: Icon(
          _getEndpointIcon(endpoint.type),
          color: _getEndpointColor(endpoint.type),
        ),
        title: Text(endpoint.name),
        subtitle: Text(endpoint.type.name.toUpperCase()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
            IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).disabledColor),
        ),
      ),
    );
  }

  IconData _getEndpointIcon(EndpointType type) {
    switch (type) {
      case EndpointType.rest:
        return Icons.api;
      case EndpointType.soap:
        return Icons.soap;
      case EndpointType.kafka:
        return Icons.message;
      case EndpointType.jms:
        return Icons.queue;
      case EndpointType.database:
        return Icons.storage;
      case EndpointType.file:
        return Icons.folder;
      case EndpointType.ftp:
        return Icons.cloud_upload;
      case EndpointType.email:
        return Icons.email;
      default:
        return Icons.link;
    }
  }

  Color _getEndpointColor(EndpointType type) {
    switch (type) {
      case EndpointType.rest:
        return Colors.blue;
      case EndpointType.soap:
        return Colors.purple;
      case EndpointType.kafka:
        return Colors.green;
      case EndpointType.jms:
        return Colors.orange;
      case EndpointType.database:
        return Colors.teal;
      case EndpointType.file:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  void _configureSourceEndpoint(BuildContext context) {
    // Show endpoint configuration dialog
  }

  void _addTargetEndpoint(BuildContext context) {
    // Show add endpoint dialog
  }
}

// ============================================================================
// TRANSFORMATION TAB
// ============================================================================

class _TransformationTab extends StatelessWidget {
  final IntegrationRoute route;
  final ValueChanged<IntegrationRoute> onUpdate;

  const _TransformationTab({required this.route, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Text(
              'Transformations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _addTransformation(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Transformation'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (route.transformations.isEmpty)
          _buildEmptyState(context)
        else
          ..._buildTransformationList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(
            Icons.transform,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No transformations configured',
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTransformationList(BuildContext context) {
    return route.transformations.map((transformation) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ExpansionTile(
          leading: Icon(_getTransformationIcon(transformation.type)),
          title: Text(transformation.name),
          subtitle: Text(transformation.type.name),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildTransformationDetails(transformation),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildTransformationDetails(TransformationStep transformation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (transformation.mappingRules != null) ...[
          const Text(
            'Mapping Rules:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...transformation.mappingRules!.map((rule) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(child: Text(rule.sourcePath)),
                  const Icon(Icons.arrow_forward, size: 16),
                  Expanded(child: Text(rule.targetPath)),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  IconData _getTransformationIcon(TransformationType type) {
    switch (type) {
      case TransformationType.dataMapper:
        return Icons.transform;
      case TransformationType.jsonTransform:
        return Icons.data_object;
      case TransformationType.xmlTransform:
        return Icons.code;
      case TransformationType.script:
        return Icons.javascript;
      default:
        return Icons.settings;
    }
  }

  void _addTransformation(BuildContext context) {
    showDialog(context: context, builder: (context) => DataMapperDialog());
  }
}

// ============================================================================
// ROUTING TAB
// ============================================================================

class _RoutingTab extends StatelessWidget {
  final IntegrationRoute route;
  final ValueChanged<IntegrationRoute> onUpdate;

  const _RoutingTab({required this.route, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Routing Configuration',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        if (route.routing != null)
          _buildRoutingConfig(context, route.routing!)
        else
          _buildNoRoutingState(context),
      ],
    );
  }

  Widget _buildRoutingConfig(BuildContext context, RoutingRule routing) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  routing.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            Text('Type: ${routing.type.name}'),
            const SizedBox(height: 16),
            const Text(
              'Routing Choices:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...routing.choices.map((choice) {
              return Card(
                color: Theme.of(context).cardColor,
                child: ListTile(
                  title: Text(choice.condition),
                  subtitle: Text('Route to: ${choice.targetNodeId}'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNoRoutingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.alt_route,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No routing rules configured',
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Configure Routing'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ERROR HANDLING TAB
// ============================================================================

class _ErrorHandlingTab extends StatelessWidget {
  final IntegrationRoute route;
  final ValueChanged<IntegrationRoute> onUpdate;

  const _ErrorHandlingTab({required this.route, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Error Handling Strategy',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        if (route.errorHandler != null)
          _buildErrorHandlerConfig(context, route.errorHandler!)
        else
          _buildDefaultErrorHandler(context),
      ],
    );
  }

  Widget _buildErrorHandlerConfig(BuildContext context, ErrorHandler handler) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              handler.type.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildConfigRow('Max Retries', handler.maxRetries.toString()),
            _buildConfigRow(
              'Retry Delay',
              '${handler.retryDelay.inMilliseconds}ms',
            ),
            _buildConfigRow(
              'Exponential Backoff',
              handler.useExponentialBackoff ? 'Yes' : 'No',
            ),
            if (handler.deadLetterChannel != null)
              _buildConfigRow(
                'Dead Letter Channel',
                handler.deadLetterChannel!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultErrorHandler(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Using Default Error Handler',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Configure Custom Error Handler'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// ============================================================================
// MONITORING TAB
// ============================================================================

class _MonitoringTab extends StatelessWidget {
  final IntegrationRoute route;
  final ValueChanged<IntegrationRoute> onUpdate;

  const _MonitoringTab({required this.route, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final monitoring =
        route.monitoring ?? const MonitoringConfig(enabled: false);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Monitoring & Metrics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Enable Monitoring'),
          subtitle: const Text('Collect metrics and traces for this route'),
          value: monitoring.enabled,
          onChanged: (value) {},
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Collect Metrics'),
          subtitle: const Text('Track route performance metrics'),
          value: monitoring.collectMetrics,
          onChanged: monitoring.enabled ? (value) {} : null,
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Enable Tracing'),
          subtitle: const Text('Distributed tracing with OpenTelemetry'),
          value: monitoring.enableTracing,
          onChanged: monitoring.enabled ? (value) {} : null,
        ),
      ],
    );
  }
}

// ============================================================================
// ADVANCED TAB
// ============================================================================

class _AdvancedTab extends StatelessWidget {
  final IntegrationRoute route;
  final ValueChanged<IntegrationRoute> onUpdate;

  const _AdvancedTab({required this.route, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Advanced Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        const Text('Additional configuration options will be available here.'),
      ],
    );
  }
}
