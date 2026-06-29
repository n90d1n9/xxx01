// Simulation State (Enhanced)
import 'simulation_entry.dart';

class SimulationState {
  final bool isRunning;
  final String? currentNodeId;
  final Map<String, dynamic> messageData;
  final List<SimulationLogEntry> executionLog;
  final int currentStep;
  final bool isPaused;
  final String simulationId;

  SimulationState({
    this.isRunning = false,
    this.currentNodeId,
    this.messageData = const {},
    this.executionLog = const [],
    this.currentStep = 0,
    this.isPaused = false,
    String? simulationId,
  }) : simulationId =
           simulationId ?? 'sim_${DateTime.now().millisecondsSinceEpoch}';

  SimulationState copyWith({
    bool? isRunning,
    String? currentNodeId,
    Map<String, dynamic>? messageData,
    List<SimulationLogEntry>? executionLog,
    int? currentStep,
    bool? isPaused,
    String? simulationId,
  }) {
    return SimulationState(
      isRunning: isRunning ?? this.isRunning,
      currentNodeId: currentNodeId ?? this.currentNodeId,
      messageData: messageData ?? this.messageData,
      executionLog: executionLog ?? this.executionLog,
      currentStep: currentStep ?? this.currentStep,
      isPaused: isPaused ?? this.isPaused,
      simulationId: simulationId ?? this.simulationId,
    );
  }
}
