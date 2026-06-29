// pubspec.yaml dependencies:
/*
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  dio: ^5.3.2
  web_socket_channel: ^2.4.0
  fl_chart: ^0.64.0
  go_router: ^12.1.1
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1
  graphview: ^1.2.0
  animated_text_kit: ^4.2.2
  google_fonts: ^6.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  freezed: ^2.4.6
  riverpod_generator: ^2.3.9
*/

// lib/main.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

void main() {
  runApp(const ProviderScope(child: MicroserviceVisualizerApp()));
}

class MicroserviceVisualizerApp extends ConsumerWidget {
  const MicroserviceVisualizerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Microservice Topology Visualizer',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// lib/core/theme/app_theme.dart

class AppTheme {
  static const _primaryColor = Color(0xFF2196F3);
  static const _backgroundColor = Color(0xFF121212);
  static const _surfaceColor = Color(0xFF1E1E1E);
  static const _cardColor = Color(0xFF2D2D2D);

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: _backgroundColor,
    cardColor: _cardColor,
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: _surfaceColor,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    textTheme: GoogleFonts.robotoTextTheme(),
  );
}

// lib/app/router.dart

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/topology',
        builder: (context, state) => const TopologyScreen(),
      ),
      GoRoute(
        path: '/traces',
        builder: (context, state) => const TracesScreen(),
      ),
      GoRoute(
        path: '/metrics',
        builder: (context, state) => const MetricsScreen(),
      ),
    ],
  );
});

// lib/core/models/service_models.dart
class ServiceNode {
  final String id;
  final String name;
  final String namespace;
  final ServiceHealth health;
  final Map<String, dynamic> metadata;
  final List<String> dependencies;
  final double cpuUsage;
  final double memoryUsage;
  final int requestCount;
  final double errorRate;

  const ServiceNode({
    required this.id,
    required this.name,
    required this.namespace,
    required this.health,
    required this.metadata,
    this.dependencies = const [],
    this.cpuUsage = 0,
    this.memoryUsage = 0,
    this.requestCount = 0,
    this.errorRate = 0,
  });

