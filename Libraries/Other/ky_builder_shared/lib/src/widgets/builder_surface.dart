import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Provides the framed surface used by builder sidebars, panels, and toolbars.
class KyBuilderSurface extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final bool scrollable;

  const KyBuilderSurface({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.padding = const EdgeInsets.all(16),
    this.width,
    this.height,
    this.scrollable = false,
  });

  @Preview(name: 'Builder surface')
  const KyBuilderSurface.preview({super.key})
    : child = const Text('Reusable builder content'),
      title = 'Components',
      subtitle = '12 available',
      leading = const Icon(Icons.widgets_outlined),
      actions = const [],
      padding = const EdgeInsets.all(16),
      width = 320,
      height = null,
      scrollable = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final header =
        title == null && subtitle == null && leading == null
            ? null
            : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 10)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (actions.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Wrap(spacing: 4, children: actions),
                ],
              ],
            );

    Widget content = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) ...[header, const SizedBox(height: 14)],
          scrollable ? Expanded(child: child) : child,
        ],
      ),
    );

    if (scrollable) {
      content = SizedBox.expand(child: content);
    }

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: content,
      ),
    );
  }
}
