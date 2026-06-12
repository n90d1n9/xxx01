import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_dialog_actions.dart';
import '../../../widgets/ui/app_icon_action_button.dart';
import '../models/admin_shell_metadata.dart';
import '../services/admin_shell_layout_resolver.dart';

class AdminFooter extends StatelessWidget {
  const AdminFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final layout = resolveAdminShellLayout(MediaQuery.sizeOf(context).width);

    return Container(
      height: layout.footerHeight,
      padding: EdgeInsets.symmetric(horizontal: layout.horizontalPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(child: _FooterCopyright(isWide: layout.showFooterStatus)),
          if (layout.showFooterStatus) ...[
            const SizedBox(width: 12),
            const _FooterStatusPill(),
          ],
          if (layout.showFooterLinks) ...[
            const SizedBox(width: 8),
            _FooterTextAction(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy',
              onPressed:
                  () => _openInfoDialog(
                    context,
                    title: 'Privacy',
                    icon: Icons.privacy_tip_outlined,
                    message: AdminShellMetadata.privacySummary,
                  ),
            ),
            _FooterTextAction(
              icon: Icons.gavel_outlined,
              label: 'Terms',
              onPressed:
                  () => _openInfoDialog(
                    context,
                    title: 'Terms',
                    icon: Icons.gavel_outlined,
                    message: AdminShellMetadata.termsSummary,
                  ),
            ),
          ],
          AppIconActionButton(
            icon: Icons.support_agent,
            onPressed:
                () => _openInfoDialog(
                  context,
                  title: 'Support',
                  icon: Icons.support_agent,
                  message: AdminShellMetadata.supportSummary,
                ),
            tooltip: 'Contact support',
          ),
        ],
      ),
    );
  }

  Future<void> _openInfoDialog(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: Icon(icon),
            title: Text(title),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(message),
            ),
            actions: [
              AppDialogActions(
                confirmLabel: 'Close',
                confirmVariant: AppActionButtonVariant.text,
                onConfirm: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }
}

class _FooterCopyright extends StatelessWidget {
  const _FooterCopyright({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final text =
        isWide
            ? '©${DateTime.now().year} ${AdminShellMetadata.companyName}'
            : AdminShellMetadata.companyName;

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _FooterStatusPill extends StatelessWidget {
  const _FooterStatusPill();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 15,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${AdminShellMetadata.workspaceStatus} • ${AdminShellMetadata.version}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterTextAction extends StatelessWidget {
  const _FooterTextAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppActionButton(
      icon: icon,
      label: label,
      variant: AppActionButtonVariant.text,
      compact: true,
      onPressed: onPressed,
    );
  }
}
