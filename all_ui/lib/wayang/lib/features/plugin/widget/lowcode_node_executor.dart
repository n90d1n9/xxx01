import 'dart:convert';

import '../../execution/model/node_execution_result.dart';
import '../model/action/http_request_action.dart';
import '../model/action/script_action.dart';
import '../model/action/template_action.dart';
import '../model/action/tranform_action.dart';
import '../model/action/workflow_action.dart';
import '../model/config_field_definition.dart';
import '../model/config_field_schema.dart';
import '../model/field_type.dart';
import '../model/node_definition.dart';
import '../model/node_exceutor.dart';
import '../model/node_execution_context.dart';
import '../model/node_schema.dart';
import '../model/port_definition.dart';
import '../model/port_schema.dart';

class LowCodeNodeExecutor implements NodeExecutor {
  final NodeDefinition definition;

  LowCodeNodeExecutor(this.definition);

  @override
  String get nodeType => definition.type;

  @override
  NodeSchema get schema => NodeSchema(
    name: definition.name,
    description: definition.description,
    category: 'Low-Code',
    icon: definition.icon,
    color: definition.color,
    inputs: definition.inputs.map(_convertPortSchema).toList(),
    outputs: definition.outputs.map(_convertPortSchema).toList(),
    configFields: definition.configFields
        .map(_convertConfigFieldSchema)
        .toList(),
    requiredSecrets: definition.requiredSecrets,
  );

  PortSchema _convertPortSchema(PortDefinition port) {
    return PortSchema(
      id: port.id,
      name: port.name,
      description: port.description,
      type: _parsePortType(port.dataType),
      required: port.required,
      defaultValue: port.defaultValue,
    );
  }

  ConfigFieldSchema _convertConfigFieldSchema(ConfigFieldDefinition field) {
    return ConfigFieldSchema(
      key: field.key,
      label: field.label,
      description: field.description,
      type: _parseFieldType(field.fieldType),
      required: field.required,
      defaultValue: field.defaultValue,
      options: field.options,
      validation: field.validation,
    );
  }

  PortType _parsePortType(String type) {
    switch (type.toLowerCase()) {
      case 'string':
        return PortType.string;
      case 'number':
        return PortType.number;
      case 'boolean':
        return PortType.boolean;
      case 'object':
        return PortType.object;
      case 'array':
        return PortType.array;
      case 'file':
        return PortType.file;
      default:
        return PortType.any;
    }
  }

