import 'package:flutter/material.dart';

import '../../../execution/model/node_execution_result.dart';
import '../../../plugin/model/node_exceutor.dart';
import '../../../plugin/model/node_execution_context.dart';

import '../../../plugin/model/node_schema.dart';
import '../../../plugin/model/port_definition.dart';
import '../../../plugin/model/port_schema.dart';
import 'guardrail_executor.dart';
import 'guardrail_node_definition.dart';

class GuardrailNodeExecutor implements NodeExecutor {
  final GuardrailNodeDefinition definition;

  GuardrailNodeExecutor(this.definition);

  @override
  String get nodeType => 'guardrail_check';

  @override
  NodeSchema get schema => NodeSchema(
    name: definition.name,
    description: definition.description,
    category: 'Guardrails',
    icon: Icons.shield,
    color: Colors.orange,
    inputs: definition.inputs.map(_convertPortSchema).toList(),
    outputs: definition.outputs.map(_convertPortSchema).toList(),
  );

  PortSchema _convertPortSchema(PortDefinition port) {
    // Map dataType to PortType if you have a mapping
    // For now, assume 'string' → PortType.string, else PortType.any
    final type = _mapDataTypeToPortType(port.dataType);
    return PortSchema(
      id: port.id,
      name: port.name,
      description: port.description,
      type: type,
    );
  }

  PortType _mapDataTypeToPortType(String dataType) {
    switch (dataType) {
      case 'string':
        return PortType.string;
      case 'number':
        return PortType.number;
      case 'boolean':
        return PortType.boolean;
      case 'object':
        return PortType.object;
      default:
        return PortType.any;
    }
  }

  @override
  Future<NodeExecutionResult> execute(NodeExecutionContext context) async {
    final startTime = DateTime.now();

    try {
      final input = context.inputs['input'] as String?;

      if (input == null || input.trim().isEmpty) {
        return NodeExecutionResult.failure(
          nodeId: context.nodeId,
          error: 'Input is required and must be a non-empty string',
          duration: DateTime.now().difference(startTime),
          metadata: null,
        );
      }

      final executor = GuardrailExecutor(definition.rules);
      final result = await executor.check(input);

      // Build structured output
      final outputData = <String, dynamic>{
        'original_input': input,
        'passed': result.passed,
        'violations': result.violations
            .map(
              (v) => {
                'rule_id': v.ruleId,
                'rule_name': v.ruleName,
                'type': v.type.name, // ✅ use .name, not .toString()
                'severity': v.severity.name,
                'action':
                    v.action.name, // assuming GuardrailViolation has action
                'message': v.message,
                'confidence': v.confidence,
                'details': v.details,
              },
            )
            .toList(),
      };

      if (result.sanitizedInput != null) {
        outputData['sanitized_input'] = result.sanitizedInput;
      }

      final portId = result.passed ? 'passed' : 'failed';

      return NodeExecutionResult.success(
        nodeId: context.nodeId,
        outputs: {portId: outputData},
        duration: DateTime.now().difference(startTime),
        metadata: null, // or add debug info if in debug mode
      );
    } catch (e, stackTrace) {
      // Log error internally if you have a logger
      return NodeExecutionResult.failure(
        nodeId: context.nodeId,
        error: 'Guardrail execution failed: ${e.toString()}',
        duration: DateTime.now().difference(startTime),
        metadata: {
          'exception': e.toString(),
          'stack_trace': stackTrace.toString(),
        },
      );
    }
  }
}
