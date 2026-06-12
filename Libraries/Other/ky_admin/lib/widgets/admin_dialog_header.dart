import 'package:flutter/material.dart';

import '../../../widgets/ui/app_icon_action_button.dart';
import '../../../widgets/ui/app_icon_badge.dart';
import '../../../widgets/ui/app_text_cluster.dart';

class AdminDialogHeader extends StatelessWidget {
  const AdminDialogHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onClose,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 10, 14),
      child: Row(
        children: [
          AppIconBadge(
            icon: icon,
            size: 40,
            iconSize: 21,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppTextCluster(
              title: title,
              subtitle: subtitle,
              titleMaxLines: 1,
              subtitleMaxLines: 1,
              titleOverflow: TextOverflow.ellipsis,
              subtitleOverflow: TextOverflow.ellipsis,
              titleGap: 0,
              titleStyle: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              subtitleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppIconActionButton(
            icon: Icons.close,
            tooltip: 'Close dialog',
            size: 36,
            iconSize: 18,
            onPressed: onClose ?? () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}
