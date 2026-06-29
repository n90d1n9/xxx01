import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Models
class ApiGateway {
  final String id;
  final String name;
  final String endpoint;
  final String status;
  final int totalRequests;
  final double avgResponseTime;
  final DateTime lastDeployed;
  final List<String> tags;

  ApiGateway({
    required this.id,
    required this.name,
    required this.endpoint,
    required this.status,
    required this.totalRequests,
    required this.avgResponseTime,
    required this.lastDeployed,
    required this.tags,
  });

  factory ApiGateway.fromJson(Map<String, dynamic> json) {
    return ApiGateway(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      endpoint: json['endpoint'] ?? '',
      status: json['status'] ?? 'unknown',
      totalRequests: json['totalRequests'] ?? 0,
      avgResponseTime: (json['avgResponseTime'] ?? 0.0).toDouble(),
      lastDeployed:
          DateTime.tryParse(json['lastDeployed'] ?? '') ?? DateTime.now(),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

class ApiRoute {
  final String id;
  final String method;
  final String path;
  final String target;
  final bool isEnabled;
  final int requestCount;
  final List<String> middleware;

  ApiRoute({
    required this.id,
    required this.method,
    required this.path,
    required this.target,
    required this.isEnabled,
    required this.requestCount,
    required this.middleware,
  });

  factory ApiRoute.fromJson(Map<String, dynamic> json) {
    return ApiRoute(
      id: json['id'] ?? '',
      method: json['method'] ?? 'GET',
      path: json['path'] ?? '',
      target: json['target'] ?? '',
      isEnabled: json['isEnabled'] ?? true,
      requestCount: json['requestCount'] ?? 0,
      middleware: List<String>.from(json['middleware'] ?? []),
    );
  }
}

// Services
class ApiGatewayService {
  static const String baseUrl = 'https://api.example.com';

  Future<List<ApiGateway>> fetchGateways() async {
    // Simulated API call - replace with actual HTTP request
    await Future.delayed(const Duration(seconds: 1));

    // Mock data for demonstration
    return [
      ApiGateway(
        id: '1',
        name: 'Production Gateway',
        endpoint: 'https://api.prod.example.com',
        status: 'active',
        totalRequests: 45632,
        avgResponseTime: 125.5,
        lastDeployed: DateTime.now().subtract(const Duration(days: 3)),
        tags: ['production', 'v2.1'],
      ),
      ApiGateway(
        id: '2',
        name: 'Staging Gateway',
        endpoint: 'https://api.staging.example.com',
        status: 'active',
        totalRequests: 8934,
        avgResponseTime: 89.2,
        lastDeployed: DateTime.now().subtract(const Duration(hours: 6)),
        tags: ['staging', 'testing'],
      ),
      ApiGateway(
        id: '3',
        name: 'Development Gateway',
        endpoint: 'https://api.dev.example.com',
        status: 'inactive',
        totalRequests: 1523,
        avgResponseTime: 203.1,
        lastDeployed: DateTime.now().subtract(const Duration(days: 1)),
        tags: ['development', 'experimental'],
      ),
    ];
  }

  Future<List<ApiRoute>> fetchRoutes(String gatewayId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      ApiRoute(
        id: '1',
        method: 'GET',
        path: '/api/v1/users',
        target: 'users-service:8080/users',
        isEnabled: true,
        requestCount: 12450,
        middleware: ['auth', 'rate-limit', 'cors'],
      ),
      ApiRoute(
        id: '2',
        method: 'POST',
        path: '/api/v1/orders',
        target: 'orders-service:8080/orders',
        isEnabled: true,
        requestCount: 8934,
        middleware: ['auth', 'validation'],
      ),
      ApiRoute(
        id: '3',
        method: 'GET',
        path: '/api/v1/health',
        target: 'health-service:8080/health',
        isEnabled: false,
        requestCount: 234,
        middleware: ['cors'],
      ),
    ];
  }
}

// Providers
final apiGatewayServiceProvider = Provider<ApiGatewayService>((ref) {
  return ApiGatewayService();
});

final gatewaysProvider = FutureProvider<List<ApiGateway>>((ref) async {
  final service = ref.watch(apiGatewayServiceProvider);
  return service.fetchGateways();
});

final selectedGatewayProvider = StateProvider<ApiGateway?>((ref) => null);

final routesProvider = FutureProvider.family<List<ApiRoute>, String>((
  ref,
  gatewayId,
) async {
  final service = ref.watch(apiGatewayServiceProvider);
  return service.fetchRoutes(gatewayId);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredGatewaysProvider = Provider<AsyncValue<List<ApiGateway>>>((ref) {
  final gatewaysAsync = ref.watch(gatewaysProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return gatewaysAsync.when(
    data: (gateways) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(gateways);
      }
      final filtered =
          gateways
              .where(
                (gateway) =>
                    gateway.name.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    gateway.endpoint.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    gateway.tags.any(
                      (tag) =>
                          tag.toLowerCase().contains(searchQuery.toLowerCase()),
                    ),
              )
              .toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Main App
void main() {
  runApp(const ProviderScope(child: ApiGatewayApp()));
}

class ApiGatewayApp extends StatelessWidget {
  const ApiGatewayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iket  Console',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(elevation: 2, margin: EdgeInsets.all(8)),
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 1),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.dark,
        ),
        cardTheme: const CardThemeData(elevation: 2, margin: EdgeInsets.all(8)),
      ),
      home: const ApiGatewayDashboard(),
    );
  }
}

// Main Dashboard
class ApiGatewayDashboard extends ConsumerWidget {
  const ApiGatewayDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iket  Management Console'),
        actions: [
          IconButton(
            onPressed: () => ref.refresh(gatewaysProvider),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _showCreateGatewayDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('New Gateway'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 1200) {
            return const MobileLayout();
          } else {
            return const DesktopLayout();
          }
        },
      ),
    );
  }

