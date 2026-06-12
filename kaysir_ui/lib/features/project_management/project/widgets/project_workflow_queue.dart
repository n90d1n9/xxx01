import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

/// Shared empty queue row for project workflow panels.
class ProjectWorkflowEmptyQueue extends StatelessWidget {
  const ProjectWorkflowEmptyQueue({
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppInfoRow(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
    );
  }
}

/// Generic queue list that shows an empty state or compact submission rows.
class ProjectWorkflowQueue<T> extends StatelessWidget {
  const ProjectWorkflowQueue({
    required this.items,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.itemBuilder,
    this.maxItems = 3,
    super.key,
  });

  /// Builds a queue by mapping domain submissions into standard queue tiles.
  ProjectWorkflowQueue.mapped({
    required this.items,
    required this.emptyTitle,
    required this.emptySubtitle,
    required String Function(T item) titleFor,
    required String Function(T item) subtitleFor,
    required IconData Function(T item) iconFor,
    required Color Function(BuildContext context, T item) colorFor,
    Color? Function(BuildContext context, T item)? statusColorFor,
    this.maxItems = 3,
    super.key,
  }) : itemBuilder =
           ((context, item) => ProjectWorkflowQueueTile(
             title: titleFor(item),
             subtitle: subtitleFor(item),
             icon: iconFor(item),
             color: colorFor(context, item),
             statusColor: statusColorFor?.call(context, item),
           ));

  final List<T> items;
  final String emptyTitle;
  final String emptySubtitle;
  final int maxItems;
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ProjectWorkflowEmptyQueue(
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    final visibleItems = items.take(maxItems).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < visibleItems.length; index++) ...[
          itemBuilder(context, visibleItems[index]),
          if (index != visibleItems.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Compact queued item row for simple project workflow histories.
class ProjectWorkflowQueueTile extends StatelessWidget {
  const ProjectWorkflowQueueTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.statusColor,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppInfoRow(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: color.withValues(alpha: 0.12),
      iconForegroundColor: color,
      titleMaxLines: 2,
      subtitleMaxLines: 2,
      trailing: AppStatusPill(
        label: 'Queued',
        icon: Icons.playlist_add_check_outlined,
        color: statusColor ?? colorScheme.primary,
        maxWidth: 106,
      ),
    );
  }
}

@Preview(name: 'Project workflow queue')
Widget projectWorkflowQueuePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProjectWorkflowQueue<String>.mapped(
          items: const ['Budget recovery response'],
          emptyTitle: 'Workflow queue empty',
          emptySubtitle: 'Queued responses will appear here.',
          titleFor: (item) => item,
          subtitleFor: (_) => 'Executive escalation - Owner: Sponsor',
          iconFor: (_) => Icons.priority_high_rounded,
          colorFor: (context, _) => Theme.of(context).colorScheme.error,
        ),
      ),
    ),
  );
}
