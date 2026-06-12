// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/legacy.dart';

void main() {
  runApp(const ProviderScope(child: ConsulManagerApp()));
}

class ConsulManagerApp extends StatelessWidget {
  const ConsulManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consul Manager',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const DashboardScreen(),
    );
  }
}

/* 
 {Node: 9388e819fc70, 
 CheckID: serfHealth,
 Name: Serf Health Status, 
 Status: passing, Notes: , 
 Output: Agent alive and reachable, 
 ServiceID: , 
 ServiceName: , 
 ServiceTags: [], Type: , 
 Interval: , 
 Timeout: , 
 ExposedPort: 0, 
 Definition: {}, 
 CreateIndex: 13, 
 ModifyIndex: 13}
 */
// lib/models/consul_health.dart
class ConsulHealth {
  final dynamic nodeId;
  final String serviceName;
  final dynamic status;
  final dynamic output;
  final DateTime lastChecked;

  ConsulHealth({
    required this.nodeId,
    required this.serviceName,
    required this.status,
    required this.output,
    required this.lastChecked,
  });

  factory ConsulHealth.fromJson(Map<String, dynamic> json) {
    print('json: $json');

    return ConsulHealth(
      //nodeId: json['Node']['ID'] ?? '',
      nodeId: json['Node'] ?? '',
      serviceName: json['ServiceName'] ?? '',
      status: json['Status'] ?? '',
      output: json['Output'] ?? '',
      lastChecked: DateTime.tryParse(json['CheckTime'] ?? '') ?? DateTime.now(),
    );
  }
}

// lib/models/consul_service.dart
class ConsulService {
  final String id;
  final String name;
  final String address;
  final int port;
  final Map<String, String> tags;

  ConsulService({
    required this.id,
    required this.name,
    required this.address,
    required this.port,
    required this.tags,
  });

  factory ConsulService.fromJson(Map<String, dynamic> json) {
    final tagsMap = <String, String>{};
    final tagsJson = json['Tags'] as Map<String, dynamic>?;
    if (tagsJson != null) {
      tagsJson.forEach((key, value) {
        if (value is String) {
          tagsMap[key] = value;
        }
      });
    }

    return ConsulService(
      id: json['ID'] ?? '',
      name: json['Service'] ?? '',
      address: json['Address'] ?? '',
      port: json['Port'] ?? 0,
      tags: tagsMap,
    );
  }
}

// lib/services/consul_api_service.dart

class ConsulApiService {
  final String baseUrl;
  final String token;
  final Logger logger;

