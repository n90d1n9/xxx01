class CodeMappings {
  final Map<String, dynamic>? nodeToCode;
  final Map<String, dynamic>? workflowToCode;
  final Map<String, dynamic>? connectorToCode;

  CodeMappings({this.nodeToCode, this.workflowToCode, this.connectorToCode});

  factory CodeMappings.fromJson(Map<String, dynamic> json) {
    return CodeMappings(
      nodeToCode: json['nodeToCode'] != null
          ? Map<String, dynamic>.from(json['nodeToCode'] as Map)
          : null,
      workflowToCode: json['workflowToCode'] != null
          ? Map<String, dynamic>.from(json['workflowToCode'] as Map)
          : null,
      connectorToCode: json['connectorToCode'] != null
          ? Map<String, dynamic>.from(json['connectorToCode'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (nodeToCode != null) 'nodeToCode': nodeToCode,
      if (workflowToCode != null) 'workflowToCode': workflowToCode,
      if (connectorToCode != null) 'connectorToCode': connectorToCode,
    };
  }
}
