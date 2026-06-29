import '../../schema/validation_result.dart';
import 'agent_context.dart';
import 'agent_response.dart';
import 'agent_type.dart';
import 'ai_agent.dart';
import 'execution_plan.dart';
import 'orchestrator_agent.dart';

class PlanningAgent extends AIAgent {
  final PlanningStrategy strategy;
  final int maxSteps;
  final bool includeAlternatives;

  PlanningAgent({
    required super.id,
    required super.name,
    required super.description,
    required super.config,
    required this.strategy,
    this.maxSteps = 10,
    this.includeAlternatives = false,
  }) : super(
         type: AgentType.planner,
         capabilities: [AgentCapability.planning, AgentCapability.reasoning],
         tools: [],
       );

  @override
  Future<AgentResponse> execute(AgentContext context) async {
    try {
      final plan = await _generatePlan(context);

      return AgentResponse(
        success: true,
        data: plan.toJson(),
        metadata: {'strategy': strategy.name, 'steps': plan.steps.length},
      );
    } catch (e) {
      return AgentResponse(success: false, data: null, error: e.toString());
    }
  }

  Future<ExecutionPlan> _generatePlan(AgentContext context) async {
    switch (strategy) {
      case PlanningStrategy.goalBased:
        return await _goalBasedPlanning(context);

      case PlanningStrategy.taskDecomposition:
        return await _taskDecomposition(context);

      case PlanningStrategy.hierarchical:
        return await _hierarchicalPlanning(context);

      case PlanningStrategy.reactive:
        return await _reactivePlanning(context);
    }
  }

  Future<ExecutionPlan> _goalBasedPlanning(AgentContext context) async {
    final goal = context.metadata['goal'] as String?;
    if (goal == null) {
      throw Exception('Goal not specified in context');
    }

    // Decompose goal into sub-goals
    final subGoals = await _decomposeGoal(goal);

    // Create execution plan
    return ExecutionPlan(
      agentIds: subGoals.map((g) => g.agentId).toList(),
      strategy: OrchestrationType.sequential,
      metadata: {'goals': subGoals.map((g) => g.description).toList()},
    );
  }

  Future<ExecutionPlan> _taskDecomposition(AgentContext context) async {
    // Break down complex task into simpler subtasks
    final task = context.input as String;
    final subtasks = await _decomposeTask(task);

    return ExecutionPlan(
      agentIds: subtasks.map((t) => t.agentId).toList(),
      strategy: OrchestrationType.sequential,
    );
  }

  Future<ExecutionPlan> _hierarchicalPlanning(AgentContext context) async {
    // Create hierarchical plan with levels
    return ExecutionPlan(agentIds: [], strategy: OrchestrationType.sequential);
  }

  Future<ExecutionPlan> _reactivePlanning(AgentContext context) async {
    // Plan reacts to current state
    return ExecutionPlan(agentIds: [], strategy: OrchestrationType.dynamic);
  }

  Future<List<SubGoal>> _decomposeGoal(String goal) async {
    // Use LLM to decompose goal
    return [SubGoal(description: 'Step 1', agentId: 'agent1')];
  }

  Future<List<SubTask>> _decomposeTask(String task) async {
    // Use LLM to decompose task
    return [SubTask(description: 'Subtask 1', agentId: 'agent1')];
  }

  @override
  ValidationResult validate() {
    return ValidationResult(isValid: true, issues: []);
  }
}

enum PlanningStrategy { goalBased, taskDecomposition, hierarchical, reactive }

class SubGoal {
  final String description;
  final String agentId;

  SubGoal({required this.description, required this.agentId});
}

class SubTask {
  final String description;
  final String agentId;

  SubTask({required this.description, required this.agentId});
}
