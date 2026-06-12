import 'package:flutter/material.dart';

import '../../../widgets/ui/app_icon_badge.dart';
import '../../../widgets/ui/app_text_cluster.dart';
import '../../../widgets/ui/app_value_cluster.dart';

class AdminDataListTile extends StatelessWidget {
  const AdminDataListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.primaryValue,
    this.secondaryValue,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final String? primaryValue;
  final String? secondaryValue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        final titleBlock = _AdminDataListTileTitle(
          title: title,
          subtitle: subtitle,
        );
        final valueBlock = _AdminDataListTileValues(
          primaryValue: primaryValue,
          secondaryValue: secondaryValue,
          alignEnd: !isCompact,
        );

        final content =
            isCompact
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleBlock,
                    if (primaryValue != null || secondaryValue != null) ...[
                      const SizedBox(height: 8),
                      valueBlock,
                    ],
                  ],
                )
                : Row(
                  children: [
                    Expanded(child: titleBlock),
                    if (primaryValue != null || secondaryValue != null) ...[
                      const SizedBox(width: 16),
                      valueBlock,
                    ],
                  ],
                );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leadingIcon != null) ...[
              _AdminDataListTileIcon(icon: leadingIcon!),
              const SizedBox(width: 12),
            ],
            Expanded(child: content),
          ],
        );
      },
    );
  }
}

class _AdminDataListTileIcon extends StatelessWidget {
  const _AdminDataListTileIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppIconBadge(
      icon: icon,
      size: 40,
      iconSize: 20,
      backgroundColor: colorScheme.secondaryContainer,
      foregroundColor: colorScheme.onSecondaryContainer,
    );
  }
}

class _AdminDataListTileTitle extends StatelessWidget {
  const _AdminDataListTileTitle({required this.title, required this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppTextCluster(
      title: title,
      subtitle: subtitle,
      titleMaxLines: 1,
      subtitleMaxLines: 1,
      titleOverflow: TextOverflow.ellipsis,
      subtitleOverflow: TextOverflow.ellipsis,
      titleGap: 3,
      titleStyle: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      subtitleStyle: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }
}

class _AdminDataListTileValues extends StatelessWidget {
  const _AdminDataListTileValues({
    required this.primaryValue,
    required this.secondaryValue,
    required this.alignEnd,
  });

  final String? primaryValue;
  final String? secondaryValue;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return AppValueCluster(
      value: primaryValue,
      detail: secondaryValue,
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      valueStyle: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}
