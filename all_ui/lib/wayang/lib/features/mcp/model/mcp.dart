enum MCPToolStatus { active, deprecated, beta, archived }

enum MCPServerStatus {
  connected,
  disconnected,
  connecting,
  error,
  maintenance,
  initializing,
}

enum MCPTransportType { websocket, http, grpc, tcp }

enum MCPLogLevel { debug, info, warn, error }

enum MCPCompressionType { none, gzip, deflate }

enum MCPErrorSeverity { low, medium, high, critical }

/* 
enum MCPTransportType { websocket, http, grpc, tcp }

enum MCPLogLevel { debug, info, warn, error }

enum MCPCompressionType { none, gzip, deflate }
 */
