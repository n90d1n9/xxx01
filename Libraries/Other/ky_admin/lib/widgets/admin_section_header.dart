import 'package:flutter/material.dart';

import '../../../widgets/ui/app_icon_badge.dart';
import '../../../widgets/ui/app_text_cluster.dart';

class AdminSectionHeader extends StatelessWidget {
  const AdminSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.titleMaxLines = 1,
    this.subtitleMaxLines = 2,
    this.compactBreakpoint = 520,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final int titleMaxLines;
  final int subtitleMaxLines;
  final double compactBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final titleRow = _AdminSectionTitleRow(
          title: title,
          subtitle: subtitle,
          leadingIcon: leadingIcon,
          titleMaxLines: titleMaxLines,
          subtitleMaxLines: subtitleMaxLines,
        );

        if (trailing == null) return titleRow;

        if (constraints.maxWidth < compactBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleRow,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: trailing),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleRow),
            const SizedBox(width: 12),
            Flexible(
              child: Align(alignment: Alignment.centerRight, child: trailing),
            ),
          ],
        );
      },
    );
  }
}

class _AdminSectionTitleRow extends StatelessWidget {
  const _AdminSectionTitleRow({
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.titleMaxLines,
    required this.subtitleMaxLines,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final int titleMaxLines;
  final int subtitleMaxLines;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leadingIcon != null) ...[
          AppIconBadge(
            icon: leadingIcon!,
            size: 36,
            iconSize: 18,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: AppTextCluster(
            title: title,
            subtitle: subtitle,
            titleMaxLines: titleMaxLines,
            subtitleMaxLines: subtitleMaxLines,
            titleOverflow: TextOverflow.ellipsis,
            subtitleOverflow: TextOverflow.ellipsis,
            titleGap: 4,
            titleStyle: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            subtitleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
