import 'package:flutter/material.dart';

import '../../../widgets/ui/app_icon_badge.dart';
import '../../../widgets/ui/app_surface.dart';
import '../../../widgets/ui/app_text_cluster.dart';
import 'admin_breadcrumbs.dart';

class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.leadingIcon,
    this.breadcrumbs = const [],
    this.actions = const [],
    this.toolbar,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final IconData? leadingIcon;
  final List<String> breadcrumbs;
  final List<Widget> actions;
  final Widget? toolbar;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurface(
      elevated: true,
      backgroundColor: colorScheme.surfaceContainerLowest,
      padding: EdgeInsets.all(compact ? 18 : 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;
          final titleBlock = _AdminPageTitleBlock(
            title: title,
            subtitle: subtitle,
            eyebrow: eyebrow,
            leadingIcon: leadingIcon,
          );
          final actionCluster = _AdminPageActionCluster(actions: actions);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (breadcrumbs.isNotEmpty) ...[
                AdminBreadcrumbs(items: breadcrumbs),
                const SizedBox(height: 14),
              ],
              if (isCompact) ...[
                titleBlock,
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  actionCluster,
                ],
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: titleBlock),
                    if (actions.isNotEmpty) ...[
                      const SizedBox(width: 18),
                      Flexible(child: actionCluster),
                    ],
                  ],
                ),
              if (toolbar != null) ...[
                const SizedBox(height: 18),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                const SizedBox(height: 16),
                toolbar!,
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AdminPageTitleBlock extends StatelessWidget {
  const _AdminPageTitleBlock({
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
            size: 46,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: AppTextCluster(
            eyebrow: eyebrow,
            title: title,
            subtitle: subtitle,
            eyebrowGap: 5,
            titleGap: 7,
            subtitleMaxWidth: 720,
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

class _AdminPageActionCluster extends StatelessWidget {
  const _AdminPageActionCluster({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: actions,
    );
  }
}
