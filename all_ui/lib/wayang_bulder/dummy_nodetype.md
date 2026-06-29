import 'package:flutter/material.dart';

import 'features/workflow/model/workflow_node_port.dart';
import 'features/plugin/model/config_field.dart';
import 'features/plugin/model/node_type_config.dart';
import 'features/plugin/model/port_config.dart';
import 'features/workflow/model/workflow_node.dart';

final Map<String, List<NodeConfig>> nodeTypesByCategory = {
  'Triggers': [
    NodeConfig(
      type: NodeType.webhook,
      label: 'Webhook',
      description: 'Triggered by HTTP webhooks',
      icon: Icons.webhook,
      color: Colors.green,
      category: 'Triggers',
      inputs: [],
      outputs: [
        PortConfig(id: 'output', label: 'Payload', type: PortType.object),
      ],
      configFields: {
        'url': ConfigField(
          key: 'url',
          label: 'Webhook URL',
          type: ConfigFieldType.text,
          required: true,
          placeholder: 'https://...',
        ),
        'method': ConfigField(
          key: 'method',
          label: 'HTTP Method',
          type: ConfigFieldType.select,
          defaultValue: 'POST',
          options: ['GET', 'POST', 'PUT', 'DELETE'],
        ),
      },
    ),
    NodeConfig(
      type: NodeType.schedule,
      label: 'Schedule',
      description: 'Run on a schedule',
      icon: Icons.schedule,
      color: Colors.green.shade700,
      category: 'Triggers',
      inputs: [],
      outputs: [PortConfig(id: 'output', label: 'Trigger', type: PortType.any)],
      configFields: {
        'cron': ConfigField(
          key: 'cron',
          label: 'Cron Expression',
          type: ConfigFieldType.text,
          defaultValue: '0 * * * *',
          placeholder: '0 * * * *',
        ),
        'timezone': ConfigField(
          key: 'timezone',
          label: 'Timezone',
          type: ConfigFieldType.text,
          defaultValue: 'UTC',
        ),
      },
    ),
  ],
  'AI/LLM': [
    NodeConfig(
      type: NodeType.llm,
      label: 'LLM',
      description: 'Large Language Model',
      icon: Icons.psychology,
      color: Colors.purple,
      category: 'AI/LLM',
      inputs: [
        PortConfig(id: 'prompt', label: 'Prompt', type: PortType.string),
      ],
      outputs: [
        PortConfig(id: 'response', label: 'Response', type: PortType.string),
      ],
      configFields: {
        'provider': ConfigField(
          key: 'provider',
          label: 'Provider',
          type: ConfigFieldType.select,
          defaultValue: 'openai',
          options: ['openai', 'anthropic', 'google'],
        ),
        'model': ConfigField(
          key: 'model',
          label: 'Model',
          type: ConfigFieldType.text,
          defaultValue: 'gpt-4',
        ),
        'temperature': ConfigField(
          key: 'temperature',
          label: 'Temperature',
          type: ConfigFieldType.number,
          defaultValue: 0.7,
          min: 0.0,
          max: 2.0,
        ),
        'maxTokens': ConfigField(
          key: 'maxTokens',
          label: 'Max Tokens',
          type: ConfigFieldType.number,
          defaultValue: 1000,
        ),
        'systemPrompt': ConfigField(
          key: 'systemPrompt',
          label: 'System Prompt',
          type: ConfigFieldType.multiline,
          placeholder: 'You are a helpful assistant...',
        ),
      },
    ),
    NodeConfig(
      type: NodeType.embedding,
      label: 'Embedding',
      description: 'Generate embeddings',
      icon: Icons.abc,
      color: Colors.purple.shade700,
      category: 'AI/LLM',
      inputs: [PortConfig(id: 'text', label: 'Text', type: PortType.string)],
      outputs: [
        PortConfig(id: 'vector', label: 'Vector', type: PortType.array),
      ],
      configFields: {
        'model': ConfigField(
          key: 'model',
          label: 'Model',
          type: ConfigFieldType.text,
          defaultValue: 'text-embedding-ada-002',
        ),
      },
    ),
  ],
  'Logic': [
    NodeConfig(
      type: NodeType.condition,
      label: 'Condition',
      description: 'Branch based on condition',
      icon: Icons.alt_route,
      color: Colors.orange,
      category: 'Logic',
      inputs: [PortConfig(id: 'input', label: 'Input', type: PortType.any)],
      outputs: [
        PortConfig(id: 'true', label: 'True', type: PortType.any),
        PortConfig(id: 'false', label: 'False', type: PortType.any),
      ],
      configFields: {
        'condition': ConfigField(
          key: 'condition',
          label: 'Condition',
          type: ConfigFieldType.text,
          required: true,
          placeholder: 'input.value > 10',
        ),
      },
    ),
    NodeConfig(
      type: NodeType.switchNode,
      label: 'Switch',
      description: 'Multi-way branch',
      icon: Icons.call_split,
      color: Colors.orange.shade700,
      category: 'Logic',
      inputs: [PortConfig(id: 'input', label: 'Input', type: PortType.any)],
      outputs: [
        PortConfig(id: 'case1', label: 'Case 1', type: PortType.any),
        PortConfig(id: 'case2', label: 'Case 2', type: PortType.any),
        PortConfig(id: 'default', label: 'Default', type: PortType.any),
      ],
      configFields: {
        'cases': ConfigField(
          key: 'cases',
          label: 'Cases (JSON)',
          type: ConfigFieldType.json,
          defaultValue: '[]',
        ),
      },
    ),
  ],
  'Data': [
    NodeConfig(
      type: NodeType.transform,
      label: 'Transform',
      description: 'Transform data',
      icon: Icons.transform,
      color: Colors.blue,
      category: 'Data',
      inputs: [PortConfig(id: 'input', label: 'Input', type: PortType.any)],
      outputs: [PortConfig(id: 'output', label: 'Output', type: PortType.any)],
      configFields: {
        'script': ConfigField(
          key: 'script',
          label: 'Transform Script',
          type: ConfigFieldType.multiline,
          required: true,
          placeholder: 'return { ...input, transformed: true }',
        ),
      },
    ),
    NodeConfig(
      type: NodeType.filter,
      label: 'Filter',
      description: 'Filter array items',
      icon: Icons.filter_list,
      color: Colors.blue.shade700,
      category: 'Data',
      inputs: [PortConfig(id: 'array', label: 'Array', type: PortType.array)],
      outputs: [
        PortConfig(id: 'filtered', label: 'Filtered', type: PortType.array),
      ],
      configFields: {
        'condition': ConfigField(
          key: 'condition',
          label: 'Filter Condition',
          type: ConfigFieldType.text,
          required: true,
          placeholder: 'item.value > 10',
        ),
      },
    ),
  ],
  'Integration': [
    NodeConfig(
      type: NodeType.api,
      label: 'HTTP Request',
      description: 'Make HTTP API calls',
      icon: Icons.api,
      color: Colors.teal,
      category: 'Integration',
      inputs: [
        PortConfig(
          id: 'body',
          label: 'Body',
          type: PortType.object,
          required: false,
        ),
      ],
      outputs: [
        PortConfig(id: 'response', label: 'Response', type: PortType.object),
        PortConfig(id: 'error', label: 'Error', type: PortType.object),
      ],
      configFields: {
        'url': ConfigField(
          key: 'url',
          label: 'URL',
          type: ConfigFieldType.text,
          required: true,
          placeholder: 'https://api.example.com/endpoint',
        ),
        'method': ConfigField(
          key: 'method',
          label: 'Method',
          type: ConfigFieldType.select,
          defaultValue: 'GET',
          options: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
        ),
        'headers': ConfigField(
          key: 'headers',
          label: 'Headers (JSON)',
          type: ConfigFieldType.json,
          defaultValue: '{}',
        ),
        'timeout': ConfigField(
          key: 'timeout',
          label: 'Timeout (seconds)',
          type: ConfigFieldType.number,
          defaultValue: 30,
        ),
      },
    ),
    NodeConfig(
      type: NodeType.database,
      label: 'Database Query',
      description: 'Execute database queries',
      icon: Icons.storage,
      color: Colors.teal.shade700,
      category: 'Integration',
      inputs: [
        PortConfig(
          id: 'params',
          label: 'Parameters',
          type: PortType.object,
          required: false,
        ),
      ],
      outputs: [
        PortConfig(id: 'result', label: 'Result', type: PortType.array),
      ],
      configFields: {
        'connection': ConfigField(
          key: 'connection',
          label: 'Connection String',
          type: ConfigFieldType.password,
          required: true,
        ),
        'query': ConfigField(
          key: 'query',
          label: 'SQL Query',
          type: ConfigFieldType.multiline,
          required: true,
          placeholder: 'SELECT * FROM users WHERE id = ?',
        ),
      },
    ),
  ],
  'Output': [
    NodeConfig(
      type: NodeType.response,
      label: 'Response',
      description: 'Return workflow response',
      icon: Icons.output,
      color: Colors.red,
      category: 'Output',
      inputs: [PortConfig(id: 'data', label: 'Data', type: PortType.any)],
      outputs: [],
      configFields: {
        'statusCode': ConfigField(
          key: 'statusCode',
          label: 'Status Code',
          type: ConfigFieldType.number,
          defaultValue: 200,
        ),
        'format': ConfigField(
          key: 'format',
          label: 'Format',
          type: ConfigFieldType.select,
          defaultValue: 'json',
          options: ['json', 'text', 'xml'],
        ),
      },
    ),
    NodeConfig(
      type: NodeType.notification,
      label: 'Notification',
      description: 'Send notifications',
      icon: Icons.notifications,
      color: Colors.red.shade700,
      category: 'Output',
      inputs: [
        PortConfig(id: 'message', label: 'Message', type: PortType.string),
      ],
      outputs: [PortConfig(id: 'sent', label: 'Sent', type: PortType.boolean)],
      configFields: {
        'channel': ConfigField(
          key: 'channel',
          label: 'Channel',
          type: ConfigFieldType.select,
          defaultValue: 'email',
          options: ['email', 'slack', 'webhook'],
        ),
        'recipients': ConfigField(
          key: 'recipients',
          label: 'Recipients',
          type: ConfigFieldType.text,
          required: true,
        ),
      },
    ),
  ],
};
