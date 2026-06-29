import 'package:flutter_riverpod/legacy.dart';

import '../model/mcp.dart';
import '../model/mcp_tool.dart';
import '../model/mcp_tool_category.dart';
import '../model/mcp_tool_parameter.dart';

final mcpToolsProvider = StateNotifierProvider<MCPToolNotifier, List<MCPTool>>(
  (ref) => MCPToolNotifier(),
);

class MCPToolNotifier extends StateNotifier<List<MCPTool>> {
  MCPToolNotifier() : super(_generateSampleTools());

  static List<MCPTool> _generateSampleTools() {
    return [
      MCPTool(
        id: 'tool-1',
        name: 'JSON Transformer',
        version: '1.2.0',
        description: 'Transform and validate JSON data structures',
        category: MCPToolCategory.dataProcessing,
        parameters: [
          MCPToolParameter(
            name: 'input',
            type: 'object',
            description: 'JSON input data',
            required: true,
          ),
          MCPToolParameter(
            name: 'schema',
            type: 'object',
            description: 'JSON Schema for validation',
            required: false,
          ),
        ],
        status: MCPToolStatus.active,
        author: 'MCP Team',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        usageCount: 5420,
        rating: 4.8,
        gitHubUrl: 'https://github.com/mcp/json-transformer',
        tags: ['json', 'validation', 'transformation'],
      ),
      MCPTool(
        id: 'tool-2',
        name: 'API Gateway',
        version: '2.0.0',
        description: 'Route and manage API requests across services',
        category: MCPToolCategory.integration,
        parameters: [
          MCPToolParameter(
            name: 'endpoint',
            type: 'string',
            description: 'Target endpoint URL',
            required: true,
          ),
          MCPToolParameter(
            name: 'method',
            type: 'string',
            description: 'HTTP method',
            required: true,
            enumValues: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
          ),
        ],
        status: MCPToolStatus.active,
        author: 'Integration Team',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        usageCount: 12840,
        rating: 4.6,
        gitHubUrl: 'https://github.com/mcp/api-gateway',
        tags: ['api', 'gateway', 'routing'],
      ),
      MCPTool(
        id: 'tool-3',
        name: 'Database Query Builder',
        version: '1.5.0',
        description: 'Build and execute complex database queries',
        category: MCPToolCategory.dataProcessing,
        parameters: [
          MCPToolParameter(
            name: 'query',
            type: 'string',
            description: 'SQL query string',
            required: true,
          ),
          MCPToolParameter(
            name: 'timeout',
            type: 'number',
            description: 'Query timeout in milliseconds',
            required: false,
            defaultValue: 5000,
          ),
        ],
        status: MCPToolStatus.beta,
        author: 'Data Team',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        usageCount: 3210,
        rating: 4.3,
        tags: ['database', 'sql', 'query'],
      ),
    ];
  }

  void addTool(MCPTool tool) {
    state = [...state, tool];
  }

  void updateTool(String id, MCPTool updatedTool) {
    state = [
      for (final tool in state)
        if (tool.id == id)
          updatedTool.copyWith(updatedAt: DateTime.now())
        else
          tool,
    ];
  }

  void deleteTool(String id) {
    state = state.where((tool) => tool.id != id).toList();
  }
}