  factory ServiceNode.fromJson(Map<String, dynamic> json) {
    return ServiceNode(
      id: json['id'] as String,
      name: json['name'] as String,
      namespace: json['namespace'] as String,
      health: ServiceHealth.values.firstWhere(
        (e) => e.toString() == 'ServiceHealth.${json['health']}',
        orElse: () => ServiceHealth.unknown,
      ),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      dependencies: List<String>.from(json['dependencies'] ?? []),
      cpuUsage: (json['cpuUsage'] ?? 0).toDouble(),
      memoryUsage: (json['memoryUsage'] ?? 0).toDouble(),
      requestCount: (json['requestCount'] ?? 0).toInt(),
      errorRate: (json['errorRate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'namespace': namespace,
      'health': health.toString().split('.').last,
      'metadata': metadata,
      'dependencies': dependencies,
      'cpuUsage': cpuUsage,
      'memoryUsage': memoryUsage,
      'requestCount': requestCount,
      'errorRate': errorRate,
    };
  }
}

class TrafficEdge {
  final String from;
  final String to;
  final double requestRate;
  final double errorRate;
  final double responseTime;
  final TrafficHealth health;

  const TrafficEdge({
    required this.from,
    required this.to,
    required this.requestRate,
    required this.errorRate,
    required this.responseTime,
    required this.health,
  });

  factory TrafficEdge.fromJson(Map<String, dynamic> json) {
    return TrafficEdge(
      from: json['from'] as String,
      to: json['to'] as String,
      requestRate: (json['requestRate'] ?? 0).toDouble(),
      errorRate: (json['errorRate'] ?? 0).toDouble(),
      responseTime: (json['responseTime'] ?? 0).toDouble(),
      health: TrafficHealth.values.firstWhere(
        (e) => e.toString() == 'TrafficHealth.${json['health']}',
        orElse: () => TrafficHealth.warning,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'requestRate': requestRate,
      'errorRate': errorRate,
      'responseTime': responseTime,
      'health': health.toString().split('.').last,
    };
  }
}

class Trace {
  final String traceId;
  final String operationName;
  final DateTime startTime;
  final Duration duration;
  final List<Span> spans;
  final TraceStatus status;

  const Trace({
    required this.traceId,
    required this.operationName,
    required this.startTime,
    required this.duration,
    required this.spans,
    required this.status,
  });

  factory Trace.fromJson(Map<String, dynamic> json) {
    return Trace(
      traceId: json['traceId'] as String,
      operationName: json['operationName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      duration: Duration(microseconds: json['duration'] ?? 0),
      spans: (json['spans'] as List).map((e) => Span.fromJson(e)).toList(),
      status: TraceStatus.values.firstWhere(
        (e) => e.toString() == 'TraceStatus.${json['status']}',
        orElse: () => TraceStatus.timeout,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'traceId': traceId,
      'operationName': operationName,
      'startTime': startTime.toIso8601String(),
      'duration': duration.inMicroseconds,
      'spans': spans.map((e) => e.toJson()).toList(),
      'status': status.toString().split('.').last,
    };
  }

  static Trace empty({
    required String traceId,
    required String operationName,
    required DateTime startTime,
    required Duration duration,
    required List<Span> spans,
    required TraceStatus status,
  }) {
    return Trace(
      traceId: traceId,
      operationName: operationName,
      startTime: startTime,
      duration: duration,
      spans: spans,
      status: status,
    );
  }
}

class Span {
  final String spanId;
  final String operationName;
  final String serviceName;
  final DateTime startTime;
  final Duration duration;
  final String? parentSpanId;
  final Map<String, dynamic> tags;
  final List<SpanLog> logs;

  const Span({
    required this.spanId,
    required this.operationName,
    required this.serviceName,
    required this.startTime,
    required this.duration,
    this.parentSpanId,
    required this.tags,
    this.logs = const [],
  });

  factory Span.fromJson(Map<String, dynamic> json) {
    return Span(
      spanId: json['spanId'] as String,
      operationName: json['operationName'] as String,
      serviceName: json['serviceName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      duration: Duration(microseconds: json['duration'] ?? 0),
      parentSpanId: json['parentSpanId'] as String?,
      tags: Map<String, dynamic>.from(json['tags'] as Map),
      logs:
          (json['logs'] as List?)?.map((e) => SpanLog.fromJson(e)).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spanId': spanId,
      'operationName': operationName,
      'serviceName': serviceName,
      'startTime': startTime.toIso8601String(),
      'duration': duration.inMicroseconds,
      if (parentSpanId != null) 'parentSpanId': parentSpanId,
      'tags': tags,
      'logs': logs.map((e) => e.toJson()).toList(),
    };
  }
}

class SpanLog {
  final DateTime timestamp;
  final Map<String, dynamic> fields;

  const SpanLog({required this.timestamp, required this.fields});

  factory SpanLog.fromJson(Map<String, dynamic> json) {
    return SpanLog(
      timestamp: DateTime.parse(json['timestamp'] as String),
      fields: Map<String, dynamic>.from(json['fields'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {'timestamp': timestamp.toIso8601String(), 'fields': fields};
  }
}

// Enum definitions (assuming these exist)

enum ServiceHealth { healthy, warning, critical, unknown }

enum TrafficHealth { healthy, warning, critical }

enum TraceStatus { success, error, timeout }

// lib/core/providers/otel_providers.dart
// OtelService provider
final otelServiceProvider = Provider<OtelService>((ref) {
  return OtelService();
});

// ServiceNodes provider
final serviceNodesProvider = StreamProvider<List<ServiceNode>>((ref) {
  final otelService = ref.watch(otelServiceProvider);
  return otelService.getServiceNodesStream();
});

// TrafficEdges provider
final trafficEdgesProvider = StreamProvider<List<TrafficEdge>>((ref) {
  final otelService = ref.watch(otelServiceProvider);
  return otelService.getTrafficEdgesStream();
});

// Traces provider
final tracesProvider = StreamProvider<List<Trace>>((ref) {
  final otelService = ref.watch(otelServiceProvider);
  return otelService.getTracesStream();
});

// lib/core/services/otel_service.dart

class OtelService {
  final Dio _dio = Dio();
  WebSocketChannel? _wsChannel;

  // Mock data generators for demo purposes
  final Random _random = Random();
  Timer? _mockDataTimer;

  OtelService() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _mockDataTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _generateMockData();
    });
  }

  final StreamController<List<ServiceNode>> _serviceNodesController =
      StreamController<List<ServiceNode>>.broadcast();
  final StreamController<List<TrafficEdge>> _trafficEdgesController =
      StreamController<List<TrafficEdge>>.broadcast();
  final StreamController<List<Trace>> _tracesController =
      StreamController<List<Trace>>.broadcast();

  Stream<List<ServiceNode>> getServiceNodesStream() =>
      _serviceNodesController.stream;
  Stream<List<TrafficEdge>> getTrafficEdgesStream() =>
      _trafficEdgesController.stream;
  Stream<List<Trace>> getTracesStream() => _tracesController.stream;

  void _generateMockData() {
    final nodes = _generateMockServiceNodes();
    final edges = _generateMockTrafficEdges(nodes);
    final traces = _generateMockTraces(nodes);

    _serviceNodesController.add(nodes);
    _trafficEdgesController.add(edges);
    _tracesController.add(traces);
  }

  List<ServiceNode> _generateMockServiceNodes() {
    final services = [
      'api-gateway',
      'user-service',
      'product-service',
      'order-service',
      'payment-service',
      'notification-service',
    ];

    return services
        .map(
          (service) => ServiceNode(
            id: service,
            name: service,
            namespace: 'production',
            health:
                ServiceHealth.values[_random.nextInt(
                  ServiceHealth.values.length,
                )],
            metadata: {'version': '1.0.0', 'replicas': _random.nextInt(5) + 1},
            cpuUsage: _random.nextDouble() * 100,
            memoryUsage: _random.nextDouble() * 100,
            requestCount: _random.nextInt(1000),
            errorRate: _random.nextDouble() * 10,
          ),
        )
        .toList();
  }

  List<TrafficEdge> _generateMockTrafficEdges(List<ServiceNode> nodes) {
    final edges = <TrafficEdge>[];
    for (int i = 0; i < nodes.length - 1; i++) {
      edges.add(
        TrafficEdge(
          from: nodes[i].id,
          to: nodes[i + 1].id,
          requestRate: _random.nextDouble() * 100,
          errorRate: _random.nextDouble() * 5,
          responseTime: _random.nextDouble() * 1000,
          health:
              TrafficHealth.values[_random.nextInt(
                TrafficHealth.values.length,
              )],
        ),
      );
    }
    return edges;
  }

  List<Trace> _generateMockTraces(List<ServiceNode> nodes) {
    return List.generate(10, (index) {
      final traceId = 'trace-${DateTime.now().millisecondsSinceEpoch}-$index';
      final spans =
          nodes
              .take(3)
              .map(
                (node) => Span(
                  spanId: 'span-$index-${node.id}',
                  operationName: 'HTTP GET /${node.name}',
                  serviceName: node.name,
                  startTime: DateTime.now().subtract(
                    Duration(seconds: _random.nextInt(60)),
                  ),
                  duration: Duration(milliseconds: _random.nextInt(1000)),
                  tags: {'http.method': 'GET', 'http.status_code': 200},
                ),
              )
              .toList();

      return Trace(
        traceId: traceId,
        operationName: 'User Request',
        startTime: DateTime.now().subtract(
          Duration(seconds: _random.nextInt(300)),
        ),
        duration: Duration(
          milliseconds: spans.fold(
            0,
            (sum, span) => sum + span.duration.inMilliseconds,
          ),
        ),
        spans: spans,
        status: TraceStatus.values[_random.nextInt(TraceStatus.values.length)],
      );
    });
  }

  void dispose() {
    _mockDataTimer?.cancel();
    _wsChannel?.sink.close();
    _serviceNodesController.close();
    _trafficEdgesController.close();
    _tracesController.close();
  }
}

// lib/features/dashboard/presentation/dashboard_screen.dart

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceNodesAsync = ref.watch(serviceNodesProvider);
    final trafficEdgesAsync = ref.watch(trafficEdgesProvider);

    return Scaffold(
      body: Row(
        children: [
          const CustomNavigationRail(selectedIndex: 0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Microservice Topology Dashboard',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: serviceNodesAsync.when(
                      data:
                          (nodes) => trafficEdgesAsync.when(
                            data:
                                (edges) => _buildDashboardContent(
                                  context,
                                  nodes,
                                  edges,
                                ),
                            loading:
                                () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            error:
                                (error, stack) =>
                                    Center(child: Text('Error: $error')),
                          ),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, stack) =>
                              Center(child: Text('Error: $error')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, nodes, edges) {
    final totalServices = nodes.length;
    final healthyServices =
        nodes.where((n) => n.health == ServiceHealth.healthy).length;
    final avgResponseTime =
        edges.isEmpty
            ? 0.0
            : edges.map((e) => e.responseTime).reduce((a, b) => a + b) /
                edges.length;
    final totalRequests = nodes
        .map((n) => n.requestCount)
        .fold(0, (a, b) => a + b);

    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        MetricCard(
          title: 'Total Services',
          value: totalServices.toString(),
          icon: Icons.hub_outlined,
          color: Colors.blue,
          onTap: () => context.go('/topology'),
        ),
        MetricCard(
          title: 'Healthy Services',
          value: '$healthyServices/$totalServices',
          icon: Icons.health_and_safety_outlined,
          color: Colors.green,
        ),
        MetricCard(
          title: 'Avg Response Time',
          value: '${avgResponseTime.toStringAsFixed(0)}ms',
          icon: Icons.timer_outlined,
          color: Colors.orange,
        ),
        MetricCard(
          title: 'Total Requests',
          value: totalRequests.toString(),
          icon: Icons.analytics_outlined,
          color: Colors.purple,
          onTap: () => context.go('/metrics'),
        ),
        MetricCard(
          title: 'View Topology',
          value: 'Visualize',
          icon: Icons.account_tree_outlined,
          color: Colors.teal,
          onTap: () => context.go('/topology'),
        ),
        MetricCard(
          title: 'Distributed Traces',
          value: 'Analyze',
          icon: Icons.route_outlined,
          color: Colors.indigo,
          onTap: () => context.go('/traces'),
        ),
      ],
    );
  }
}

// lib/features/shared/widgets/navigation_rail.dart

class CustomNavigationRail extends StatelessWidget {
  final int selectedIndex;

  const CustomNavigationRail({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/dashboard');
            break;
          case 1:
            context.go('/topology');
            break;
          case 2:
            context.go('/traces');
            break;
          case 3:
            context.go('/metrics');
            break;
        }
      },
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.account_tree_outlined),
          selectedIcon: Icon(Icons.account_tree),
          label: Text('Topology'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.route_outlined),
          selectedIcon: Icon(Icons.route),
          label: Text('Traces'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: Text('Metrics'),
        ),
      ],
    );
  }
}

// lib/features/shared/widgets/metric_card.dart

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/features/topology/presentation/topology_screen.dart

class TopologyScreen extends ConsumerWidget {
  const TopologyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceNodesAsync = ref.watch(serviceNodesProvider);
    final trafficEdgesAsync = ref.watch(trafficEdgesProvider);

    return Scaffold(
      body: Row(
        children: [
          const CustomNavigationRail(selectedIndex: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Topology',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: serviceNodesAsync.when(
                      data:
                          (nodes) => trafficEdgesAsync.when(
                            data:
                                (edges) =>
                                    TopologyGraph(nodes: nodes, edges: edges),
                            loading:
                                () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            error:
                                (error, stack) =>
                                    Center(child: Text('Error: $error')),
                          ),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, stack) =>
                              Center(child: Text('Error: $error')),
                    ),
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

// lib/features/topology/widgets/topology_graph.dart

class TopologyGraph extends StatefulWidget {
  final List<ServiceNode> nodes;
  final List<TrafficEdge> edges;

  const TopologyGraph({super.key, required this.nodes, required this.edges});

  @override
  State<TopologyGraph> createState() => _TopologyGraphState();
}

class _TopologyGraphState extends State<TopologyGraph>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  ServiceNode? selectedNode;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: CustomPaint(
                painter: TopologyPainter(
                  nodes: widget.nodes,
                  edges: widget.edges,
                  animation: _animationController,
                  selectedNode: selectedNode,
                  onNodeTap: (node) => setState(() => selectedNode = node),
                ),
                child: GestureDetector(
                  onTapUp: (details) {
                    final RenderBox renderBox =
                        context.findRenderObject() as RenderBox;
                    final localPosition = renderBox.globalToLocal(
                      details.globalPosition,
                    );
                    _handleTap(localPosition);
                  },
                  child: Container(),
                ),
              ),
            ),
            if (selectedNode != null) ...[
              const SizedBox(width: 16),
              Expanded(flex: 1, child: _buildNodeDetails()),
            ],
          ],
        ),
      ),
    );
  }

  void _handleTap(Offset position) {
    // Simple hit detection for demo
    for (final node in widget.nodes) {
      final nodePosition = _getNodePosition(node, Size(800, 600));
      if ((position - nodePosition).distance < 30) {
        setState(() => selectedNode = node);
        break;
      }
    }
  }

  Offset _getNodePosition(ServiceNode node, Size size) {
    final index = widget.nodes.indexOf(node);
    final angle = (index / widget.nodes.length) * 2 * pi;
    final radius = min(size.width, size.height) * 0.3;
    return Offset(
      size.width / 2 + radius * cos(angle),
      size.height / 2 + radius * sin(angle),
    );
  }

  Widget _buildNodeDetails() {
    if (selectedNode == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedNode!.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Namespace', selectedNode!.namespace),
            _buildDetailRow('Health', selectedNode!.health.name),
            _buildDetailRow(
              'CPU Usage',
              '${selectedNode!.cpuUsage.toStringAsFixed(1)}%',
            ),
            _buildDetailRow(
              'Memory Usage',
              '${selectedNode!.memoryUsage.toStringAsFixed(1)}%',
            ),
            _buildDetailRow('Requests', selectedNode!.requestCount.toString()),
            _buildDetailRow(
              'Error Rate',
              '${selectedNode!.errorRate.toStringAsFixed(2)}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class TopologyPainter extends CustomPainter {
  final List<ServiceNode> nodes;
  final List<TrafficEdge> edges;
  final Animation<double> animation;
  final ServiceNode? selectedNode;
  final Function(ServiceNode) onNodeTap;

  TopologyPainter({
    required this.nodes,
    required this.edges,
    required this.animation,
    this.selectedNode,
    required this.onNodeTap,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    final nodePaint = Paint()..style = PaintingStyle.fill;

    // Draw edges
    for (final edge in edges) {
      final fromNode = nodes.firstWhere((n) => n.id == edge.from);
      final toNode = nodes.firstWhere((n) => n.id == edge.to);

      final fromPos = _getNodePosition(fromNode, size);
      final toPos = _getNodePosition(toNode, size);

      paint.color = _getTrafficColor(edge.health).withOpacity(0.6);
      paint.strokeWidth = (edge.requestRate / 20).clamp(1.0, 8.0);

      canvas.drawLine(fromPos, toPos, paint);

      // Animated traffic flow
      final t = animation.value;
      final flowPos = Offset.lerp(fromPos, toPos, t)!;
      canvas.drawCircle(flowPos, 3, Paint()..color = Colors.white);
    }

    // Draw nodes
    for (final node in nodes) {
      final position = _getNodePosition(node, size);
      final isSelected = node == selectedNode;

      nodePaint.color = _getHealthColor(node.health);
      canvas.drawCircle(position, isSelected ? 35 : 30, nodePaint);

      if (isSelected) {
        paint.color = Colors.white;
        paint.strokeWidth = 2;
        canvas.drawCircle(position, 35, paint);
      }

      // Draw service name
      final textPainter = TextPainter(
        text: TextSpan(
          text: node.name.split('-').first,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  Offset _getNodePosition(ServiceNode node, Size size) {
    final index = nodes.indexOf(node);
    final angle = (index / nodes.length) * 2 * pi;
    final radius = min(size.width, size.height) * 0.3;
    return Offset(
      size.width / 2 + radius * cos(angle),
      size.height / 2 + radius * sin(angle),
    );
  }

  Color _getHealthColor(ServiceHealth health) {
    switch (health) {
      case ServiceHealth.healthy:
        return Colors.green;
      case ServiceHealth.warning:
        return Colors.orange;
      case ServiceHealth.critical:
        return Colors.red;
      case ServiceHealth.unknown:
        return Colors.grey;
    }
  }

  Color _getTrafficColor(TrafficHealth health) {
    switch (health) {
      case TrafficHealth.healthy:
        return Colors.green;
      case TrafficHealth.warning:
        return Colors.orange;
      case TrafficHealth.critical:
        return Colors.red;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// lib/features/traces/presentation/traces_screen.dart

class TracesScreen extends ConsumerStatefulWidget {
  const TracesScreen({super.key});

  @override
  ConsumerState<TracesScreen> createState() => _TracesScreenState();
}

class _TracesScreenState extends ConsumerState<TracesScreen> {
  String? selectedTraceId;

  @override
  Widget build(BuildContext context) {
    final tracesAsync = ref.watch(tracesProvider);

    return Scaffold(
      body: Row(
        children: [
          const CustomNavigationRail(selectedIndex: 2),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distributed Traces',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: tracesAsync.when(
                      data:
                          (traces) => Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: TraceList(
                                  traces: traces,
                                  selectedTraceId: selectedTraceId,
                                  onTraceSelected: (traceId) {
                                    setState(() => selectedTraceId = traceId);
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              if (selectedTraceId != null)
                                ...(() {
                                  final selectedTrace = traces.firstWhere(
                                    (t) => t.traceId == selectedTraceId,
                                    orElse:
                                        () => Trace.empty(
                                          // Assuming you have a Trace.empty constructor
                                          traceId: '',
                                          operationName: '',
                                          startTime: DateTime.now(),
                                          duration: Duration.zero,
                                          spans: [],
                                          status: TraceStatus.timeout,
                                        ),
                                  );
                                  if (selectedTrace != null) {
                                    return [
                                      Expanded(
                                        flex: 2,
                                        child: TraceTimeline(
                                          trace: selectedTrace,
                                        ),
                                      ),
                                    ];
                                  }
                                  return <Widget>[];
                                })(),
                            ],
                          ),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, stack) =>
                              Center(child: Text('Error: $error')),
                    ),
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

// lib/features/traces/widgets/trace_list.dart

class TraceList extends StatelessWidget {
  final List<Trace> traces;
  final String? selectedTraceId;
  final Function(String) onTraceSelected;

  const TraceList({
    super.key,
    required this.traces,
    this.selectedTraceId,
    required this.onTraceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Recent Traces',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: traces.length,
              itemBuilder: (context, index) {
                final trace = traces[index];
                final isSelected = trace.traceId == selectedTraceId;

                return ListTile(
                  selected: isSelected,
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(trace.status),
                    child: Icon(
                      _getStatusIcon(trace.status),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  title: Text(
                    trace.operationName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trace.spans.length} spans • ${trace.duration.inMilliseconds}ms',
                      ),
                      Text(
                        _formatTimestamp(trace.startTime),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(
                      trace.status.name.toUpperCase(),
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: _getStatusColor(
                      trace.status,
                    ).withOpacity(0.2),
                  ),
                  onTap: () => onTraceSelected(trace.traceId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TraceStatus status) {
    switch (status) {
      case TraceStatus.success:
        return Colors.green;
      case TraceStatus.error:
        return Colors.red;
      case TraceStatus.timeout:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(TraceStatus status) {
    switch (status) {
      case TraceStatus.success:
        return Icons.check;
      case TraceStatus.error:
        return Icons.error;
      case TraceStatus.timeout:
        return Icons.access_time;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }
}

// lib/features/traces/widgets/trace_timeline.dart

class TraceTimeline extends StatelessWidget {
  final Trace trace;

  const TraceTimeline({super.key, required this.trace});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Trace Timeline',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Chip(
                  label: Text('${trace.duration.inMilliseconds}ms'),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              trace.operationName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Trace ID: ${trace.traceId}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildSpanTimeline()),
          ],
        ),
      ),
    );
  }

  Widget _buildSpanTimeline() {
    if (trace.spans.isEmpty) {
      return const Center(child: Text('No spans available for this trace.'));
    }

    final maxDuration = trace.spans
        .map((s) => s.duration.inMicroseconds)
        .reduce((a, b) => a > b ? a : b);

    return ListView.builder(
      itemCount: trace.spans.length,
      itemBuilder: (context, index) {
        final span = trace.spans[index];
        return _buildSpanItem(span, maxDuration);
      },
    );
  }

  Widget _buildSpanItem(Span span, int maxDuration) {
    final widthFactor = span.duration.inMicroseconds / maxDuration;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              span.serviceName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: widthFactor,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getSpanColor(span.serviceName),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              span.operationName,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${span.duration.inMilliseconds}ms',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSpanColor(String serviceName) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[serviceName.hashCode % colors.length];
  }
}

// lib/features/metrics/presentation/metrics_screen.dart

class MetricsScreen extends ConsumerWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceNodesAsync = ref.watch(serviceNodesProvider);
    final trafficEdgesAsync = ref.watch(trafficEdgesProvider);

    return Scaffold(
      body: Row(
        children: [
          const CustomNavigationRail(selectedIndex: 3),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Metrics',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: serviceNodesAsync.when(
                      data:
                          (nodes) => trafficEdgesAsync.when(
                            data:
                                (edges) =>
                                    _buildMetricsContent(context, nodes, edges),
                            loading:
                                () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            error:
                                (error, stack) =>
                                    Center(child: Text('Error: $error')),
                          ),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, stack) =>
                              Center(child: Text('Error: $error')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsContent(BuildContext context, nodes, edges) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildCpuUsageChart(nodes),
        _buildMemoryUsageChart(nodes),
        _buildRequestRateChart(edges),
        _buildErrorRateChart(nodes),
      ],
    );
  }

  Widget _buildCpuUsageChart(nodes) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CPU Usage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < nodes.length) {
                            return Text(
                              nodes[value.toInt()].name.split('-').first,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups:
                      nodes.asMap().entries.map<BarChartGroupData>((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.cpuUsage,
                              color: _getCpuColor(entry.value.cpuUsage),
                              width: 16,
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryUsageChart(nodes) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Memory Usage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections:
                      nodes.asMap().entries.map<PieChartSectionData>((entry) {
                        final colors = [
                          Colors.blue,
                          Colors.green,
                          Colors.orange,
                          Colors.purple,
                          Colors.teal,
                          Colors.indigo,
                        ];
                        return PieChartSectionData(
                          color: colors[entry.key % colors.length],
                          value: entry.value.memoryUsage,
                          title:
                              '${entry.value.memoryUsage.toStringAsFixed(1)}%',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestRateChart(edges) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request Rate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget:
                            (value, meta) => Text(
                              '${value.toInt()}s',
                              style: const TextStyle(fontSize: 10),
                            ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          edges.asMap().entries.map<FlSpot>((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.requestRate,
                            );
                          }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorRateChart(nodes) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Error Rate by Service',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: nodes.length,
                itemBuilder: (context, index) {
                  final node = nodes[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            node.name.split('-').first,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: node.errorRate / 100,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getErrorRateColor(node.errorRate),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${node.errorRate.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCpuColor(double usage) {
    if (usage < 50) return Colors.green;
    if (usage < 80) return Colors.orange;
    return Colors.red;
  }

  Color _getErrorRateColor(double errorRate) {
    if (errorRate < 1) return Colors.green;
    if (errorRate < 5) return Colors.orange;
    return Colors.red;
  }
}