  ConsulApiService({
    required this.baseUrl,
    required this.token,
    required this.logger,
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-Consul-Token': token,
  };

  Future<List<ConsulService>> getServices() async {
    try {
      logger.log('Fetching services from Consul');
      final response = await http.get(
        Uri.parse('$baseUrl/v1/catalog/services'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<ConsulService> services = [];

        for (final entry in data.entries) {
          final detailResponse = await http.get(
            Uri.parse('$baseUrl/v1/catalog/service/${entry.key}'),
            headers: _headers,
          );

          if (detailResponse.statusCode == 200) {
            final List<dynamic> serviceData = json.decode(detailResponse.body);
            for (final service in serviceData) {
              services.add(ConsulService.fromJson(service));
            }
          }
        }

        return services;
      } else {
        logger.logError(
          'Failed to fetch services: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to fetch services: ${response.statusCode}');
      }
    } catch (e) {
      logger.logError('Error fetching services: $e');
      rethrow;
    }
  }

  Future<List<ConsulHealth>> getHealthChecks() async {
    try {
      logger.log('Fetching health checks from Consul');
      final response = await http.get(
        Uri.parse('$baseUrl/v1/health/state/any'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(' data: $data');

        return data.map((check) => ConsulHealth.fromJson(check)).toList();
      } else {
        logger.logError(
          'Failed to fetch health checks: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Failed to fetch health checks: ${response.statusCode}',
        );
      }
    } catch (e) {
      logger.logError('Error fetching health checks: $e');
      rethrow;
    }
  }

  Future<void> registerService({
    required String name,
    required String id,
    required String address,
    required int port,
    Map<String, String>? tags,
  }) async {
    try {
      logger.log('Registering service in Consul: $name');
      final response = await http.put(
        Uri.parse('$baseUrl/v1/agent/service/register'),
        headers: _headers,
        body: json.encode({
          'ID': id,
          'Name': name,
          'Address': address,
          'Port': port,
          'Tags': tags,
        }),
      );

      if (response.statusCode != 200) {
        logger.logError(
          'Failed to register service: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to register service: ${response.statusCode}');
      }
    } catch (e) {
      logger.logError('Error registering service: $e');
      rethrow;
    }
  }

  Future<void> deregisterService(String serviceId) async {
    try {
      logger.log('Deregistering service from Consul: $serviceId');
      final response = await http.put(
        Uri.parse('$baseUrl/v1/agent/service/deregister/$serviceId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        logger.logError(
          'Failed to deregister service: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to deregister service: ${response.statusCode}');
      }
    } catch (e) {
      logger.logError('Error deregistering service: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getConsulMetrics() async {
    try {
      logger.log('Fetching Consul metrics');
      final response = await http.get(
        Uri.parse('$baseUrl/v1/agent/metrics'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        logger.logError(
          'Failed to fetch metrics: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to fetch metrics: ${response.statusCode}');
      }
    } catch (e) {
      logger.logError('Error fetching metrics: $e');
      rethrow;
    }
  }
}

// lib/providers/consul_providers.dart

final loggerProvider = Provider<Logger>((ref) => Logger());

final consulConfigProvider = Provider<Map<String, dynamic>>((ref) {
  // In a real app, this would be loaded from secure storage or env config
  return {
    'baseUrl': 'http://localhost:8500',
    'token': 'your-consul-token-here',
  };
});

final consulApiServiceProvider = Provider<ConsulApiService>((ref) {
  final config = ref.watch(consulConfigProvider);
  final logger = ref.watch(loggerProvider);
  return ConsulApiService(
    baseUrl: config['baseUrl'],
    token: config['token'],
    logger: logger,
  );
});

final servicesProvider = FutureProvider<List<ConsulService>>((ref) async {
  final consulApiService = ref.watch(consulApiServiceProvider);
  return consulApiService.getServices();
});

final healthChecksProvider = FutureProvider<List<ConsulHealth>>((ref) async {
  final consulApiService = ref.watch(consulApiServiceProvider);
  return consulApiService.getHealthChecks();
});

final consulMetricsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final consulApiService = ref.watch(consulApiServiceProvider);
  return consulApiService.getConsulMetrics();
});

final autoRefreshProvider = StateProvider<Duration>((ref) {
  // Default refresh rate: 30 seconds
  return const Duration(seconds: 30);
});

// lib/utils/logger.dart

enum LogLevel { info, warning, error, debug }

class Logger {
  void log(String message, {LogLevel level = LogLevel.info}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp][${level.name.toUpperCase()}] $message';

    // In a production app, you might want to use a proper logging framework
    if (kDebugMode) {
      print(logMessage);
    }

    // Store logs for later retrieval
    _logs.add(LogEntry(timestamp: timestamp, level: level, message: message));

    // Keep log size manageable
    if (_logs.length > maxLogEntries) {
      _logs.removeAt(0);
    }
  }

  void logError(String message) {
    log(message, level: LogLevel.error);
  }

  void logWarning(String message) {
    log(message, level: LogLevel.warning);
  }

  void logDebug(String message) {
    log(message, level: LogLevel.debug);
  }

  final List<LogEntry> _logs = [];
  final int maxLogEntries = 1000;

  List<LogEntry> getLogs({LogLevel? filterLevel}) {
    if (filterLevel == null) {
      return List.unmodifiable(_logs);
    }
    return _logs.where((log) => log.level == filterLevel).toList();
  }

  void clearLogs() {
    _logs.clear();
  }
}

class LogEntry {
  final String timestamp;
  final LogLevel level;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
  });
}

// lib/screens/dashboard_screen.dart

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final refreshInterval = ref.read(autoRefreshProvider);

