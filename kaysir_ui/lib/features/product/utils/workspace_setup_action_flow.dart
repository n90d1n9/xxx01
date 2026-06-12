import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/management_pack.dart';
import '../models/product_workspace_setup_action.dart';
import '../states/management_workspace_preferences_controller.dart';
import 'management_mode_feedback.dart';
import 'management_route_mode.dart';

/// Selects the product management pack required by a setup action.
typedef ProductWorkspaceSetupPackSelector =
    Future<ProductManagementWorkspaceSelection> Function(
      ProductManagementPackId packId,
    );

/// Opens a product workspace setup action or activates its required pack.
Future<void> openProductWorkspaceSetupAction({
  required BuildContext context,
  required ProductWorkspaceSetupAction action,
  required ProductManagementRouteMode routeMode,
  required ProductWorkspaceSetupPackSelector selectPack,
  bool showDefaultActivationFeedback = true,
}) async {
  final activationPackId = action.activationPackId;
  if (activationPackId != null) {
    final selection = await selectPack(activationPackId);
    if (!context.mounted) return;

    final feedbackMessage = action.activationFeedbackMessage;
    if (feedbackMessage != null) {
      _showSetupActionMessage(context, feedbackMessage);
      return;
    }

    if (showDefaultActivationFeedback) {
      showProductManagementModeFeedback(
        context,
        label: 'Product mode switched',
        selection: selection,
      );
    }
    return;
  }

  context.go(productRouteWithManagementMode(action.routePath, mode: routeMode));
}

void _showSetupActionMessage(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}
