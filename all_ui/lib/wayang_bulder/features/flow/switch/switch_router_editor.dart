import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayang_builder/features/flow/switch/switch_editor.dart';

import '../router/router_route.dart';
import '../router/router_strategy.dart';
import 'router_editor_dialog.dart';

class SwitchRouterEditorScreen extends ConsumerStatefulWidget {
  final SwitchRouterNodeDefinition? existingDefinition;

  const SwitchRouterEditorScreen({super.key, this.existingDefinition});

  @override
  ConsumerState<SwitchRouterEditorScreen> createState() =>
      _SwitchRouterEditorScreenState();
}

class _SwitchRouterEditorScreenState
    extends ConsumerState<SwitchRouterEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  List<RouterRoute> _routes = [];
  RouterStrategy _strategy = RouterStrategy.roundRobin;
  bool _enableLoadBalancing = false;

  @override
  void initState() {
    super.initState();

    if (widget.existingDefinition != null) {
      _nameController = TextEditingController(
        text: widget.existingDefinition!.name,
      );
      _descriptionController = TextEditingController(
        text: widget.existingDefinition!.description,
      );
      _routes = List.from(widget.existingDefinition!.routes);
      _strategy = widget.existingDefinition!.strategy;
      _enableLoadBalancing = widget.existingDefinition!.enableLoadBalancing;
    } else {
      _nameController = TextEditingController(text: 'Switch Router');
      _descriptionController = TextEditingController(
        text: 'Route data using various strategies',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Row(
          children: [
            Icon(Icons.route, color: Colors.teal),
            SizedBox(width: 12),
            Text('Switch/Router Editor', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelp,
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildBasicInfo(),
                const SizedBox(height: 24),
                _buildStrategySelection(),
                const SizedBox(height: 24),
                _buildRoutesList(),
              ],
            ),
          ),
          _buildExamplesPanel(),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Node Name',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategySelection() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Routing Strategy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...RouterStrategy.values.map(
              (strategy) => RadioListTile<RouterStrategy>(
                title: Text(
                  _getStrategyName(strategy),
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  _getStrategyDescription(strategy),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                value: strategy,
                groupValue: _strategy,
                onChanged: (value) => setState(() => _strategy = value!),
                activeColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                'Enable Load Balancing',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Track and balance load across routes',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              value: _enableLoadBalancing,
              onChanged: (value) =>
                  setState(() => _enableLoadBalancing = value),
              activeColor: Colors.teal,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutesList() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Routes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_routes.length} routes',
                    style: const TextStyle(color: Colors.teal, fontSize: 12),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addRoute,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Route'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_routes.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(
                        Icons.route,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No routes yet',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add routes to configure routing',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._routes.asMap().entries.map(
                (entry) => _buildRouteCard(entry.value, entry.key),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(RouterRoute route, int index) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    route.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_strategy == RouterStrategy.weightedRandom)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Weight: ${route.weight}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                      ),
                    ),
                  ),
                if (_strategy == RouterStrategy.priority)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Priority: ${route.priority}',
                      style: const TextStyle(
                        color: Colors.purple,
                        fontSize: 11,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.teal, size: 20),
                  onPressed: () => _editRoute(route, index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => setState(() => _routes.removeAt(index)),
                ),
              ],
            ),
            if (route.condition != null && route.condition!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.code, color: Colors.teal, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        route.condition!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExamplesPanel() {
    return Container(
      width: 400,
      color: const Color(0xFF252525),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Routing Strategies',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          _buildStrategyCard(
            'Round Robin',
            'Route 1 → Route 2 → Route 3 → Route 1...',
            'Even distribution across all routes',
            Icons.sync,
            Colors.blue,
          ),
          _buildStrategyCard(
            'Random',
            'Random selection each time',
            'Simple load distribution',
            Icons.shuffle,
            Colors.purple,
          ),
          _buildStrategyCard(
            'Weighted',
            'Routes selected by weight probability',
            'Favor specific routes',
            Icons.pie_chart,
            Colors.orange,
          ),
          _buildStrategyCard(
            'Least Load',
            'Route to least used destination',
            'Optimal load balancing',
            Icons.balance,
            Colors.green,
          ),
          _buildStrategyCard(
            'Priority',
            'Highest priority route selected',
            'Tiered routing',
            Icons.priority_high,
            Colors.red,
          ),
          _buildStrategyCard(
            'Custom',
            'Route based on CEL conditions',
            'Complex routing logic',
            Icons.settings,
            Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyCard(
    String name,
    String example,
    String description,
    IconData icon,
    Color color,
  ) {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              example,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  String _getStrategyName(RouterStrategy strategy) {
    switch (strategy) {
      case RouterStrategy.roundRobin:
        return 'Round Robin';
      case RouterStrategy.random:
        return 'Random';
      case RouterStrategy.weightedRandom:
        return 'Weighted Random';
      case RouterStrategy.leastLoad:
        return 'Least Load';
      case RouterStrategy.priority:
        return 'Priority';
      case RouterStrategy.custom:
        return 'Custom (CEL)';
    }
  }

  String _getStrategyDescription(RouterStrategy strategy) {
    switch (strategy) {
      case RouterStrategy.roundRobin:
        return 'Distribute evenly across routes in sequence';
      case RouterStrategy.random:
        return 'Select random route each time';
      case RouterStrategy.weightedRandom:
        return 'Random selection weighted by route weights';
      case RouterStrategy.leastLoad:
        return 'Route to least used destination';
      case RouterStrategy.priority:
        return 'Route to highest priority available';
      case RouterStrategy.custom:
        return 'Use CEL expressions to determine route';
    }
  }

  void _addRoute() {
    showDialog(
      context: context,
      builder: (context) => RouterEditorDialog(
        strategy: _strategy,
        onSave: (route) {
          setState(() => _routes.add(route));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _editRoute(RouterRoute route, int index) {
    showDialog(
      context: context,
      builder: (context) => RouterEditorDialog(
        existingRoute: route,
        strategy: _strategy,
        onSave: (updated) {
          setState(() => _routes[index] = updated);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _save() {
    if (_nameController.text.isEmpty || _routes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and at least one route are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final definition = SwitchRouterNodeDefinition(
      id:
          widget.existingDefinition?.id ??
          'router_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      description: _descriptionController.text,
      routes: _routes,
      strategy: _strategy,
      enableLoadBalancing: _enableLoadBalancing,
    );

    Navigator.pop(context, definition);
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Switch/Router Help',
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What is Switch/Router?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Advanced routing with multiple strategies. Perfect for:\n'
                '• Load balancing\n'
                '• A/B testing\n'
                '• Feature flags\n'
                '• Multi-agent systems',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                'Strategies:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Round Robin: Even distribution\n'
                '• Random: Simple randomization\n'
                '• Weighted: Favor certain routes\n'
                '• Least Load: Balance workload\n'
                '• Priority: Tiered routing\n'
                '• Custom: CEL expressions',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
