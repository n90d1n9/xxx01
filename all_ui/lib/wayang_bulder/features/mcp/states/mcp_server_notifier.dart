import 'package:flutter_riverpod/legacy.dart';

import '../model/mcp.dart';
import '../model/mcp_auth_config.dart';
import '../model/mcp_capability.dart';
import '../model/mcp_error.dart';
import '../model/mcp_security_config.dart';
import '../model/mcp_server.dart';
import '../model/mcp_server_config.dart';
import '../model/mcp_server_metric.dart';

final mcpServersProvider =
    StateNotifierProvider<MCPServerNotifier, List<MCPServer>>(
      (ref) => MCPServerNotifier(),
    );

final serverFilterProvider = StateProvider<MCPServerStatus?>((ref) => null);

class MCPServerNotifier extends StateNotifier<List<MCPServer>> {
  MCPServerNotifier() : super(_generateSampleServers());

  static List<MCPServer> _generateSampleServers() {
    // Generate 24-hour request data
    final requestsPerHour = List<int>.generate(24, (index) {
      final baseLoad = 1000;
      final peakHours = [12, 13, 14]; // Noon peak
      if (peakHours.contains(index)) return baseLoad + 2000;
      if (index >= 7 && index <= 18) return baseLoad + 800; // Business hours
      return baseLoad + 200; // Off hours
    });

    // Generate 24-hour error data
    final errorsPerHour = List<int>.generate(24, (index) {
      final baseErrors = 5;
      if (index >= 7 && index <= 18) return baseErrors + 15;
      return baseErrors + 3;
    });

    return [
      MCPServer(
        id: '1',
        name: 'Development Server',
        host: 'localhost',
        port: 8080,
        status: MCPServerStatus.connected,
        lastConnected: DateTime.now().subtract(const Duration(minutes: 5)),
        description: 'Local development MCP server',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        registryIds: ['reg-1', 'reg-2'],
        config: MCPServerConfig(
          transport: MCPTransportType.websocket,
          security: MCPSecurityConfig(enableTLS: false),
          auth: MCPAuthConfig(type: MCPAuthType.none),
          maxConnections: 50,
          enableLogging: true,
          logLevel: MCPLogLevel.debug,
        ),
        capabilities: [
          MCPCapability(name: 'resources', version: '1.0.0', enabled: true),
          MCPCapability(name: 'tools', version: '1.0.0', enabled: true),
          MCPCapability(name: 'prompts', version: '1.0.0', enabled: false),
        ],
        metrics: MCPServerMetrics(
          activeConnections: 5,
          totalRequests: 1250,
          failedRequests: 12,
          averageResponseTime: const Duration(milliseconds: 45),
          cpuUsage: 15.5,
          memoryUsage: 256.8,
          bytesTransferred: 1048576,
          lastUpdated: DateTime.now(),
          requestsByType: {'GET': 800, 'POST': 350, 'PUT': 75, 'DELETE': 25},
          recentErrors: [
            MCPError(
              message: 'Connection timeout',
              code: 'CONN_TIMEOUT',
              timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
              severity: MCPErrorSeverity.medium,
            ),
          ],
          requestsPerHour: requestsPerHour,
          errorsPerHour: errorsPerHour,
        ),
      ),
      MCPServer(
        id: '2',
        name: 'Production Server',
        host: 'prod.example.com',
        port: 443,
        status: MCPServerStatus.connected,
        lastConnected: DateTime.now().subtract(const Duration(minutes: 2)),
        description: 'Production MCP server instance',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        registryIds: ['reg-3'],
        config: MCPServerConfig(
          transport: MCPTransportType.websocket,
          security: MCPSecurityConfig(
            enableTLS: true,
            tlsVersion: 'TLS1.3',
            requireClientCert: true,
            verifyHostname: true,
          ),
          auth: MCPAuthConfig(
            type: MCPAuthType.bearer,
            token: 'prod-token-xyz',
          ),
          maxConnections: 500,
          compression: MCPCompressionType.gzip,
        ),
        capabilities: [
          MCPCapability(name: 'resources', version: '1.2.0', enabled: true),
          MCPCapability(name: 'tools', version: '1.2.0', enabled: true),
          MCPCapability(name: 'prompts', version: '1.1.0', enabled: true),
          MCPCapability(name: 'sampling', version: '1.0.0', enabled: true),
        ],
        metrics: MCPServerMetrics(
          activeConnections: 127,
          totalRequests: 45230,
          failedRequests: 89,
          averageResponseTime: const Duration(milliseconds: 32),
          cpuUsage: 45.2,
          memoryUsage: 1024.5,
          bytesTransferred: 134217728,
          lastUpdated: DateTime.now(),
          requestsByType: {
            'GET': 30000,
            'POST': 12000,
            'PUT': 2500,
            'DELETE': 730,
          },
          recentErrors: [
            MCPError(
              message: 'Connection timeout',
              code: 'TIMEOUT_001',
              timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
              severity: MCPErrorSeverity.medium,
            ),
          ],
          requestsPerHour: requestsPerHour,
          errorsPerHour: errorsPerHour,
        ),
      ),
      MCPServer(
        id: '3',
        name: 'Staging Server',
        host: 'staging.example.com',
        port: 443,
        status: MCPServerStatus.maintenance,
        lastConnected: DateTime.now().subtract(const Duration(hours: 1)),
        description: 'Staging environment for testing',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        registryIds: ['reg-2'],
        config: MCPServerConfig(
          transport: MCPTransportType.http,
          security: MCPSecurityConfig(enableTLS: true),
          auth: MCPAuthConfig(
            type: MCPAuthType.apiKey,
            apiKey: 'staging-key-abc',
          ),
        ),
        capabilities: [
          MCPCapability(name: 'resources', version: '1.1.0', enabled: true),
          MCPCapability(name: 'tools', version: '1.1.0', enabled: false),
        ],
        metrics: MCPServerMetrics(
          activeConnections: 0,
          totalRequests: 5620,
          failedRequests: 45,
          averageResponseTime: const Duration(milliseconds: 78),
          cpuUsage: 8.1,
          memoryUsage: 512.3,
          bytesTransferred: 16777216,
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
          requestsByType: {
            'GET': 4000,
            'POST': 1200,
            'PUT': 320,
            'DELETE': 100,
          },
          recentErrors: [
            MCPError(
              message: 'Authentication failed',
              code: 'AUTH_401',
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              severity: MCPErrorSeverity.high,
            ),
          ],
          requestsPerHour: requestsPerHour,
          errorsPerHour: errorsPerHour,
        ),
      ),
    ];
  }

