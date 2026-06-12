import 'package:flutter/material.dart';

import 'app_icon_badge.dart';
import 'app_text_cluster.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.leadingIcon,
    this.action,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final IconData? leadingIcon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 680;
        final titleBlock = _TitleBlock(
          title: title,
          subtitle: subtitle,
          eyebrow: eyebrow,
          leadingIcon: leadingIcon,
        );

        if (action == null) {
          return titleBlock;
        }

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 14),
              Align(alignment: Alignment.centerLeft, child: action),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 16),
            action!,
          ],
        );
      },
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    required this.leadingIcon,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leadingIcon != null) ...[
          AppIconBadge(
            icon: leadingIcon!,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: AppTextCluster(
            eyebrow: eyebrow,
            title: title,
            subtitle: subtitle,
            titleStyle: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            subtitleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
