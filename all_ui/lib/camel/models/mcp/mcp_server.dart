import 'mcp_parameter.dart';
import 'mcp_server_info.dart';
import 'mcp_tool.dart';
import 'mcp_tool_result.dart';

class MCPServer {
  final String id;
  final String name;
  final String endpoint;
  final List<MCPTool> tools;
  final MCPAuthentication? authentication;

  MCPServer({
    required this.id,
    required this.name,
    required this.endpoint,
    required this.tools,
    this.authentication,
  });

  Future<MCPServerInfo> getInfo() async {
    return MCPServerInfo(
      name: name,
      version: '1.0.0',
      tools: tools.map((t) => t.toJson()).toList(),
    );
  }

  Future<MCPToolResult> executeTool(
    String toolId,
    Map<String, dynamic> params,
  ) async {
    final tool = tools.firstWhere((t) => t.id == toolId);
    return await tool.execute(params);
  }
}
