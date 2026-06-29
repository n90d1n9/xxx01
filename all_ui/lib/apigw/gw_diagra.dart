import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graphview/GraphView.dart';

// Models
class ApiGatewayInstance {
  final String id;
  final String name;
  final String region;
  final String status;
  final List<String> endpointIds;

  ApiGatewayInstance({
    required this.id,
    required this.name,
    required this.region,
    required this.status,
    required this.endpointIds,
  });
}

class Endpoint {
  final String id;
  final String path;
  final String method;
  final String integration;
  final String gatewayId;

  Endpoint({
    required this.id,
    required this.path,
    required this.method,
    required this.integration,
    required this.gatewayId,
  });

  Color get methodColor {
    switch (method) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// API Service
class ApiGatewayService {
  Future<List<ApiGatewayInstance>> fetchGatewayInstances() async {
    // Mock data - in production, replace with actual API call
    await Future.delayed(Duration(seconds: 1));
    return [
      ApiGatewayInstance(
        id: 'gw-001',
        name: 'Production Gateway',
        region: 'us-east-1',
        status: 'Active',
        endpointIds: ['ep-001', 'ep-002', 'ep-003'],
      ),
      ApiGatewayInstance(
        id: 'gw-002',
        name: 'Staging Gateway',
        region: 'us-west-2',
        status: 'Active',
        endpointIds: ['ep-004', 'ep-005'],
      ),
      ApiGatewayInstance(
        id: 'gw-003',
        name: 'Development Gateway',
        region: 'eu-west-1',
        status: 'Inactive',
        endpointIds: ['ep-006', 'ep-007', 'ep-008'],
      ),
    ];
  }

  Future<List<Endpoint>> fetchEndpoints() async {
    // Mock data - in production, replace with actual API call
    await Future.delayed(Duration(seconds: 1));
    return [
      Endpoint(
        id: 'ep-001',
        path: '/users',
        method: 'GET',
        integration: 'Lambda',
        gatewayId: 'gw-001',
      ),
      Endpoint(
        id: 'ep-002',
        path: '/users',
        method: 'POST',
        integration: 'Lambda',
        gatewayId: 'gw-001',
      ),
      Endpoint(
        id: 'ep-003',
        path: '/products',
        method: 'GET',
        integration: 'HTTP',
        gatewayId: 'gw-001',
      ),
      Endpoint(
        id: 'ep-004',
        path: '/users',
        method: 'GET',
        integration: 'Lambda',
        gatewayId: 'gw-002',
      ),
      Endpoint(
        id: 'ep-005',
        path: '/orders',
        method: 'POST',
        integration: 'SQS',
        gatewayId: 'gw-002',
      ),
      Endpoint(
        id: 'ep-006',
        path: '/test',
        method: 'GET',
        integration: 'Mock',
        gatewayId: 'gw-003',
      ),
      Endpoint(
        id: 'ep-007',
        path: '/debug',
        method: 'GET',
        integration: 'Lambda',
        gatewayId: 'gw-003',
      ),
      Endpoint(
        id: 'ep-008',
        path: '/debug',
        method: 'DELETE',
        integration: 'Lambda',
        gatewayId: 'gw-003',
      ),
    ];
  }
}

// Providers
final apiGatewayServiceProvider = Provider<ApiGatewayService>((ref) {
  return ApiGatewayService();
});

final gatewayInstancesProvider = FutureProvider<List<ApiGatewayInstance>>((
  ref,
) async {
  final apiService = ref.watch(apiGatewayServiceProvider);
  return await apiService.fetchGatewayInstances();
});

final endpointsProvider = FutureProvider<List<Endpoint>>((ref) async {
  final apiService = ref.watch(apiGatewayServiceProvider);
  return await apiService.fetchEndpoints();
});

// Selected providers for filtering
final selectedGatewayProvider = StateProvider<String?>((ref) => null);

// Filtered endpoints provider
final filteredEndpointsProvider = Provider<List<Endpoint>>((ref) {
  final endpointsAsyncValue = ref.watch(endpointsProvider);
  final selectedGateway = ref.watch(selectedGatewayProvider);

  return endpointsAsyncValue.when(
    data: (endpoints) {
      if (selectedGateway == null) {
        return endpoints;
      }
      return endpoints
          .where((endpoint) => endpoint.gatewayId == selectedGateway)
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Main screen
class ApiGatewayNetworkDiagram extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gatewaysAsyncValue = ref.watch(gatewayInstancesProvider);
    final selectedGateway = ref.watch(selectedGatewayProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Iket  Network Diagram'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(gatewayInstancesProvider);
              ref.refresh(endpointsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Gateway selection
          gatewaysAsyncValue.when(
            data:
                (gateways) => GatewaySelectorWidget(
                  gateways: gateways,
                  selectedGateway: selectedGateway,
                  onGatewaySelected: (gatewayId) {
                    ref.read(selectedGatewayProvider.notifier).state =
                        selectedGateway == gatewayId ? null : gatewayId;
                  },
                ),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error loading Iket s')),
          ),

          // Network diagram
          Expanded(child: NetworkDiagramWidget()),
        ],
      ),
    );
  }
}

class GatewaySelectorWidget extends StatelessWidget {
  final List<ApiGatewayInstance> gateways;
  final String? selectedGateway;
  final Function(String) onGatewaySelected;

  const GatewaySelectorWidget({
    required this.gateways,
    required this.selectedGateway,
    required this.onGatewaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: gateways.length,
        itemBuilder: (context, index) {
          final gateway = gateways[index];
          final isSelected = gateway.id == selectedGateway;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              onTap: () => onGatewaySelected(gateway.id),
              child: Container(
                width: 180,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gateway.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            isSelected ? Colors.blue.shade800 : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      gateway.region,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                gateway.status == 'Active'
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          gateway.status,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                gateway.status == 'Active'
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '${gateway.endpointIds.length} endpoints',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class NetworkDiagramWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gatewaysAsyncValue = ref.watch(gatewayInstancesProvider);
    final endpointsAsyncValue = ref.watch(endpointsProvider);
    final selectedGateway = ref.watch(selectedGatewayProvider);

    if (gatewaysAsyncValue is AsyncLoading ||
        endpointsAsyncValue is AsyncLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (gatewaysAsyncValue is AsyncError || endpointsAsyncValue is AsyncError) {
      return Center(child: Text('Error loading data'));
    }

    if (gatewaysAsyncValue is AsyncData && endpointsAsyncValue is AsyncData) {
      final gateways = gatewaysAsyncValue.value!;
      final endpoints = endpointsAsyncValue.value!;

      return DiagramView(
        gateways: gateways,
        endpoints: endpoints,
        selectedGatewayId: selectedGateway,
      );
    }

    return Container();
  }
}

class DiagramView extends StatelessWidget {
  final List<ApiGatewayInstance> gateways;
  final List<Endpoint> endpoints;
  final String? selectedGatewayId;

  DiagramView({
    required this.gateways,
    required this.endpoints,
    required this.selectedGatewayId,
  });

  @override
  Widget build(BuildContext context) {
    final Graph graph = Graph();
    final algorithm = FruchtermanReingoldAlgorithm();

    // Filter items based on selection
    final filteredGateways =
        selectedGatewayId == null
            ? gateways
            : gateways.where((g) => g.id == selectedGatewayId).toList();

    final filteredEndpoints =
        selectedGatewayId == null
            ? endpoints
            : endpoints.where((e) => e.gatewayId == selectedGatewayId).toList();

    // Create nodes
    final Map<String, Node> gatewayNodes = {};
    final Map<String, Node> endpointNodes = {};

    // Add gateway nodes
    for (final gateway in filteredGateways) {
      final node = Node.Id(gateway.id);
      gatewayNodes[gateway.id] = node;
      graph.addNode(node);
    }

    // Add endpoint nodes
    for (final endpoint in filteredEndpoints) {
      final node = Node.Id(endpoint.id);
      endpointNodes[endpoint.id] = node;
      graph.addNode(node);

      // Connect endpoint to its gateway
      if (gatewayNodes.containsKey(endpoint.gatewayId)) {
        graph.addEdge(gatewayNodes[endpoint.gatewayId]!, node);
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Legend
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                _buildLegendItem('Iket ', Colors.blue),
                SizedBox(width: 16),
                _buildLegendItem('GET', Colors.green),
                SizedBox(width: 16),
                _buildLegendItem('POST', Colors.blue),
                SizedBox(width: 16),
                _buildLegendItem('PUT', Colors.orange),
                SizedBox(width: 16),
                _buildLegendItem('DELETE', Colors.red),
              ],
            ),
          ),

          // Graph
          Expanded(
            child: InteractiveViewer(
              constrained: false,
              boundaryMargin: EdgeInsets.all(100),
              minScale: 0.1,
              maxScale: 2.5,
              child: GraphView(
                graph: graph,
                algorithm: algorithm,
                paint:
                    Paint()
                      ..color = Colors.grey
                      ..strokeWidth = 1
                      ..style = PaintingStyle.stroke,
                builder: (Node node) {
                  // Check if node is a gateway
                  if (gatewayNodes.values.contains(node)) {
                    final gateway = gateways.firstWhere(
                      (g) => g.id == node.key!.value,
                    );
                    return _buildGatewayNode(gateway);
                  }
                  // Else it's an endpoint
                  else if (endpointNodes.values.contains(node)) {
                    final endpoint = endpoints.firstWhere(
                      (e) => e.id == node.key!.value,
                    );
                    return _buildEndpointNode(endpoint);
                  }

                  return Container();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildGatewayNode(ApiGatewayInstance gateway) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud, color: Colors.blue, size: 32),
          SizedBox(height: 4),
          Text(gateway.name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(gateway.region, style: TextStyle(fontSize: 12)),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: gateway.status == 'Active' ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              gateway.status,
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndpointNode(Endpoint endpoint) {
    IconData methodIcon;
    switch (endpoint.method) {
      case 'GET':
        methodIcon = Icons.download;
        break;
      case 'POST':
        methodIcon = Icons.add;
        break;
      case 'PUT':
        methodIcon = Icons.edit;
        break;
      case 'DELETE':
        methodIcon = Icons.delete;
        break;
      default:
        methodIcon = Icons.api;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: endpoint.methodColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: endpoint.methodColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  endpoint.method,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 4),
              Icon(methodIcon, size: 16, color: endpoint.methodColor),
            ],
          ),
          SizedBox(height: 4),
          Text(endpoint.path, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          Text(
            endpoint.integration,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// Main app
class ApiGatewayDiagramApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Iket  Network Diagram',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: ApiGatewayNetworkDiagram(),
      ),
    );
  }
}

void main() {
  runApp(ApiGatewayDiagramApp());
}
