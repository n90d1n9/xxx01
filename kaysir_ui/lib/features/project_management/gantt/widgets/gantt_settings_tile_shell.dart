import 'package:flutter/material.dart';

/// Shared surface and header layout for Gantt settings controls.
class GanttSettingsTileShell extends StatelessWidget {
  const GanttSettingsTileShell({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.child,
    this.subtitle,
    this.enabled = true,
    this.contentSpacing = 8,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Widget child;
  final bool enabled;
  final double contentSpacing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: enabled ? 1 : 0.56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GanttSettingsTileHeader(
                title: title,
                subtitle: subtitle,
                icon: icon,
              ),
              SizedBox(height: contentSpacing),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon, title, and optional subtitle row for Gantt settings tiles.
class _GanttSettingsTileHeader extends StatelessWidget {
  const _GanttSettingsTileHeader({
    required this.title,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 10),
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
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (subtitle case final subtitle?)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
