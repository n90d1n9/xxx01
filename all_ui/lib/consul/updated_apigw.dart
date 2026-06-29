
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class ConsulService {
  final String id;
  final String name;
  final String status;
  final String address;
  final int port;
  final Map<String, String> tags;
  final DateTime lastUpdated;

  ConsulService({
    required this.id,
    required this.name,
    required this.status,
    required this.address,
    required this.port,
    required this.tags,
    required this.lastUpdated,
  });
}

class ApiRoute {
  final String id;
  final String path;
  final String method;
  final String targetServiceId;
  final String status;
  final Map<String, String> policies;
  final Map<String, dynamic> rateLimit;
  final bool authRequired;
  final DateTime lastUpdated;

  ApiRoute({
    required this.id,
    required this.path,
    required this.method,
    required this.targetServiceId,
    required this.status,
    required this.policies,
    required this.rateLimit,
    required this.authRequired,
    required this.lastUpdated,
  });
}

// Enums
enum AdminTab { services, apiGateway }

// Providers
final selectedTabProvider = StateProvider<AdminTab>((ref) => AdminTab.services);
final selectedEnvironmentProvider = StateProvider<String>((ref) => 'Production');

final consulServicesProvider = FutureProvider<List<ConsulService>>((ref) {
  final environment = ref.watch(selectedEnvironmentProvider);
  // In a real app, this would fetch data from the Consul API based on environment
  return Future.delayed(
    const Duration(seconds: 1),
    () => _getMockServices(environment),
  );
});