  FieldType _parseFieldType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return FieldType.text;
      case 'number':
        return FieldType.number;
      case 'boolean':
        return FieldType.boolean;
      case 'select':
        return FieldType.select;
      case 'textarea':
        return FieldType.textarea;
      case 'password':
        return FieldType.password;
      case 'json':
        return FieldType.json;
      default:
        return FieldType.text;
    }
  }

  @override
  Future<NodeExecutionResult> execute(NodeExecutionContext context) async {
    final startTime = DateTime.now();

    try {
      final action = definition.action;
      Map<String, dynamic> result;

      if (action is HttpRequestAction) {
        result = await _executeHttpRequest(action, context);
      } else if (action is TransformAction) {
        result = await _executeTransform(action, context);
      } else if (action is ScriptAction) {
        result = await _executeScript(action, context);
      } else if (action is TemplateAction) {
        result = await _executeTemplate(action, context);
      } else if (action is WorkflowAction) {
        result = await _executeWorkflow(action, context);
      } else {
        throw Exception('Unknown action type: ${action.type}');
      }

      return NodeExecutionResult.success(
        nodeId: context.nodeId,
        outputs: result,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e) {
      return NodeExecutionResult.failure(
        nodeId: context.nodeId,
        error: e.toString(),
        duration: DateTime.now().difference(startTime),
      );
    }
  }

  Future<Map<String, dynamic>> _executeHttpRequest(
    HttpRequestAction action,
    NodeExecutionContext context,
  ) async {
    // Replace template variables
    final url = _replaceTemplateVariables(action.urlTemplate, context);
    final body = action.bodyTemplate != null
        ? _replaceTemplateVariables(action.bodyTemplate!, context)
        : null;

    // Build headers
    final headers = <String, String>{...action.headers};

    // Add authentication
    if (action.authType != null) {
      _addAuthentication(headers, action, context);
    }

    // Make HTTP request (simplified - use http package in production)
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate response
    final response = {
      'statusCode': 200,
      'body': {'success': true, 'data': 'Response data'},
      'headers': headers,
    };

    // Apply response mapping
    if (action.responseMapping != null) {
      return _applyResponseMapping(response, action.responseMapping!);
    }

    return response;
  }

  Future<Map<String, dynamic>> _executeTransform(
    TransformAction action,
    NodeExecutionContext context,
  ) async {
    final result = <String, dynamic>{};

    for (final rule in action.rules) {
      final sourceValue = _getNestedValue(context.inputs, rule.sourceField);

      dynamic transformedValue = sourceValue;

      if (rule.transformType != null) {
        transformedValue = _applyTransform(
          sourceValue,
          rule.transformType!,
          rule.transformConfig,
        );
      }

      _setNestedValue(result, rule.targetField, transformedValue);
    }

    return {action.outputFormat: result};
  }

  Future<Map<String, dynamic>> _executeScript(
    ScriptAction action,
    NodeExecutionContext context,
  ) async {
    // In production, use dart:isolate or a sandboxed VM
    // For now, return a simulated result
    await Future.delayed(const Duration(milliseconds: 300));

    return {'output': 'Script executed', 'language': action.language};
  }

  Future<Map<String, dynamic>> _executeTemplate(
    TemplateAction action,
    NodeExecutionContext context,
  ) async {
    // Simple template replacement (use proper template engine in production)
    var output = action.template;

    final allData = {
      ...context.inputs,
      ...context.config,
      ...context.variables,
    };

    allData.forEach((key, value) {
      output = output.replaceAll('{{$key}}', value.toString());
    });

    return {'output': output};
  }

  Future<Map<String, dynamic>> _executeWorkflow(
    WorkflowAction action,
    NodeExecutionContext context,
  ) async {
    // Map inputs
    final workflowInputs = <String, dynamic>{};
    action.inputMapping.forEach((targetKey, sourceKey) {
      workflowInputs[targetKey] = _getNestedValue(context.inputs, sourceKey);
    });

    // Execute sub-workflow (simplified)
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate workflow result
    final workflowResult = {'status': 'completed', 'output': workflowInputs};

    // Map outputs
    final result = <String, dynamic>{};
    action.outputMapping.forEach((targetKey, sourceKey) {
      result[targetKey] = _getNestedValue(workflowResult, sourceKey);
    });

    return result;
  }

  // ==================== HELPER METHODS ====================

  String _replaceTemplateVariables(
    String template,
    NodeExecutionContext context,
  ) {
    var result = template;

    final allData = {
      'inputs': context.inputs,
      'config': context.config,
      'variables': context.variables,
    };

    // Replace {{category.key}} patterns
    final pattern = RegExp(r'\{\{([^}]+)\}\}');
    final matches = pattern.allMatches(template);

    for (final match in matches) {
      final path = match.group(1)!;
      final value = _getNestedValueByPath(allData, path);
      result = result.replaceAll(match.group(0)!, value?.toString() ?? '');
    }

    return result;
  }

  void _addAuthentication(
    Map<String, String> headers,
    HttpRequestAction action,
    NodeExecutionContext context,
  ) {
    switch (action.authType) {
      case 'bearer':
        final token =
            action.authConfig?['token'] ?? context.secrets['API_TOKEN'];
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
        break;
      case 'basic':
        final username =
            action.authConfig?['username'] ?? context.secrets['USERNAME'];
        final password =
            action.authConfig?['password'] ?? context.secrets['PASSWORD'];
        if (username != null && password != null) {
          final credentials = base64.encode(utf8.encode('$username:$password'));
          headers['Authorization'] = 'Basic $credentials';
        }
        break;
      case 'api_key':
        final key = action.authConfig?['key'] ?? 'X-API-Key';
        final value = action.authConfig?['value'] ?? context.secrets['API_KEY'];
        if (value != null) {
          headers[key] = value;
        }
        break;
    }
  }

  Map<String, dynamic> _applyResponseMapping(
    Map<String, dynamic> response,
    Map<String, dynamic> mapping,
  ) {
    final result = <String, dynamic>{};

    mapping.forEach((targetKey, sourcePath) {
      result[targetKey] = _getNestedValueByPath(response, sourcePath);
    });

    return result;
  }

  dynamic _applyTransform(
    dynamic value,
    String transformType,
    Map<String, dynamic>? config,
  ) {
    switch (transformType) {
      case 'uppercase':
        return value.toString().toUpperCase();
      case 'lowercase':
        return value.toString().toLowerCase();
      case 'trim':
        return value.toString().trim();
      case 'toNumber':
        return num.tryParse(value.toString()) ?? 0;
      case 'toString':
        return value.toString();
      case 'toBoolean':
        return value.toString().toLowerCase() == 'true';
      case 'split':
        final delimiter = config?['delimiter'] ?? ',';
        return value.toString().split(delimiter);
      case 'join':
        final delimiter = config?['delimiter'] ?? ',';
        return (value as List).join(delimiter);
      case 'jsonParse':
        return jsonDecode(value.toString());
      case 'jsonStringify':
        return jsonEncode(value);
      default:
        return value;
    }
  }

  dynamic _getNestedValue(Map<String, dynamic> data, String key) {
    if (data.containsKey(key)) {
      return data[key];
    }
    return null;
  }

  dynamic _getNestedValueByPath(Map<String, dynamic> data, String path) {
    final parts = path.split('.');
    dynamic current = data;

    for (final part in parts) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }

    return current;
  }

  void _setNestedValue(Map<String, dynamic> data, String key, dynamic value) {
    final parts = key.split('.');

    if (parts.length == 1) {
      data[key] = value;
      return;
    }

    Map<String, dynamic> current = data;

    for (var i = 0; i < parts.length - 1; i++) {
      final part = parts[i];
      if (!current.containsKey(part)) {
        current[part] = <String, dynamic>{};
      }
      current = current[part] as Map<String, dynamic>;
    }

    current[parts.last] = value;
  }
}
