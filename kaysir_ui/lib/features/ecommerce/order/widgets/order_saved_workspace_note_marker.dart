import 'package:flutter/material.dart';

import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_accessibility.dart';

class OrderSavedWorkspaceNoteMarker extends StatelessWidget {
  final OrderSavedWorkspace workspace;
  final bool selected;

  const OrderSavedWorkspaceNoteMarker({
    super.key,
    required this.workspace,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!workspace.isDescriptionCustom) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final foreground =
        selected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.tertiary;
    final background =
        selected
            ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.12)
            : theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5);

    return Tooltip(
      message: orderSavedWorkspaceNoteTooltip(workspace),
      child: Semantics(
        label: orderSavedWorkspaceNoteSemanticsLabel(workspace),
        hint: orderSavedWorkspaceNoteSemanticsHint(workspace),
        child: Container(
          key: ValueKey('order_saved_workspace_note_marker_${workspace.id}'),
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(color: foreground.withValues(alpha: 0.22)),
          ),
          child: Icon(
            Icons.sticky_note_2_outlined,
            size: 12,
            color: foreground,
          ),
        ),
      ),
    );
  }
}