final apiRoutesProvider = FutureProvider<List<ApiRoute>>((ref) {
  final environment = ref.watch(selectedEnvironmentProvider);
  // In a real app, this would fetch data from the Iket 
  return Future.delayed(
    const Duration(seconds: 1),
    () => _getMockApiRoutes(environment),
  );
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredServicesProvider = Provider<AsyncValue<List<ConsulService>>>((ref) {
  final servicesAsyncValue = ref.watch(consulServicesProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  
  return servicesAsyncValue.whenData((services) {
    if (searchQuery.isEmpty) return services;
    return services.where((service) {
      return service.name.toLowerCase().contains(searchQuery) ||
          service.id.toLowerCase().contains(searchQuery) ||
          service.tags.values.any((tag) => tag.toLowerCase().contains(searchQuery));
    }).toList();
  });
});

final filteredApiRoutesProvider = Provider<AsyncValue<List<ApiRoute>>>((ref) {
  final routesAsyncValue = ref.watch(apiRoutesProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  
  return routesAsyncValue.whenData((routes) {
    if (searchQuery.isEmpty) return routes;
    return routes.where((route) {
      return route.path.toLowerCase().contains(searchQuery) ||
          route.id.toLowerCase().contains(searchQuery) ||
          route.targetServiceId.toLowerCase().contains(searchQuery);
    }).toList();
  });
});

final selectedServiceProvider = StateProvider<String?>((ref) => null);
final selectedRouteProvider = StateProvider<String?>((ref) => null);

// Utility functions for mock data
List<ConsulService> _getMockServices(String environment) {
  final baseServices = [
    ConsulService(
      id: 'auth-service-001',
      name: 'Authentication Service',
      status: 'healthy',
      address: '10.0.12.45',
      port: 8080,
      tags: {'version': 'v1.2.3', 'team': 'security'},
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ConsulService(
      id: 'payment-service-001',
      name: 'Payment Processing',
      status: 'healthy',
      address: '10.0.12.46',
      port: 8081,
      tags: {'version': 'v2.0.1', 'team': 'finance'},
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    ConsulService(
      id: 'user-service-001',
      name: 'User Management',
      status: 'warning',
      address: '10.0.12.47',
      port: 8082,
      tags: {'version': 'v1.5.0', 'team': 'core'},
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    ConsulService(
      id: 'notification-service-001',
      name: 'Notification Service',
      status: 'critical',
      address: '10.0.12.48',
      port: 8083,
      tags: {'version': 'v1.1.0', 'team': 'communications'},
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    ConsulService(
      id: 'inventory-service-001',
      name: 'Inventory Management',
      status: 'healthy',
      address: '10.0.12.49',
      port: 8084,
      tags: {'version': 'v1.3.5', 'team': 'logistics'},
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 7)),
    ),
  ];

  // Add environment-specific services
  if (environment == 'Development') {
    baseServices.add(
      ConsulService(
        id: 'test-service-001',
        name: 'Test Framework',
        status: 'healthy',
        address: '10.0.12.50',
        port: 8085,
        tags: {'version': 'v0.9.0', 'team': 'qa'},
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    );
  } else if (environment == 'Staging') {
    baseServices.add(
      ConsulService(
        id: 'metrics-service-001',
        name: 'Metrics Collector',
        status: 'warning',
        address: '10.0.12.51',
        port: 8086,
        tags: {'version': 'v1.0.1', 'team': 'devops'},
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
    );
  }

  return baseServices;
}

List<ApiRoute> _getMockApiRoutes(String environment) {
  final baseRoutes = [
    ApiRoute(
      id: 'route-auth-login',
      path: '/api/v1/auth/login',
      method: 'POST',
      targetServiceId: 'auth-service-001',
      status: 'active',
      policies: {'cors': 'enabled', 'ip-filtering': 'disabled'},
      rateLimit: {'limit': 100, 'period': '1m'},
      authRequired: false,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ApiRoute(
      id: 'route-users-get',
      path: '/api/v1/users',
      method: 'GET',
      targetServiceId: 'user-service-001',
      status: 'active',
      policies: {'cors': 'enabled', 'cache': 'enabled'},
      rateLimit: {'limit': 500, 'period': '1m'},
      authRequired: true,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ApiRoute(
      id: 'route-users-profile',
      path: '/api/v1/users/profile',
      method: 'GET',
      targetServiceId: 'user-service-001',
      status: 'active',
      policies: {'cors': 'enabled', 'cache': 'enabled'},
      rateLimit: {'limit': 300, 'period': '1m'},
      authRequired: true,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    ApiRoute(
      id: 'route-payment-process',
      path: '/api/v1/payments/process',
      method: 'POST',
      targetServiceId: 'payment-service-001',
      status: 'active',
      policies: {'cors': 'enabled', 'ip-filtering': 'enabled'},
      rateLimit: {'limit': 50, 'period': '1m'},
      authRequired: true,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    ApiRoute(
      id: 'route-notifications-send',
      path: '/api/v1/notifications/send',
      method: 'POST',
      targetServiceId: 'notification-service-001',
      status: 'inactive',
      policies: {'cors': 'enabled'},
      rateLimit: {'limit': 200, 'period': '1m'},
      authRequired: true,
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ApiRoute(
      id: 'route-inventory-check',
      path: '/api/v1/inventory/check',
      method: 'GET',
      targetServiceId: 'inventory-service-001',
      status: 'active',
      policies: {'cors': 'enabled', 'cache': 'enabled'},
      rateLimit: {'limit': 1000, 'period': '1m'},
      authRequired: true,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // Add environment-specific routes
  if (environment == 'Development') {
    baseRoutes.add(
      ApiRoute(
        id: 'route-test-ping',
        path: '/api/test/ping',
        method: 'GET',
        targetServiceId: 'test-service-001',
        status: 'active',
        policies: {'cors': 'enabled'},
        rateLimit: {'limit': 5000, 'period': '1m'},
        authRequired: false,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    );
  } else if (environment == 'Staging') {
    baseRoutes.add(
      ApiRoute(
        id: 'route-metrics-collect',
        path: '/api/metrics/collect',
        method: 'POST',
        targetServiceId: 'metrics-service-001',
        status: 'active',
        policies: {'cors': 'enabled'},
        rateLimit: {'limit': 300, 'period': '1m'},
        authRequired: true,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    );
  }

  return baseRoutes;
}

class ConsulAdminScreen extends ConsumerWidget {
  const ConsulAdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final selectedEnvironment = ref.watch(selectedEnvironmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedTab == AdminTab.services
            ? 'Consul Service Discovery'
            : 'Iket  Administration'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (selectedTab == AdminTab.services) {
                ref.refresh(consulServicesProvider);
              } else {
                ref.refresh(apiRoutesProvider);
              }
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Show settings dialog in a real app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings not implemented in this demo')),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabSelector(context, ref, selectedTab),
          _buildEnvironmentSelector(context, ref, selectedEnvironment),
          _buildSearchBar(context, ref),
          Expanded(
            child: selectedTab == AdminTab.services
                ? _buildServicesContent(context, ref)
                : _buildApiGatewayContent(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedTab == AdminTab.services) {
            // Show add service dialog in a real app
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add service feature not implemented in this demo')),
            );
          } else {
            // Show add API route dialog in a real app
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add API route feature not implemented in this demo')),
            );
          }
        },
        child: const Icon(Icons.add),
        tooltip: selectedTab == AdminTab.services ? 'Register new service' : 'Create new route',
      ),
    );
  }

  Widget _buildTabSelector(BuildContext context, WidgetRef ref, AdminTab selectedTab) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => ref.read(selectedTabProvider.notifier).state = AdminTab.services,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selectedTab == AdminTab.services
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.device_hub,
                      color: selectedTab == AdminTab.services
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Services',
                      style: TextStyle(
                        fontWeight: selectedTab == AdminTab.services
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selectedTab == AdminTab.services
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => ref.read(selectedTabProvider.notifier).state = AdminTab.apiGateway,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selectedTab == AdminTab.apiGateway
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.api,
                      color: selectedTab == AdminTab.apiGateway
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Iket ',
                      style: TextStyle(
                        fontWeight: selectedTab == AdminTab.apiGateway
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selectedTab == AdminTab.apiGateway
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentSelector(
      BuildContext context, WidgetRef ref, String selectedEnvironment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          const Icon(Icons.public, size: 24),
          const SizedBox(width: 16),
          Text('Environment:', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: selectedEnvironment,
            items: ['Development', 'Staging', 'Production']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                ref.read(selectedEnvironmentProvider.notifier).state = newValue;
              }
            },
            style: Theme.of(context).textTheme.bodyLarge,
            underline: Container(
              height: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: ref.watch(selectedTabProvider) == AdminTab.services
              ? 'Search services by name, ID, or tags'
              : 'Search routes by path, ID, or service',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
      ),
    );
  }

  // Services Tab Content
  Widget _buildServicesContent(BuildContext context, WidgetRef ref) {
    final filteredServices = ref.watch(filteredServicesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildServiceStats(filteredServices),
        Expanded(
          child: _buildServiceList(context, ref),
        ),
      ],
    );
  }

  Widget _buildServiceStats(AsyncValue<List<ConsulService>> filteredServices) {
    return filteredServices.when(
      data: (services) {
        final healthyCount = services.where((s) => s.status == 'healthy').length;
        final warningCount = services.where((s) => s.status == 'warning').length;
        final criticalCount = services.where((s) => s.status == 'critical').length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildStatCard('Healthy', healthyCount, Colors.green),
              const SizedBox(width: 8),
              _buildStatCard('Warning', warningCount, Colors.orange),
              const SizedBox(width: 8),
              _buildStatCard('Critical', criticalCount, Colors.red),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 56),
      error: (_, __) => const SizedBox(height: 56),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceList(BuildContext context, WidgetRef ref) {
    final filteredServices = ref.watch(filteredServicesProvider);
    final selectedServiceId = ref.watch(selectedServiceProvider);

    return filteredServices.when(
      data: (services) {
        if (services.isEmpty) {
          return const Center(
            child: Text('No services match your criteria'),
          );
        }

        return ListView.builder(
          itemCount: services.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final service = services[index];
            final isSelected = service.id == selectedServiceId;

            return Card(
              elevation: isSelected ? 4 : 1,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected
                    ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                    : BorderSide.none,
              ),
              child: InkWell(
                onTap: () {
                  ref.read(selectedServiceProvider.notifier).state =
                      isSelected ? null : service.id;
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _getStatusIcon(service.status),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              service.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              // Handle menu actions in a real app
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$value not implemented in this demo')),
                              );
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Edit Service'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'restart',
                                child: Text('Restart Service'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'deregister',
                                child: Text('Deregister Service'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ID: ${service.id}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Endpoint: ${service.address}:${service.port}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: service.tags.entries.map((entry) {
                          return Chip(
                            label: Text('${entry.key}: ${entry.value}'),
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            padding: EdgeInsets.zero,
                          );
                        }).toList(),
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildDetailSection(context, service),
                      ],
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          'Last updated: ${_formatDateTime(service.lastUpdated)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context, ConsulService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Details',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.health_and_safety),
                label: const Text('Health Checks'),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.show_chart),
                label: const Text('Metrics'),
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text('Configuration'),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text('History'),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Iket  Tab Content
  Widget _buildApiGatewayContent(BuildContext context, WidgetRef ref) {
    final filteredRoutes = ref.watch(filteredApiRoutesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildApiGatewayStats(filteredRoutes),
        Expanded(
          child: _buildApiRoutesList(context, ref),
        ),
      ],
    );
  }

  Widget _buildApiGatewayStats(AsyncValue<List<ApiRoute>> filteredRoutes) {
    return filteredRoutes.when(
      data: (routes) {
        final activeCount = routes.where((r) => r.status == 'active').length;
        final inactiveCount = routes.where((r) => r.status == 'inactive').length;
        final authRequiredCount = routes.where((r) => r.authRequired).length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildStatCard('Active', activeCount, Colors.green),
              const SizedBox(width: 8),
              _buildStatCard('Inactive', inactiveCount, Colors.grey),
              const SizedBox(width: 8),
              _buildStatCard('Auth Required', authRequiredCount, Colors.blue),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 56),
      error: (_, __) => const SizedBox(height: 56),
    );
  }

  Widget _buildApiRoutesList(BuildContext context, WidgetRef ref) {
    final filteredRoutes = ref.watch(filteredApiRoutesProvider);
    final selectedRouteId = ref.watch(selectedRouteProvider);

    return filteredRoutes.when(
      data: (routes) {
        if (routes.isEmpty) {
          return const Center(
            child: Text('No API routes match your criteria'),
          );
        }

        return ListView.builder(
          itemCount: routes.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final route = routes[index];
            final isSelected = route.id == selectedRouteId;

            return Card(
              elevation: isSelected ? 4 : 1,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected
                    ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                    : BorderSide.none,
              ),
              child: InkWell(
                onTap: () {
                  ref.read(selectedRouteProvider.notifier).state =
                      isSelected ? null : route.id;
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _getApiMethodBadge(route.method),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              route.path,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Switch(
                            value: route.status == 'active',
                            onChanged: (value) {
                              // In a real app, this would update the route status
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    value
                                        ? 'Route would be activated'
                                        : 'Route would be deactivated',
                                  ),
                                ),
                              );
                            },
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              // Handle menu actions in a real app
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$value not implemented in this demo')),
                              );
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Edit Route'),
```