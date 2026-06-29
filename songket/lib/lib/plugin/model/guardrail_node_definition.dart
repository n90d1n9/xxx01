import 'package:flutter/material.dart';

import '../../../plugin/model/node_definition.dart';
import '../../../plugin/model/port_definition.dart';
import 'guardrail_action.dart';
import 'guardrail_rule.dart';

class GuardrailNodeDefinition extends NodeDefinition {
  // Optional: expose action for convenience, but don't duplicate state
  GuardrailAction get guardrailAction => action as GuardrailAction;
  final List<GuardrailRule> rules;
  final bool stopOnFirstViolation;
  final bool returnViolations;
  GuardrailNodeDefinition({
    required super.id,
    required super.name,
    required super.description,
    required this.rules,
    this.stopOnFirstViolation = false,
    this.returnViolations = true,
  }) : super(
         type: 'guardrail_check',
         icon: Icons.shield,
         color: Colors.orange,
         inputs: [
           PortDefinition(
             id: 'input',
             name: 'Input',
             description: 'Text to check against guardrails',
             dataType: 'string',
             required: true,
           ),
         ],
         outputs: [
           PortDefinition(
             id: 'passed',
             name: 'Passed',
             description: 'Output when input passes all checks',
             dataType: 'object',
           ),
           PortDefinition(
             id: 'failed',
             name: 'Failed',
             description: 'Output when input fails checks',
             dataType: 'object',
           ),
         ],
         configFields: [], // Consider populating if rules are editable in UI
         requiredSecrets: [],
         action: GuardrailAction(
           rules: rules,
           stopOnFirstViolation: stopOnFirstViolation,
           returnViolations: returnViolations,
         ),
       );

  // Optional: convenience constructor from action
  factory GuardrailNodeDefinition.fromAction({
    required String id,
    required String name,
    required String description,
    required GuardrailAction action,
  }) => GuardrailNodeDefinition(
    id: id,
    name: name,
    description: description,
    rules: action.rules,
    stopOnFirstViolation: action.stopOnFirstViolation,
    returnViolations: action.returnViolations,
  );
}
