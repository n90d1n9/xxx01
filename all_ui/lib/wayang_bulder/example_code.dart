import 'package:flutter/material.dart';

import 'features/plugin/model/action/http_request_action.dart';
import 'features/plugin/model/config_field_definition.dart';
import 'features/plugin/model/node_definition.dart';
import 'features/plugin/model/node_execution_context.dart';
import 'features/plugin/model/plugin_definition.dart';
import 'features/plugin/model/plugin_definition_uploader.dart';
import 'features/plugin/model/plugin_registry.dart';
import 'features/plugin/model/port_definition.dart';

void exampleLowCodePluginUsage() async {
  // 1. Create plugin definition using the builder UI
  final pluginDefinition = PluginDefinition(
    id: 'my-custom-plugin',
    name: 'My Custom Plugin',
    version: '1.0.0',
    description: 'A custom plugin created with the low-code builder',
    author: 'Your Name',
    category: 'Integration',
    tags: ['api', 'custom'],
    createdAt: DateTime.now(),
    nodes: [
      NodeDefinition(
        id: 'fetch_user',
        name: 'Fetch User',
        type: 'fetch_user_node',
        description: 'Fetch user data from API',
        icon: Icons.person,
        color: Colors.blue,
        inputs: [
          PortDefinition(
            id: 'userId',
            name: 'User ID',
            description: 'The user ID to fetch',
            dataType: 'string',
            required: true,
          ),
        ],
        outputs: [
          PortDefinition(
            id: 'user',
            name: 'User Data',
            description: 'The fetched user data',
            dataType: 'object',
          ),
        ],
        configFields: [
          ConfigFieldDefinition(
            key: 'apiEndpoint',
            label: 'API Endpoint',
            description: 'The API endpoint URL',
            fieldType: 'text',
            required: true,
            defaultValue: 'https://api.example.com',
          ),
        ],
        requiredSecrets: ['API_KEY'],
        action: HttpRequestAction(
          method: 'GET',
          urlTemplate: '{{config.apiEndpoint}}/users/{{inputs.userId}}',
          headers: {'Content-Type': 'application/json'},
          authType: 'bearer',
          responseMapping: {'user': 'body.data'},
        ),
      ),
    ],
  );

  // 2. Upload to agent builder
  final registry = PluginRegistry();
  final uploader = PluginDefinitionUploader(registry);

  await uploader.uploadDefinition(pluginDefinition);

  // 3. Use the plugin
  final executor = registry.getExecutor('fetch_user_node');
  if (executor != null) {
    final context = NodeExecutionContext(
      nodeId: 'node-1',
      workflowId: 'workflow-1',
      executionId: 'exec-1',
      inputs: {'userId': '12345'},
      config: {'apiEndpoint': 'https://api.example.com'},
      secrets: {'API_KEY': 'secret-key'},
      variables: {},
    );

    final result = await executor.execute(context);
    print('Execution result: ${result.status}');
    print('Output: ${result.outputs}');
  }
}
