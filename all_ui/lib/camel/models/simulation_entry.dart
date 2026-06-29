import 'base_log_entry.dart';
import 'execution_log_entry.dart';

class SimulationLogEntry {
  final String id;
  final String simulationId;
  final String action;
  final String nodeName;
  final String? nodeId;
  final DateTime timestamp;
  final Duration? processingTime;
  final Map<String, dynamic>? data;
  final SimulationStatus status;

  const SimulationLogEntry({
    required this.id,
    required this.simulationId,
    required this.action,
    required this.nodeName,
    this.nodeId,
    required this.timestamp,
    this.processingTime,
    this.data,
    this.status = SimulationStatus.info,
  });

  SimulationLogEntry copyWith({
    String? id,
    String? simulationId,
    String? action,
    String? nodeName,
    String? nodeId,
    DateTime? timestamp,
    Duration? processingTime,
    Map<String, dynamic>? data,
    SimulationStatus? status,
  }) {
    return SimulationLogEntry(
      id: id ?? this.id,
      simulationId: simulationId ?? this.simulationId,
      action: action ?? this.action,
      nodeName: nodeName ?? this.nodeName,
      nodeId: nodeId ?? this.nodeId,
      timestamp: timestamp ?? this.timestamp,
      processingTime: processingTime ?? this.processingTime,
      data: data ?? this.data,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'simulationId': simulationId,
      'action': action,
      'nodeName': nodeName,
      'nodeId': nodeId,
      'timestamp': timestamp.toIso8601String(),
      'processingTime': processingTime?.inMilliseconds,
      'data': data,
      'status': status.name,
    };
  }

  factory SimulationLogEntry.fromJson(Map<String, dynamic> json) {
    return SimulationLogEntry(
      id: json['id'],
      simulationId: json['simulationId'],
      action: json['action'],
      nodeName: json['nodeName'],
      nodeId: json['nodeId'],
      timestamp: DateTime.parse(json['timestamp']),
      processingTime:
          json['processingTime'] != null
              ? Duration(milliseconds: json['processingTime'])
              : null,
      data:
          json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      status: SimulationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SimulationStatus.info,
      ),
    );
  }

  // Convert to ExecutionLogEntry for compatibility
  ExecutionLogEntry toExecutionLogEntry({
    required String templateId,
    required String templateName,
  }) {
    return ExecutionLogEntry(
      id: id,
      templateId: templateId,
      templateName: templateName,
      action: action,
      nodeName: nodeName,
      timestamp: timestamp,
      processingTime: processingTime,
      status: status.toExecutionStatus(),
      context: data,
    );
  }

  String get formattedProcessingTime {
    if (processingTime == null) return 'N/A';
    if (processingTime!.inMilliseconds < 1000) {
      return '${processingTime!.inMilliseconds}ms';
    }
    return '${(processingTime!.inMilliseconds / 1000).toStringAsFixed(2)}s';
  }

  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }
}

enum SimulationStatus {
  info,
  success,
  warning,
  error;

  ExecutionStatus toExecutionStatus() {
    switch (this) {
      case SimulationStatus.info:
        return ExecutionStatus.success;
      case SimulationStatus.success:
        return ExecutionStatus.success;
      case SimulationStatus.warning:
        return ExecutionStatus.warning;
      case SimulationStatus.error:
        return ExecutionStatus.error;
    }
  }
}
