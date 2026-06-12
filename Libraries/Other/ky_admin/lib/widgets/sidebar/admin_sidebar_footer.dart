import 'package:flutter/material.dart';

import '../../../../widgets/ui/app_icon_action_button.dart';
import '../../models/admin_shell_metadata.dart';

class AdminSidebarFooter extends StatelessWidget {
  const AdminSidebarFooter({
    super.key,
    required this.isCompact,
    this.version = AdminShellMetadata.version,
    this.statusLabel = AdminShellMetadata.workspaceStatus,
    this.onHelpPressed,
  });

  final bool isCompact;
  final String version;
  final String statusLabel;
  final VoidCallback? onHelpPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child:
          isCompact
              ? Center(
                child: AppIconActionButton(
                  icon: Icons.support_agent_outlined,
                  tooltip: 'Help and support',
                  variant: AppIconActionButtonVariant.tonal,
                  onPressed: onHelpPressed,
                ),
              )
              : _ExpandedFooter(
                version: version,
                statusLabel: statusLabel,
                onHelpPressed: onHelpPressed,
              ),
    );
  }
}

class _ExpandedFooter extends StatelessWidget {
  const _ExpandedFooter({
    required this.version,
    required this.statusLabel,
    required this.onHelpPressed,
  });

  final String version;
  final String statusLabel;
  final VoidCallback? onHelpPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.verified_outlined,
              size: 18,
              color: colorScheme.onTertiaryContainer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  statusLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  version,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppIconActionButton(
            icon: Icons.help_outline,
            tooltip: 'Help and support',
            size: 36,
            iconSize: 18,
            onPressed: onHelpPressed,
          ),
        ],
      ),
    );
  }
}
