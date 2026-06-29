import 'base_log_entry.dart';

class ExecutionLogEntry extends BaseLogEntry {
  final String templateId;
  final String templateName;
  final ExecutionStatus status;
  final Map<String, dynamic>? context;
  final String? outputPath;
  final String? errorMessage;
  final int? outputSize;
  final List<String>? generatedFiles;

  const ExecutionLogEntry({
    required super.id,
    required this.templateId,
    required this.templateName,
    required super.action,
    required super.nodeName,
    required super.timestamp,
    super.processingTime,
    this.status = ExecutionStatus.success,
    this.context,
    this.outputPath,
    this.errorMessage,
    this.outputSize,
    this.generatedFiles,
  });

  ExecutionLogEntry copyWith({
    String? id,
    String? templateId,
    String? templateName,
    String? action,
    String? nodeName,
    DateTime? timestamp,
    Duration? processingTime,
    ExecutionStatus? status,
    Map<String, dynamic>? context,
    String? outputPath,
    String? errorMessage,
    int? outputSize,
    List<String>? generatedFiles,
  }) {
    return ExecutionLogEntry(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      action: action ?? this.action,
      nodeName: nodeName ?? this.nodeName,
      timestamp: timestamp ?? this.timestamp,
      processingTime: processingTime ?? this.processingTime,
      status: status ?? this.status,
      context: context ?? this.context,
      outputPath: outputPath ?? this.outputPath,
      errorMessage: errorMessage ?? this.errorMessage,
      outputSize: outputSize ?? this.outputSize,
      generatedFiles: generatedFiles ?? this.generatedFiles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'templateName': templateName,
      'action': action,
      'nodeName': nodeName,
      'timestamp': timestamp.toIso8601String(),
      'processingTime': processingTime?.inMilliseconds,
      'status': status.name,
      'context': context,
      'outputPath': outputPath,
      'errorMessage': errorMessage,
      'outputSize': outputSize,
      'generatedFiles': generatedFiles,
    };
  }

  factory ExecutionLogEntry.fromJson(Map<String, dynamic> json) {
    return ExecutionLogEntry(
      id: json['id'],
      templateId: json['templateId'],
      templateName: json['templateName'],
      action: json['action'],
      nodeName: json['nodeName'],
      timestamp: DateTime.parse(json['timestamp']),
      processingTime:
          json['processingTime'] != null
              ? Duration(milliseconds: json['processingTime'])
              : null,
      status: ExecutionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ExecutionStatus.success,
      ),
      context:
          json['context'] != null
              ? Map<String, dynamic>.from(json['context'])
              : null,
      outputPath: json['outputPath'],
      errorMessage: json['errorMessage'],
      outputSize: json['outputSize'],
      generatedFiles:
          json['generatedFiles'] != null
              ? List<String>.from(json['generatedFiles'])
              : null,
    );
  }

  bool get isSuccess => status == ExecutionStatus.success;
  bool get isError => status == ExecutionStatus.error;
  bool get isWarning => status == ExecutionStatus.warning;

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

  @override
  String toString() {
    return 'ExecutionLogEntry($templateName - $action - $status)';
  }
}

enum ExecutionStatus { success, error, warning, processing, cancelled }
