import '../../schema/validation_issue.dart';
import '../../schema/validation_result.dart';
import 'agent_context.dart';
import 'agent_response.dart';
import 'agent_type.dart';
import 'ai_agent.dart';
import 'execution_plan.dart';
import 'execution_step.dart';

class OrchestratorAgent extends AIAgent {
  final List<String> subAgentIds;
  final OrchestrationType orchestrationType;
  final Map<String, dynamic> routingRules;

  OrchestratorAgent({
    required super.id,
    required super.name,
    required super.description,
    required super.config,
    required this.subAgentIds,
    required this.orchestrationType,
    required this.routingRules,
  }) : super(
         type: AgentType.orchestrator,
         capabilities: [
           AgentCapability.orchestration,
           AgentCapability.planning,
           AgentCapability.execution,
         ],
         tools: [],
       );

  @override
  Future<AgentResponse> execute(AgentContext context) async {
    final steps = <ExecutionStep>[];

    try {
      // Plan execution order
      final executionPlan = await _planExecution(context);

      // Execute based on orchestration type
      switch (orchestrationType) {
        case OrchestrationType.sequential:
          return await _executeSequential(executionPlan, context, steps);

        case OrchestrationType.parallel:
          return await _executeParallel(executionPlan, context, steps);

        case OrchestrationType.conditional:
          return await _executeConditional(executionPlan, context, steps);

        case OrchestrationType.dynamic:
          return await _executeDynamic(executionPlan, context, steps);
      }
    } catch (e) {
      return AgentResponse(
        success: false,
        data: null,
        error: e.toString(),
        steps: steps,
        metadata: {'orchestrator': id},
      );
    }
  }

  Future<ExecutionPlan> _planExecution(AgentContext context) async {
    // Analyze context and determine execution strategy
    final plan = ExecutionPlan(
      agentIds: subAgentIds,
      strategy: orchestrationType,
      estimatedDuration: _estimateDuration(),
    );

    return plan;
  }

  Future<AgentResponse> _executeSequential(
    ExecutionPlan plan,
    AgentContext context,
    List<ExecutionStep> steps,
  ) async {
    dynamic currentData = context.input;

    for (final agentId in plan.agentIds) {
      final agent = await _getAgent(agentId);
      final agentContext = context.copyWith(input: currentData);

      final response = await agent.execute(agentContext);
      steps.add(
        ExecutionStep(
          agentId: agentId,
          agentName: agent.name,
          success: response.success,
          output: response.data,
          duration: response.duration,
        ),
      );

      if (!response.success && config['stopOnError'] == true) {
        return AgentResponse(
          success: false,
          data: currentData,
          error: response.error,
          steps: steps,
        );
      }

      currentData = response.data;
    }

    return AgentResponse(
      success: true,
      data: currentData,
      steps: steps,
      metadata: {'type': 'sequential'},
    );
  }

  Future<AgentResponse> _executeParallel(
    ExecutionPlan plan,
    AgentContext context,
    List<ExecutionStep> steps,
  ) async {
    final futures = plan.agentIds.map((agentId) async {
      final agent = await _getAgent(agentId);
      return await agent.execute(context);
    });

    final responses = await Future.wait(futures);

    // Aggregate results
    final allSuccess = responses.every((r) => r.success);
    final aggregatedData = responses.map((r) => r.data).toList();

    return AgentResponse(
      success: allSuccess,
      data: aggregatedData,
      steps: steps,
      metadata: {'type': 'parallel'},
    );
  }

  Future<AgentResponse> _executeConditional(
    ExecutionPlan plan,
    AgentContext context,
    List<ExecutionStep> steps,
  ) async {
    // Evaluate routing rules to determine which agents to execute
    for (final rule in routingRules.entries) {
      if (_evaluateCondition(rule.key, context)) {
        final agentIds = rule.value as List<String>;
        return await _executeSequential(
          ExecutionPlan(
            agentIds: agentIds,
            strategy: OrchestrationType.sequential,
          ),
          context,
          steps,
        );
      }
    }

    return AgentResponse(
      success: false,
      data: null,
      error: 'No matching condition',
      steps: steps,
    );
  }

  Future<AgentResponse> _executeDynamic(
    ExecutionPlan plan,
    AgentContext context,
    List<ExecutionStep> steps,
  ) async {
    // Use LLM to determine execution order dynamically
    // This would integrate with your AI model
    return await _executeSequential(plan, context, steps);
  }

  bool _evaluateCondition(String condition, AgentContext context) {
    // Simple condition evaluation
    // In production, use proper expression evaluator
    return true;
  }

  Duration _estimateDuration() {
    return Duration(seconds: subAgentIds.length * 2);
  }

  Future<AIAgent> _getAgent(String agentId) async {
    // Get agent from registry
    throw UnimplementedError('Agent registry not implemented');
  }

  @override
  ValidationResult validate() {
    final issues = <ValidationIssue>[];

    if (subAgentIds.isEmpty) {
      issues.add(
        ValidationIssue(
          severity: IssueSeverity.error,
          category: IssueCategory.configuration,
          message: 'Orchestrator must have at least one sub-agent',
        ),
      );
    }

    return ValidationResult(isValid: issues.isEmpty, issues: issues);
  }
}

enum OrchestrationType { sequential, parallel, conditional, dynamic }
