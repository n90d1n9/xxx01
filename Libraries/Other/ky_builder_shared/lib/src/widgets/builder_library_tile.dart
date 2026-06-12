import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Renders a selectable builder library row for components, presets, or layers.
class KyBuilderLibraryTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;
  final bool dragging;
  final bool dense;
  final double minLeadingWidth;

  const KyBuilderLibraryTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.dragging = false,
    this.dense = false,
    this.minLeadingWidth = 40,
  });

  @Preview(name: 'Builder library tile')
  const KyBuilderLibraryTile.preview({super.key})
    : title = const Text('Hero Section'),
      subtitle = const Text('Primary page introduction'),
      leading = const Icon(Icons.view_agenda_outlined),
      trailing = const Icon(Icons.chevron_right),
      onTap = null,
      selected = true,
      dragging = false,
      dense = false,
      minLeadingWidth = 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: dragging ? 0 : (selected ? 2 : 1),
      color: selected ? colorScheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      child: ListTile(
        dense: dense,
        minLeadingWidth: minLeadingWidth,
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
