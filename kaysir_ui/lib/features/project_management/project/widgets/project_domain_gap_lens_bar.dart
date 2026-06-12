import 'package:flutter/material.dart';

import '../services/project_domain_gap_focus_service.dart';
import '../services/project_domain_gap_summary_service.dart';

class ProjectDomainGapLensBar extends StatelessWidget {
  const ProjectDomainGapLensBar({
    required this.summary,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final ProjectDomainGapSummary summary;
  final ProjectDomainGapFocus value;
  final ValueChanged<ProjectDomainGapFocus> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!summary.hasGaps) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _GapFocusChip(
          key: const ValueKey('project-table-brief-all-gap-focus'),
          label: 'All Fields',
          icon: ProjectDomainGapFocus.all.icon,
          color: Theme.of(context).colorScheme.secondary,
          selected: value == ProjectDomainGapFocus.all,
          onSelected: () => onChanged(ProjectDomainGapFocus.all),
        ),
        _GapFocusChip(
          key: const ValueKey('project-table-brief-any-gap-focus'),
          label: 'Any Gaps (${summary.missingFieldCount})',
          icon: ProjectDomainGapFocus.missingAny.icon,
          color: Theme.of(context).colorScheme.secondary,
          selected: value == ProjectDomainGapFocus.missingAny,
          onSelected: () => onChanged(ProjectDomainGapFocus.missingAny),
        ),
        if (summary.missingRequiredCount > 0)
          _GapFocusChip(
            key: const ValueKey('project-table-brief-required-gap-focus'),
            label: 'Required (${summary.missingRequiredCount})',
            icon: ProjectDomainGapFocus.missingRequired.icon,
            color: Theme.of(context).colorScheme.error,
            selected: value == ProjectDomainGapFocus.missingRequired,
            onSelected: () => onChanged(ProjectDomainGapFocus.missingRequired),
          ),
        if (summary.missingRecommendedCount > 0)
          _GapFocusChip(
            key: const ValueKey('project-table-brief-recommended-gap-focus'),
            label: 'Recommended (${summary.missingRecommendedCount})',
            icon: ProjectDomainGapFocus.missingRecommended.icon,
            color: Theme.of(context).colorScheme.primary,
            selected: value == ProjectDomainGapFocus.missingRecommended,
            onSelected:
                () => onChanged(ProjectDomainGapFocus.missingRecommended),
          ),
        if (summary.missingRiskSignalCount > 0)
          _GapFocusChip(
            key: const ValueKey('project-table-brief-risk-gap-focus'),
            label: 'Risk (${summary.missingRiskSignalCount})',
            icon: ProjectDomainGapFocus.missingRiskSignals.icon,
            color: Theme.of(context).colorScheme.tertiary,
            selected: value == ProjectDomainGapFocus.missingRiskSignals,
            onSelected:
                () => onChanged(ProjectDomainGapFocus.missingRiskSignals),
          ),
      ],
    );
  }
}

class _GapFocusChip extends StatelessWidget {
  const _GapFocusChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? colorScheme.onPrimary : color,
      ),
      label: Text(label, overflow: TextOverflow.ellipsis),
      selected: selected,
      selectedColor: color,
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: selected ? 1 : 0.35)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: selected ? colorScheme.onPrimary : color,
        fontWeight: FontWeight.w900,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}
