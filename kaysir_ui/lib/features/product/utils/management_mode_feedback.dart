import 'package:flutter/material.dart';

import '../states/management_workspace_preferences_controller.dart';

/// Builds the concise pack/profile message shown after workspace mode changes.
String productManagementModeFeedbackMessage({
  required String label,
  required ProductManagementWorkspaceSelection selection,
}) {
  return '$label: ${selection.pack.title} / ${selection.channelProfile.title}';
}

/// Shows a floating snackbar for product management mode changes.
void showProductManagementModeFeedback(
  BuildContext context, {
  required String label,
  required ProductManagementWorkspaceSelection selection,
  SnackBarAction? action,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          productManagementModeFeedbackMessage(
            label: label,
            selection: selection,
          ),
        ),
        action: action,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1800),
      ),
    );
}