  /// Add a new server to the list
  void addServer(MCPServer server) {
    state = [...state, server];
  }

  /// Update an existing server
  void updateServer(String id, MCPServer updatedServer) {
    state = [
      for (final server in state)
        if (server.id == id)
          updatedServer.copyWith(updatedAt: DateTime.now())
        else
          server,
    ];
  }

  /// Delete a server by ID
  void deleteServer(String id) {
    state = state.where((server) => server.id != id).toList();
  }

  /// Toggle server connection status
  void toggleConnection(String id) {
    final server = state.firstWhere((s) => s.id == id);

    if (server.status == MCPServerStatus.maintenance) {
      return; // Cannot connect to maintenance servers
    }

    final newStatus = server.status == MCPServerStatus.connected
        ? MCPServerStatus.disconnected
        : MCPServerStatus.connecting;

    updateServer(id, server.copyWith(status: newStatus));

    // Simulate connection process
    if (newStatus == MCPServerStatus.connecting) {
      Future.delayed(const Duration(seconds: 2), () {
        final currentServer = state.firstWhere((s) => s.id == id);
        updateServer(
          id,
          currentServer.copyWith(
            status: MCPServerStatus.connected,
            lastConnected: DateTime.now(),
          ),
        );
      });
    }
  }

  /// Update metrics for a server
  /// Update metrics for a server
  void updateServerMetrics(String id, MCPServerMetrics metrics) {
    final server = state.firstWhere((s) => s.id == id);
    updateServer(id, server.copyWith(metrics: metrics));
  }

  /// Get a server by ID
  MCPServer? getServerById(String id) {
    try {
      return state.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all connected servers
  List<MCPServer> getConnectedServers() {
    return state.where((s) => s.status == MCPServerStatus.connected).toList();
  }

  /// Get all servers by status
  List<MCPServer> getServersByStatus(MCPServerStatus status) {
    return state.where((s) => s.status == status).toList();
  }
}
