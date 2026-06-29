import 'mcp.dart';
import 'mcp_capability.dart';
import 'mcp_server_config.dart';
import 'server_config_metrics.dart';
import 'mcp_server_metric.dart';

class MCPServer {
  final String id;
  final String name;
  final String host;
  final int port;
  final MCPServerStatus status;
  final DateTime? lastConnected;
  final String? description;
  final MCPServerConfig config;
  final MCPServerMetrics? metrics;
  final List<MCPCapability> capabilities;
  final List<String> registryIds;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MCPServer({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.status,
    required this.config,
    required this.capabilities,
    required this.createdAt,
    this.lastConnected,
    this.description,
    this.metrics,
    this.registryIds = const [],
    this.updatedAt,
  });

  MCPServer copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    MCPServerStatus? status,
    DateTime? lastConnected,
    String? description,
    MCPServerConfig? config,
    MCPServerMetrics? metrics,
    List<MCPCapability>? capabilities,
    List<String>? registryIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MCPServer(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      status: status ?? this.status,
      lastConnected: lastConnected ?? this.lastConnected,
      description: description ?? this.description,
      config: config ?? this.config,
      metrics: metrics ?? this.metrics,
      capabilities: capabilities ?? this.capabilities,
      registryIds: registryIds ?? this.registryIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 

/* 
class MCPServer {
  final String id;
  final String name;
  final String host;
  final int port;
  final MCPServerStatus status;
  final DateTime? lastConnected;
  final String? description;
  final MCPServerConfig config;
  final MCPServerMetrics? metrics;
  final List<MCPCapability> capabilities;
  final List<String> registryIds; // Tools registry IDs
  final DateTime createdAt;
  final DateTime? updatedAt;

  MCPServer({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.status,
    required this.config,
    required this.capabilities,
    required this.createdAt,
    this.lastConnected,
    this.description,
    this.metrics,
    this.registryIds = const [],
    this.updatedAt,
  });

  MCPServer copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    MCPServerStatus? status,
    DateTime? lastConnected,
    String? description,
    MCPServerConfig? config,
    MCPServerMetrics? metrics,
    List<MCPCapability>? capabilities,
    List<String>? registryIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MCPServer(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      status: status ?? this.status,
      lastConnected: lastConnected ?? this.lastConnected,
      description: description ?? this.description,
      config: config ?? this.config,
      metrics: metrics ?? this.metrics,
      capabilities: capabilities ?? this.capabilities,
      registryIds: registryIds ?? this.registryIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
 */