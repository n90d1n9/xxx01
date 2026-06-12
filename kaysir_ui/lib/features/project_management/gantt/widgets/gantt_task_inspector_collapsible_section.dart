import 'package:flutter/material.dart';

import 'gantt_task_inspector_section_config.dart';

class GanttTaskInspectorCollapsibleSection extends StatefulWidget {
  const GanttTaskInspectorCollapsibleSection({
    required this.section,
    required this.child,
    this.initiallyCollapsed = false,
    super.key,
  });

  static Key toggleButtonKey(GanttTaskInspectorSection section) {
    return ValueKey('gantt-task-inspector-${section.name}-toggle');
  }

  final GanttTaskInspectorSection section;
  final Widget child;
  final bool initiallyCollapsed;

  @override
  State<GanttTaskInspectorCollapsibleSection> createState() =>
      _GanttTaskInspectorCollapsibleSectionState();
}

class _GanttTaskInspectorCollapsibleSectionState
    extends State<GanttTaskInspectorCollapsibleSection> {
  late var _isExpanded = !widget.initiallyCollapsed;

  @override
  void didUpdateWidget(GanttTaskInspectorCollapsibleSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section != widget.section ||
        oldWidget.initiallyCollapsed != widget.initiallyCollapsed) {
      _isExpanded = !widget.initiallyCollapsed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final section = widget.section;
    final radius = BorderRadius.circular(8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: GanttTaskInspectorCollapsibleSection.toggleButtonKey(section),
            onTap: _toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
              child: Row(
                children: [
                  Icon(section.icon, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          section.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          section.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child:
              _isExpanded
                  ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: widget.child,
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
}

extension GanttTaskInspectorSectionPresentation on GanttTaskInspectorSection {
  String get title {
    switch (this) {
      case GanttTaskInspectorSection.summary:
        return 'Task Summary';
      case GanttTaskInspectorSection.editing:
        return 'Edit Controls';
      case GanttTaskInspectorSection.readiness:
        return 'Readiness';
      case GanttTaskInspectorSection.relationships:
        return 'Relationships';
      case GanttTaskInspectorSection.actions:
        return 'Actions';
    }
  }

  String get subtitle {
    switch (this) {
      case GanttTaskInspectorSection.summary:
        return 'Status, schedule, and project context';
      case GanttTaskInspectorSection.editing:
        return 'Progress, type, dates, and recent edits';
      case GanttTaskInspectorSection.readiness:
        return 'Schedule health and predecessor readiness';
      case GanttTaskInspectorSection.relationships:
        return 'Upstream, downstream, and branch focus';
      case GanttTaskInspectorSection.actions:
        return 'Project, undo, and selection actions';
    }
  }

  IconData get icon {
    switch (this) {
      case GanttTaskInspectorSection.summary:
        return Icons.summarize_outlined;
      case GanttTaskInspectorSection.editing:
        return Icons.tune_rounded;
      case GanttTaskInspectorSection.readiness:
        return Icons.fact_check_outlined;
      case GanttTaskInspectorSection.relationships:
        return Icons.account_tree_outlined;
      case GanttTaskInspectorSection.actions:
        return Icons.task_alt_rounded;
    }
  }
}
