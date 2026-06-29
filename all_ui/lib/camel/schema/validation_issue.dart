import 'package:flutter/material.dart';

class ValidationIssue {
  final IssueSeverity severity;
  final IssueCategory category;
  final String message;
  final String? nodeId;
  final String? field;

  const ValidationIssue({
    required this.severity,
    required this.category,
    required this.message,
    this.nodeId,
    this.field,
  });

  IconData get icon {
    switch (severity) {
      case IssueSeverity.error:
        return Icons.error;
      case IssueSeverity.warning:
        return Icons.warning;
      case IssueSeverity.info:
        return Icons.info;
    }
  }

  Color get color {
    switch (severity) {
      case IssueSeverity.error:
        return Colors.red;
      case IssueSeverity.warning:
        return Colors.orange;
      case IssueSeverity.info:
        return Colors.blue;
    }
  }
}

enum IssueSeverity { error, warning, info }

enum IssueCategory {
  structure,
  configuration,
  connections,
  endpoints,
  transformation,
  expression,
  errorHandling,
}
