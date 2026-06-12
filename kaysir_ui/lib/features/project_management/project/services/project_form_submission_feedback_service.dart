import 'package:flutter/material.dart';

/// Outcome kind used to format project form submission feedback.
enum ProjectFormSubmissionFeedbackKind { created, updated }

String projectFormSubmissionFeedbackMessage({
  required String projectName,
  required ProjectFormSubmissionFeedbackKind kind,
}) {
  final actionLabel = switch (kind) {
    ProjectFormSubmissionFeedbackKind.created => 'created',
    ProjectFormSubmissionFeedbackKind.updated => 'updated',
  };

  return 'Project $actionLabel: $projectName';
}

void showProjectFormSubmissionFeedback(
  BuildContext context, {
  required String projectName,
  required ProjectFormSubmissionFeedbackKind kind,
  SnackBarAction? action,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          projectFormSubmissionFeedbackMessage(
            projectName: projectName,
            kind: kind,
          ),
        ),
        action: action,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2200),
      ),
    );
}
