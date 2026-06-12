import 'package:flutter/material.dart';

/// Displays the workspace command center title, active state, and reset action.
class RestaurantWorkspaceCommandCenterHeader extends StatelessWidget {
  const RestaurantWorkspaceCommandCenterHeader({
    super.key,
    required this.activeStateLabel,
    required this.canReset,
    required this.onReset,
  });

  static const double _compactWidth = 360;

  final String activeStateLabel;
  final bool canReset;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Command center',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          activeStateLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
    final resetControl = RestaurantWorkspaceResetControl(
      canReset: canReset,
      onReset: onReset,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _compactWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 8), resetControl],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const SizedBox(width: 12),
            resetControl,
          ],
        );
      },
    );
  }
}

/// Displays the reset action for workspace filters and search controls.
class RestaurantWorkspaceResetControl extends StatelessWidget {
  const RestaurantWorkspaceResetControl({
    super.key,
    required this.canReset,
    required this.onReset,
  });

  final bool canReset;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: canReset,
      label: canReset
          ? 'Reset workspace controls'
          : 'Workspace controls already default',
      child: Tooltip(
        message: canReset
            ? 'Reset workspace filters and search'
            : 'Workspace controls are already default',
        child: TextButton.icon(
          onPressed: canReset ? onReset : null,
          icon: const Icon(Icons.restart_alt_rounded, size: 16),
          label: const Text('Reset'),
        ),
      ),
    );
  }
}