  void _showCreateGatewayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateGatewayDialog(),
    );
  }
}

// Desktop Layout
class DesktopLayout extends ConsumerWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Left Panel - Gateway List
        SizedBox(
          width: 400,
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search gateways...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                ),
              ),
              // Gateway List
              const Expanded(child: GatewayList()),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Right Panel - Gateway Details
        const Expanded(child: GatewayDetails()),
      ],
    );
  }
}

// Mobile Layout
class MobileLayout extends ConsumerWidget {
  const MobileLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGateway = ref.watch(selectedGatewayProvider);

    if (selectedGateway != null) {
      return const GatewayDetails();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search gateways...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
          ),
        ),
        const Expanded(child: GatewayList()),
      ],
    );
  }
}

// Gateway List Widget
class GatewayList extends ConsumerWidget {
  const GatewayList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gatewaysAsync = ref.watch(filteredGatewaysProvider);

    return gatewaysAsync.when(
      data: (gateways) {
        return ListView.builder(
          itemCount: gateways.length,
          itemBuilder: (context, index) {
            final gateway = gateways[index];
            return GatewayCard(gateway: gateway);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading gateways: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(gatewaysProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
    );
  }
}

// Gateway Card Widget
/* class GatewayCard extends ConsumerWidget {
  final ApiGateway gateway;

  const GatewayCard({super.key, required this.gateway});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGateway = ref.watch(selectedGatewayProvider);
    final isSelected = selectedGateway?.id == gateway.id;

    return Card(
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () {
          ref.read(selectedGatewayProvider.notifier).state = gateway;
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
        method.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
} */

// Dialog Widgets
class CreateGatewayDialog extends StatefulWidget {
  const CreateGatewayDialog({super.key});

  @override
  State<CreateGatewayDialog> createState() => _CreateGatewayDialogState();
}

class _CreateGatewayDialogState extends State<CreateGatewayDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _endpointController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _endpointController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Gateway'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Gateway Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a gateway name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endpointController,
                decoration: const InputDecoration(
                  labelText: 'Endpoint URL',
                  border: OutlineInputBorder(),
                  hintText: 'https://api.example.com',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an endpoint URL';
                  }
                  if (!Uri.tryParse(value)!.hasAbsolutePath == true) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma-separated)',
                  border: OutlineInputBorder(),
                  hintText: 'production, v1.0, api',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _createGateway, child: const Text('Create')),
      ],
    );
  }

  void _createGateway() {
    if (_formKey.currentState!.validate()) {
      // Handle gateway creation logic here
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gateway "${_nameController.text}" created successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class AddRouteDialog extends StatefulWidget {
  const AddRouteDialog({super.key});

  @override
  State<AddRouteDialog> createState() => _AddRouteDialogState();
}

class _AddRouteDialogState extends State<AddRouteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pathController = TextEditingController();
  final _targetController = TextEditingController();
  String _selectedMethod = 'GET';
  final List<String> _selectedMiddleware = [];

  final List<String> _availableMethods = [
    'GET',
    'POST',
    'PUT',
    'DELETE',
    'PATCH',
    'OPTIONS',
  ];
  final List<String> _availableMiddleware = [
    'auth',
    'rate-limit',
    'cors',
    'validation',
    'logging',
    'compression',
    'cache',
  ];

  @override
  void dispose() {
    _pathController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Route'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: DropdownButtonFormField<String>(
                      value: _selectedMethod,
                      decoration: const InputDecoration(
                        labelText: 'Method',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          _availableMethods.map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _pathController,
                      decoration: const InputDecoration(
                        labelText: 'Path',
                        border: OutlineInputBorder(),
                        hintText: '/api/v1/users',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a path';
                        }
                        if (!value.startsWith('/')) {
                          return 'Path must start with /';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetController,
                decoration: const InputDecoration(
                  labelText: 'Target Service',
                  border: OutlineInputBorder(),
                  hintText: 'users-service:8080/users',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a target service';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Middleware',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children:
                        _availableMiddleware.map((middleware) {
                          final isSelected = _selectedMiddleware.contains(
                            middleware,
                          );
                          return FilterChip(
                            label: Text(middleware),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedMiddleware.add(middleware);
                                } else {
                                  _selectedMiddleware.remove(middleware);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _addRoute, child: const Text('Add Route')),
      ],
    );
  }

  void _addRoute() {
    if (_formKey.currentState!.validate()) {
      // Handle route creation logic here
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Route "$_selectedMethod ${_pathController.text}" added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// Loading and Error Widgets
class LoadingWidget extends StatelessWidget {
  final String message;

  const LoadingWidget({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

// Search and Filter Components
class AdvancedSearchPanel extends ConsumerStatefulWidget {
  const AdvancedSearchPanel({super.key});

  @override
  ConsumerState<AdvancedSearchPanel> createState() =>
      _AdvancedSearchPanelState();
}

class _AdvancedSearchPanelState extends ConsumerState<AdvancedSearchPanel> {
  String _statusFilter = 'all';
  String _sortBy = 'name';
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Advanced Filters'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _statusFilter,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('All Statuses'),
                        ),
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(
                          value: 'inactive',
                          child: Text('Inactive'),
                        ),
                        DropdownMenuItem(value: 'error', child: Text('Error')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _statusFilter = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sortBy,
                      decoration: const InputDecoration(
                        labelText: 'Sort By',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'name', child: Text('Name')),
                        DropdownMenuItem(
                          value: 'requests',
                          child: Text('Total Requests'),
                        ),
                        DropdownMenuItem(
                          value: 'response_time',
                          child: Text('Response Time'),
                        ),
                        DropdownMenuItem(
                          value: 'last_deployed',
                          child: Text('Last Deployed'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _sortAscending = !_sortAscending;
                      });
                    },
                    icon: Icon(
                      _sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                    ),
                    tooltip:
                        _sortAscending ? 'Sort Ascending' : 'Sort Descending',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Apply filters
                    },
                    child: const Text('Apply Filters'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _statusFilter = 'all';
                        _sortBy = 'name';
                        _sortAscending = true;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Status Chip Widget
class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'inactive':
        color = Colors.grey;
        icon = Icons.pause_circle;
        break;
      case 'error':
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        color = Colors.orange;
        icon = Icons.help;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color, width: 1),
      backgroundColor: color.withOpacity(0.1),
    );
  }
}

// Gateway Details Widget
class GatewayDetails extends ConsumerWidget {
  const GatewayDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGateway = ref.watch(selectedGatewayProvider);

    if (selectedGateway == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.api, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Select a gateway to view details',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                if (MediaQuery.of(context).size.width < 1200)
                  IconButton(
                    onPressed: () {
                      ref.read(selectedGatewayProvider.notifier).state = null;
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedGateway.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedGateway.endpoint,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: selectedGateway.status),
                const SizedBox(width: 8),
                PopupMenuButton(
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit Gateway'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'deploy',
                          child: ListTile(
                            leading: Icon(Icons.publish),
                            title: Text('Deploy'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
          // Tabs
          const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Routes'),
              Tab(text: 'Settings'),
            ],
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              children: [
                GatewayOverview(gateway: selectedGateway),
                GatewayRoutes(gateway: selectedGateway),
                GatewaySettings(gateway: selectedGateway),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Gateway Overview Tab
class GatewayOverview extends StatelessWidget {
  final ApiGateway gateway;

  const GatewayOverview({super.key, required this.gateway});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics Cards
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Total Requests',
                  value: gateway.totalRequests.toString(),
                  icon: Icons.analytics,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'Avg Response Time',
                  value: '${gateway.avgResponseTime.toStringAsFixed(1)}ms',
                  icon: Icons.timer,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Information Section
          Text(
            'Gateway Information',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          InfoRow(label: 'Gateway ID', value: gateway.id),
          InfoRow(label: 'Endpoint', value: gateway.endpoint),
          InfoRow(label: 'Status', value: gateway.status),
          InfoRow(
            label: 'Last Deployed',
            value: _formatDateTime(gateway.lastDeployed),
          ),
          InfoRow(label: 'Tags', value: gateway.tags.join(', ')),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Gateway Routes Tab
class GatewayRoutes extends ConsumerWidget {
  final ApiGateway gateway;

  const GatewayRoutes({super.key, required this.gateway});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(routesProvider(gateway.id));

    return Column(
      children: [
        // Header with Add Route button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text('API Routes', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddRouteDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Route'),
              ),
            ],
          ),
        ),
        // Routes List
        Expanded(
          child: routesAsync.when(
            data: (routes) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  final route = routes[index];
                  return RouteCard(route: route);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) =>
                    Center(child: Text('Error loading routes: $error')),
          ),
        ),
      ],
    );
  }

  void _showAddRouteDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddRouteDialog());
  }
}

// Gateway Settings Tab
class GatewaySettings extends StatelessWidget {
  final ApiGateway gateway;

  const GatewaySettings({super.key, required this.gateway});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gateway Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Configuration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: gateway.name,
                    decoration: const InputDecoration(
                      labelText: 'Gateway Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: gateway.endpoint,
                    decoration: const InputDecoration(
                      labelText: 'Endpoint URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Save Changes'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widgets
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class RouteCard extends StatelessWidget {
  final ApiRoute route;

  const RouteCard({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MethodChip(method: route.method),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    route.path,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
                Switch(
                  value: route.isEnabled,
                  onChanged: (value) {
                    // Handle route enable/disable
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Target: ${route.target}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${route.requestCount} requests',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                ...route.middleware.map(
                  (middleware) => Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Chip(
                      label: Text(middleware),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MethodChip extends StatelessWidget {
  final String method;

  const MethodChip({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (method.toUpperCase()) {
      case 'GET':
        color = Colors.green;
        break;
      case 'POST':
        color = Colors.blue;
        break;
      case 'PUT':
        color = Colors.orange;
        break;
      case 'DELETE':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class GatewayCard extends ConsumerWidget {
  final ApiGateway gateway;

  const GatewayCard({super.key, required this.gateway});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGateway = ref.watch(selectedGatewayProvider);
    final isSelected = selectedGateway?.id == gateway.id;

    return Card(
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () {
          ref.read(selectedGatewayProvider.notifier).state = gateway;
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      gateway.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  StatusChip(status: gateway.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                gateway.endpoint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${gateway.totalRequests} requests',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${gateway.avgResponseTime.toStringAsFixed(1)}ms avg',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (gateway.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children:
                      gateway.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/* 

class GatewaySettings extends StatefulWidget {
  final ApiGateway gateway;

  const GatewaySettings({super.key, required this.gateway});

  @override
  State<GatewaySettings> createState() => _GatewaySettingsState();
}

class _GatewaySettingsState extends State<GatewaySettings> {
  late TextEditingController _nameController;
  late TextEditingController _endpointController;
  late TextEditingController _tagsController;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gateway.name);
    _endpointController = TextEditingController(text: widget.gateway.endpoint);
    _tagsController = TextEditingController(text: widget.gateway.tags.join(', '));
    _selectedStatus = widget.gateway.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _endpointController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gateway Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Configuration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Gateway Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _endpointController,
                    decoration: const InputDecoration(
                      labelText: 'Endpoint URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                      DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _saveSettings,
                        child: const Text('Save Changes'),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: _resetSettings,
                        child: const Text('Reset'),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: _showDeleteDialog,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Delete Gateway'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advanced Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('Rate limiting, CORS, and other advanced settings would go here.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );
  }

  void _resetSettings() {
    setState(() {
      _nameController.text = widget.gateway.name;
      _endpointController.text = widget.gateway.endpoint;
      _tagsController.text = widget.gateway.tags.join(', ');
      _selectedStatus = widget.gateway.status;
    });
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Gateway?'),
        content: const Text('Are you sure you want to delete this gateway? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gateway deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
 */
