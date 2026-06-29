import 'mcp.dart';
import 'mcp_auth_config.dart';
import 'mcp_security_config.dart';

class MCPServerConfig {
  final MCPTransportType transport;
  final MCPSecurityConfig security;
  final MCPAuthConfig auth;
  final int maxConnections;
  final Duration timeout;
  final Duration keepAlive;
  final bool enableLogging;
  final MCPLogLevel logLevel;
  final Map<String, String> environment;
  final List<String> allowedHosts;
  final MCPCompressionType compression;
  final bool enableMetrics;
  final Duration heartbeatInterval;
  final int maxRetries;

  MCPServerConfig({
    required this.transport,
    required this.security,
    required this.auth,
    this.maxConnections = 100,
    this.timeout = const Duration(seconds: 30),
    this.keepAlive = const Duration(seconds: 60),
    this.enableLogging = true,
    this.logLevel = MCPLogLevel.info,
    this.environment = const {},
    this.allowedHosts = const [],
    this.compression = MCPCompressionType.none,
    this.enableMetrics = true,
    this.heartbeatInterval = const Duration(seconds: 30),
    this.maxRetries = 3,
  });
}

/* 
class MCPServerConfig {
  final MCPTransportType transport;
  final MCPSecurityConfig security;
  final MCPAuthConfig auth;
  final int maxConnections;
  final Duration timeout;
  final Duration keepAlive;
  final bool enableLogging;
  final MCPLogLevel logLevel;
  final Map<String, String> environment;
  final List<String> allowedHosts;
  final MCPCompressionType compression;
  final bool enableMetrics;
  final Duration heartbeatInterval;
  final int maxRetries;

  MCPServerConfig({
    required this.transport,
    required this.security,
    required this.auth,
    this.maxConnections = 100,
    this.timeout = const Duration(seconds: 30),
    this.keepAlive = const Duration(seconds: 60),
    this.enableLogging = true,
    this.logLevel = MCPLogLevel.info,
    this.environment = const {},
    this.allowedHosts = const [],
    this.compression = MCPCompressionType.none,
    this.enableMetrics = true,
    this.heartbeatInterval = const Duration(seconds: 30),
    this.maxRetries = 3,
  });
} */