      // Set up periodic refresh
      Future.delayed(refreshInterval, () {
        if (!mounted) return;

        ref.refresh(servicesProvider);
        ref.refresh(healthChecksProvider);
        ref.refresh(consulMetricsProvider);

        _startAutoRefresh();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ServicesScreen(),
      const HealthScreen(),
      const MetricsScreen(),
      const LogsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consul Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(servicesProvider);
              ref.refresh(healthChecksProvider);
              ref.refresh(consulMetricsProvider);
            },
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Services'),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            label: 'Metrics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Logs'),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Consumer(
          builder: (context, ref, _) {
            final refreshInterval = ref.watch(autoRefreshProvider);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Auto-refresh interval:'),
                DropdownButton<Duration>(
                  value: refreshInterval,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      ref.read(autoRefreshProvider.notifier).state = newValue;
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: Duration(seconds: 15),
                      child: Text('15 seconds'),
                    ),
                    DropdownMenuItem(
                      value: Duration(seconds: 30),
                      child: Text('30 seconds'),
                    ),
                    DropdownMenuItem(
                      value: Duration(minutes: 1),
                      child: Text('1 minute'),
                    ),
                    DropdownMenuItem(
                      value: Duration(minutes: 5),
                      child: Text('5 minutes'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// lib/screens/services_screen.dart

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      body: servicesAsync.when(
        data: (services) => _buildServicesList(context, ref, services),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading services: ${error.toString()}')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddServiceDialog(context, ref),
        child: const Icon(Icons.add),
        tooltip: 'Add Service',
      ),
    );
  }

  Widget _buildServicesList(
    BuildContext context,
    WidgetRef ref,
    List<ConsulService> services,
  ) {
    if (services.isEmpty) {
      return const Center(child: Text('No services found'));
    }

    return ListView.builder(
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(service.name),
            subtitle: Text('${service.address}:${service.port}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDeleteService(context, ref, service),
              tooltip: 'Remove Service',
            ),
            onTap: () => _showServiceDetails(context, service),
          ),
        );
      },
    );
  }

  void _showServiceDetails(BuildContext context, ConsulService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${service.id}'),
            Text('Address: ${service.address}'),
            Text('Port: ${service.port}'),
            const SizedBox(height: 10),
            const Text('Tags:'),
            if (service.tags.isEmpty)
              const Text('No tags')
            else
              ...service.tags.entries.map((e) => Text('${e.key}: ${e.value}')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteService(
    BuildContext context,
    WidgetRef ref,
    ConsulService service,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Service'),
        content: Text(
          'Are you sure you want to remove ${service.name} service?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final consulApiService = ref.read(consulApiServiceProvider);
                await consulApiService.deregisterService(service.id);
                ref.refresh(servicesProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Service ${service.name} removed')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to remove service: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final addressController = TextEditingController();
    final portController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Service Name'),
              ),
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: 'Service ID'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: portController,
                decoration: const InputDecoration(labelText: 'Port'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  idController.text.isEmpty ||
                  addressController.text.isEmpty ||
                  portController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All fields are required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.of(context).pop();

              try {
                final consulApiService = ref.read(consulApiServiceProvider);
                await consulApiService.registerService(
                  name: nameController.text,
                  id: idController.text,
                  address: addressController.text,
                  port: int.parse(portController.text),
                );
                ref.refresh(servicesProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Service ${nameController.text} registered'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to register service: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// lib/screens/health_screen.dart

class HealthScreen extends ConsumerWidget {
  const HealthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthChecksAsync = ref.watch(healthChecksProvider);

    return Scaffold(
      body: healthChecksAsync.when(
        data: (healthChecks) => _buildHealthChecksList(healthChecks),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading health checks: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildHealthChecksList(List<ConsulHealth> healthChecks) {
    print('>>>> $healthChecks');

    if (healthChecks.isEmpty) {
      return const Center(child: Text('No health checks found'));
    }

    final passingChecks = healthChecks
        .where((check) => check.status == 'passing')
        .toList();
    final warningChecks = healthChecks
        .where((check) => check.status == 'warning')
        .toList();
    final criticalChecks = healthChecks
        .where((check) => check.status == 'critical')
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(passingChecks, warningChecks, criticalChecks),
          if (criticalChecks.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Critical Checks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...criticalChecks.map(
              (check) => _buildHealthCheckCard(check, Colors.red),
            ),
          ],
          if (warningChecks.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Warning Checks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...warningChecks.map(
              (check) => _buildHealthCheckCard(check, Colors.orange),
            ),
          ],
          if (passingChecks.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Passing Checks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...passingChecks.map(
              (check) => _buildHealthCheckCard(check, Colors.green),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    List<ConsulHealth> passingChecks,
    List<ConsulHealth> warningChecks,
    List<ConsulHealth> criticalChecks,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatusIndicator(
                    'Passing',
                    passingChecks.length,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatusIndicator(
                    'Warning',
                    warningChecks.length,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatusIndicator(
                    'Critical',
                    criticalChecks.length,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildHealthCheckCard(ConsulHealth check, Color statusColor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(Icons.check_circle, color: Colors.white),
        ),
        title: Text(
          check.serviceName.isEmpty ? 'Node Check' : check.serviceName,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${check.status}'),
            Text('Node: ${check.nodeId}'),
            Text(
              'Last Check: ${check.lastChecked.toLocal().toString().substring(0, 19)}',
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () => _showHealthCheckDetails(check),
      ),
    );
  }

  void _showHealthCheckDetails(ConsulHealth check) {
    // This would be implemented to show a dialog with full details
  }
}

// lib/screens/metrics_screen.dart

class MetricsScreen extends ConsumerWidget {
  const MetricsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(consulMetricsProvider);

    return Scaffold(
      body: metricsAsync.when(
        data: (metrics) => _buildMetricsView(metrics),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading metrics: ${error.toString()}')),
      ),
    );
  }

  Widget _buildMetricsView(Map<String, dynamic> metrics) {
    final gauges = metrics['Gauges'] as List<dynamic>? ?? [];
    final counters = metrics['Counters'] as List<dynamic>? ?? [];
    final samples = metrics['Samples'] as List<dynamic>? ?? [];

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Gauges'),
              Tab(text: 'Counters'),
              Tab(text: 'Samples'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildGaugesList(gauges),
                _buildCountersList(counters),
                _buildSamplesList(samples),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaugesList(List<dynamic> gauges) {
    if (gauges.isEmpty) {
      return const Center(child: Text('No gauges available'));
    }

    return ListView.builder(
      itemCount: gauges.length,
      itemBuilder: (context, index) {
        final gauge = gauges[index];
        return ListTile(
          title: Text(gauge['Name'] ?? 'Unknown'),
          subtitle: Text('Value: ${gauge['Value']}'),
        );
      },
    );
  }

  Widget _buildCountersList(List<dynamic> counters) {
    if (counters.isEmpty) {
      return const Center(child: Text('No counters available'));
    }

    return ListView.builder(
      itemCount: counters.length,
      itemBuilder: (context, index) {
        final counter = counters[index];
        return ListTile(
          title: Text(counter['Name'] ?? 'Unknown'),
          subtitle: Text('Count: ${counter['Count']}'),
        );
      },
    );
  }

  Widget _buildSamplesList(List<dynamic> samples) {
    if (samples.isEmpty) {
      return const Center(child: Text('No samples available'));
    }

    return ListView.builder(
      itemCount: samples.length,
      itemBuilder: (context, index) {
        final sample = samples[index];
        return ExpansionTile(
          title: Text(sample['Name'] ?? 'Unknown'),
          subtitle: Text('Rate: ${sample['Rate']}'),
          children: [
            ListTile(
              title: const Text('Statistics'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Min: ${sample['Min']}'),
                  Text('Max: ${sample['Max']}'),
                  Text('Mean: ${sample['Mean']}'),
                  Text('Stddev: ${sample['Stddev']}'),
                  Text('Sum: ${sample['Sum']}'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// lib/screens/logs_screen.dart

class LogsScreen extends ConsumerWidget {
  const LogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logger = ref.watch(loggerProvider);
    final logs = logger.getLogs();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Filter: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<LogLevel?>(
                  value: null,
                  hint: const Text('All Levels'),
                  onChanged: (LogLevel? newValue) {
                    // Implement filter logic
                    // This would typically use a state provider
                  },
                  items: [
                    ...LogLevel.values.map(
                      (level) => DropdownMenuItem(
                        value: level,
                        child: Text(level.name),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    logger.clearLogs();
                    // Force rebuild
                    ref.invalidate(loggerProvider);
                  },
                  tooltip: 'Clear Logs',
                ),
              ],
            ),
          ),
          Expanded(
            child: logs.isEmpty
                ? const Center(child: Text('No logs available'))
                : ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log =
                          logs[logs.length - 1 - index]; // Show newest first
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: _getLogLevelIcon(log.level),
                          title: Text(log.message),
                          subtitle: Text(log.timestamp),
                          dense: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _getLogLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return const Icon(Icons.info, color: Colors.blue);
      case LogLevel.warning:
        return const Icon(Icons.warning, color: Colors.orange);
      case LogLevel.error:
        return const Icon(Icons.error, color: Colors.red);
      case LogLevel.debug:
        return const Icon(Icons.code, color: Colors.grey);
    }
  }
}
