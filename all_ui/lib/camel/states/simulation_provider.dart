import 'package:flutter_riverpod/legacy.dart';

import '../models/execution_log_entry.dart';
import '../models/simulation_entry.dart';
import '../models/simulation_state.dart';

class SimulationNotifier extends StateNotifier<SimulationState> {
  SimulationNotifier() : super(SimulationState());

  void start(Map<String, dynamic> initialData) {
    state = SimulationState(
      isRunning: true,
      messageData: initialData,
      executionLog: [
        SimulationLogEntry(
          id: 'log_${DateTime.now().millisecondsSinceEpoch}',
          simulationId: state.simulationId,
          timestamp: DateTime.now(),
          nodeName: 'System',
          action: 'Simulation started',
          data: initialData,
        ),
      ],
    );
  }

  void processNode(
    String nodeId,
    String nodeName,
    Map<String, dynamic>? transformedData,
  ) {
    if (!state.isRunning || state.isPaused) return;

    final startTime = DateTime.now();

    // Simulate processing delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!state.isRunning) return; // Check if still running after delay

      final processingTime = DateTime.now().difference(startTime);

      state = state.copyWith(
        currentNodeId: nodeId,
        messageData: transformedData ?? state.messageData,
        executionLog: [
          ...state.executionLog,
          SimulationLogEntry(
            id: 'log_${DateTime.now().millisecondsSinceEpoch}',
            simulationId: state.simulationId,
            timestamp: DateTime.now(),
            nodeId: nodeId,
            nodeName: nodeName,
            action: 'Processed',
            data: transformedData,
            processingTime: processingTime,
            status: SimulationStatus.success,
          ),
        ],
        currentStep: state.currentStep + 1,
      );
    });
  }

  void addLogEntry({
    required String action,
    required String nodeName,
    String? nodeId,
    Map<String, dynamic>? data,
    SimulationStatus status = SimulationStatus.info,
    Duration? processingTime,
  }) {
    state = state.copyWith(
      executionLog: [
        ...state.executionLog,
        SimulationLogEntry(
          id: 'log_${DateTime.now().millisecondsSinceEpoch}',
          simulationId: state.simulationId,
          timestamp: DateTime.now(),
          nodeName: nodeName,
          nodeId: nodeId,
          action: action,
          data: data,
          status: status,
          processingTime: processingTime,
        ),
      ],
    );
  }

  void pause() {
    if (!state.isRunning) return;

    state = state.copyWith(isPaused: true);
    addLogEntry(
      action: 'Simulation paused',
      nodeName: 'System',
      status: SimulationStatus.warning,
    );
  }

  void resume() {
    if (!state.isRunning || !state.isPaused) return;

    state = state.copyWith(isPaused: false);
    addLogEntry(
      action: 'Simulation resumed',
      nodeName: 'System',
      status: SimulationStatus.info,
    );
  }

  void step() {
    if (!state.isRunning || state.isPaused) return;

    // Move to next node in simulation
    state = state.copyWith(currentStep: state.currentStep + 1);
    addLogEntry(
      action: 'Step advanced',
      nodeName: 'System',
      nodeId: 'step_${state.currentStep + 1}',
      status: SimulationStatus.info,
    );
  }

  void stop() {
    if (!state.isRunning) return;

    state = state.copyWith(
      isRunning: false,
      currentNodeId: null,
      isPaused: false,
    );

    addLogEntry(
      action: 'Simulation stopped',
      nodeName: 'System',
      status: SimulationStatus.info,
    );
  }

  void reset() {
    state = SimulationState();
  }

  void simulateError(String nodeId, String nodeName, String errorMessage) {
    addLogEntry(
      action: 'Error: $errorMessage',
      nodeName: nodeName,
      nodeId: nodeId,
      status: SimulationStatus.error,
    );
  }

  void simulateWarning(String nodeId, String nodeName, String warningMessage) {
    addLogEntry(
      action: 'Warning: $warningMessage',
      nodeName: nodeName,
      nodeId: nodeId,
      status: SimulationStatus.warning,
    );
  }

  // Get execution log as ExecutionLogEntry for compatibility
  List<ExecutionLogEntry> getExecutionLogAsTemplateLog({
    String templateId = 'simulation',
    String templateName = 'Simulation',
  }) {
    return state.executionLog
        .map(
          (entry) => entry.toExecutionLogEntry(
            templateId: templateId,
            templateName: templateName,
          ),
        )
        .toList();
  }
}

final simulationProvider =
    StateNotifierProvider<SimulationNotifier, SimulationState>((ref) {
      return SimulationNotifier();
    });
