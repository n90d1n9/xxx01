import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../widgets/ui/app_status_pill.dart';

/// Shared section shell for omni-channel registry diagnostics content.
class OmniChannelActivityRegistrySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget child;

  const OmniChannelActivityRegistrySection({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor ?? colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

/// Shared bounded tile for registry diagnostics metrics and warnings.
class OmniChannelActivityRegistryTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final int subtitleMaxLines;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<Widget> children;

  const OmniChannelActivityRegistryTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.subtitleMaxLines = 1,
    this.backgroundColor,
    this.borderColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 224, maxWidth: 320),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
          border: Border.all(color: borderColor ?? colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: color),
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
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: subtitleMaxLines,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: children),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(name: 'Omni-channel registry card primitives')
Widget omniChannelActivityRegistryCardPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: OmniChannelActivityRegistrySection(
          title: 'Registry section',
          icon: Icons.extension_outlined,
          child: OmniChannelActivityRegistryTile(
            icon: Icons.bolt_outlined,
            color: Colors.teal,
            title: 'Review order',
            subtitle: 'Resolved action coverage',
            children: [
              AppStatusPill(
                label: '2 events',
                color: Colors.teal,
                icon: Icons.timeline_outlined,
                maxWidth: 132,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
