import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_accessibility.dart';
import 'order_saved_workspace_chip_action_menu.dart';
import 'order_saved_workspace_note_marker.dart';

class OrderSavedWorkspaceChip extends StatelessWidget {
  final OrderSavedWorkspace workspace;
  final bool selected;
  final VoidCallback? onSelected;
  final VoidCallback? onDeleted;
  final VoidCallback? onDuplicated;
  final ValueChanged<bool>? onPinnedChanged;
  final ValueChanged<String>? onRenamed;
  final ValueChanged<String>? onDescriptionChanged;
  final VoidCallback? onDescriptionReset;
  final ValueChanged<OrderSavedWorkspaceMoveDirection>? onMoved;
  final bool canMoveEarlier;
  final bool canMoveLater;

  const OrderSavedWorkspaceChip({
    super.key,
    required this.workspace,
    required this.selected,
    required this.onSelected,
    required this.onDeleted,
    required this.onDuplicated,
    required this.onPinnedChanged,
    required this.onRenamed,
    required this.onDescriptionChanged,
    required this.onDescriptionReset,
    required this.onMoved,
    required this.canMoveEarlier,
    required this.canMoveLater,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground =
        selected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant;

    return Tooltip(
      message: orderSavedWorkspaceChipTooltip(workspace),
      child: Container(
        key: ValueKey('order_saved_workspace_${workspace.id}'),
        decoration: BoxDecoration(
          color:
              selected
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          border: Border.all(
            color:
                selected
                    ? theme.colorScheme.primary.withValues(alpha: 0.34)
                    : theme.dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              button: onSelected != null,
              enabled: onSelected != null,
              selected: selected,
              label: orderSavedWorkspaceChipSemanticsLabel(
                workspace: workspace,
                selected: selected,
              ),
              hint: orderSavedWorkspaceChipSemanticsHint(workspace),
              child: InkWell(
                borderRadius: BorderRadius.circular(POSUiTokens.radius),
                onTap: onSelected,
                child: ExcludeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          workspace.isPinned
                              ? Icons.push_pin_rounded
                              : selected
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 16,
                          color: foreground,
                        ),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: Text(
                            workspace.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (workspace.isDescriptionCustom) ...[
                          const SizedBox(width: 6),
                          OrderSavedWorkspaceNoteMarker(
                            workspace: workspace,
                            selected: selected,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            OrderSavedWorkspaceChipActionMenu(
              workspace: workspace,
              foregroundColor: foreground,
              onDeleted: onDeleted,
              onDuplicated: onDuplicated,
              onPinnedChanged: onPinnedChanged,
              onRenamed: onRenamed,
              onDescriptionChanged: onDescriptionChanged,
              onDescriptionReset: onDescriptionReset,
              onMoved: onMoved,
              canMoveEarlier: canMoveEarlier,
              canMoveLater: canMoveLater,
            ),
          ],
        ),
      ),
    );
  }
}
