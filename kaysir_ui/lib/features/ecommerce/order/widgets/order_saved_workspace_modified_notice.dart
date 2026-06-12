import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';

class OrderSavedWorkspaceModifiedNotice extends StatelessWidget {
  final String? workspaceLabel;
  final String? changeSummary;
  final VoidCallback? onRevertActive;
  final VoidCallback? onUpdateActive;

  const OrderSavedWorkspaceModifiedNotice({
    super.key,
    required this.workspaceLabel,
    required this.changeSummary,
    required this.onRevertActive,
    required this.onUpdateActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warning = theme.colorScheme.tertiary;

    return Container(
      key: const ValueKey('order_saved_workspace_modified_notice'),
      padding: const EdgeInsets.all(POSUiTokens.gap),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: warning.withValues(alpha: 0.24)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth.isFinite && constraints.maxWidth < 380;
          final title = _SavedWorkspaceModifiedNoticeTitle(
            color: warning,
            workspaceLabel: workspaceLabel,
            changeSummary: changeSummary,
          );
          final actions = _SavedWorkspaceModifiedNoticeActions(
            onRevertActive: onRevertActive,
            onUpdateActive: onUpdateActive,
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                title,
                const SizedBox(height: POSUiTokens.gap),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: title),
              const SizedBox(width: POSUiTokens.gap),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _SavedWorkspaceModifiedNoticeTitle extends StatelessWidget {
  final Color color;
  final String? workspaceLabel;
  final String? changeSummary;

  const _SavedWorkspaceModifiedNoticeTitle({
    required this.color,
    required this.workspaceLabel,
    required this.changeSummary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(Icons.edit_note_rounded, size: 20, color: color),
        const SizedBox(width: POSUiTokens.gap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_effectiveWorkspaceLabel modified',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (_effectiveChangeSummary.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  _effectiveChangeSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String get _effectiveWorkspaceLabel {
    final label = workspaceLabel?.trim();
    if (label == null || label.isEmpty) return 'Shortcut';

    return label;
  }

  String get _effectiveChangeSummary => changeSummary?.trim() ?? '';
}

class _SavedWorkspaceModifiedNoticeActions extends StatelessWidget {
  final VoidCallback? onRevertActive;
  final VoidCallback? onUpdateActive;

  const _SavedWorkspaceModifiedNoticeActions({
    required this.onRevertActive,
    required this.onUpdateActive,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (onRevertActive != null)
          TextButton.icon(
            key: const ValueKey('order_revert_active_workspace'),
            onPressed: onRevertActive,
            icon: const Icon(Icons.undo_rounded, size: 16),
            label: const Text('Revert'),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        if (onUpdateActive != null)
          FilledButton.icon(
            key: const ValueKey('order_update_active_workspace'),
            onPressed: onUpdateActive,
            icon: const Icon(Icons.save_outlined, size: 16),
            label: const Text('Update'),
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
      ],
    );
  }
}
