import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../services/gantt_chart_expanded_control_section_presentation_service.dart';

/// Vertical section list for expanded full-screen Gantt controls.
class GanttChartExpandedControlSectionList extends StatelessWidget {
  const GanttChartExpandedControlSectionList({
    required this.sections,
    this.spacing = 14,
    super.key,
  });

  final List<Widget> sections;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < sections.length; index += 1) ...[
          sections[index],
          if (index != sections.length - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}

/// Named grouping for related expanded Gantt control strips.
class GanttChartExpandedControlSection extends StatelessWidget {
  const GanttChartExpandedControlSection({
    required this.role,
    required this.children,
    this.spacing = 10,
    super.key,
  });

  final GanttChartExpandedControlSectionRole role;
  final List<Widget> children;
  final double spacing;

  static Key sectionKey(GanttChartExpandedControlSectionRole role) {
    return ValueKey('gantt-expanded-control-section-${role.name}');
  }

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final presentation = ganttChartExpandedControlSectionPresentation(role);

    return Semantics(
      container: true,
      label: '${presentation.label}. ${presentation.subtitle}.',
      child: Column(
        key: sectionKey(role),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(presentation: presentation),
          SizedBox(height: spacing),
          for (var index = 0; index < children.length; index += 1) ...[
            children[index],
            if (index != children.length - 1) SizedBox(height: spacing),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.presentation});

  final GanttChartExpandedControlSectionPresentation presentation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(
              presentation.icon,
              size: 16,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                presentation.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                presentation.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Gantt expanded control section')
Widget ganttChartExpandedControlSectionPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: GanttChartExpandedControlSection(
          role: GanttChartExpandedControlSectionRole.display,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFFE8DEF8)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Control strip placeholder'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
