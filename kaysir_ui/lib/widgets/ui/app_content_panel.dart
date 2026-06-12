import 'package:flutter/material.dart';

import 'app_surface.dart';

class AppContentPanel extends StatelessWidget {
  const AppContentPanel({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.leadingIcon,
    this.padding = const EdgeInsets.all(16),
    this.gap = 16,
    this.elevated = true,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? leadingIcon;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double gap;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      elevated: elevated,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _PanelHeader(
            title: title,
            subtitle: subtitle,
            trailing: trailing,
            leadingIcon: leadingIcon,
          ),
          SizedBox(height: gap),
          child,
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.leadingIcon,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleBlock = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    if (trailing == null) {
      return titleBlock;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              titleBlock,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: trailing!),
            ],
          );
        }

        const minimumTitleWidth = 96.0;
        final trailingMaxWidth = constraints.maxWidth - minimumTitleWidth - 16;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 16),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: trailingMaxWidth),
              child: trailing!,
            ),
          ],
        );
      },
    );
  }
}
