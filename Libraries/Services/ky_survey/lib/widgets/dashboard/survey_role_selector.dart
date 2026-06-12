import 'package:flutter/material.dart';

import '../../models/survey_role.dart';

/// Renders the available survey workspace roles as a compact selector.
class SurveyRoleSelector extends StatelessWidget {
  final SurveyRole selectedRole;
  final ValueChanged<SurveyRole> onChanged;
  final List<SurveyRole> roles;
  final String semanticsLabel;

  const SurveyRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
    this.roles = SurveyRole.values,
    this.semanticsLabel = 'Survey workspace role',
  });

  @override
  Widget build(BuildContext context) {
    final roles = _effectiveRoles;
    if (roles.length == 1) {
      return _SurveySingleRoleIndicator(
        role: roles.single,
        semanticsLabel: semanticsLabel,
      );
    }

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<SurveyRole>(
          showSelectedIcon: false,
          segments: [
            for (final role in roles)
              ButtonSegment<SurveyRole>(
                value: role,
                label: Text(role.label),
                icon: Icon(_surveyRoleIcon(role), size: 18),
                tooltip: 'Switch to ${role.workspaceTitle}',
              ),
          ],
          selected: {selectedRole},
          onSelectionChanged: (value) {
            if (value.isEmpty) {
              return;
            }

            onChanged(value.first);
          },
        ),
      ),
    );
  }

  List<SurveyRole> get _effectiveRoles {
    final effectiveRoles = <SurveyRole>[];
    for (final role in roles) {
      if (!effectiveRoles.contains(role)) {
        effectiveRoles.add(role);
      }
    }

    if (!effectiveRoles.contains(selectedRole)) {
      effectiveRoles.insert(0, selectedRole);
    }

    return effectiveRoles;
  }
}

/// Displays a non-interactive role state when role switching is unavailable.
class _SurveySingleRoleIndicator extends StatelessWidget {
  final SurveyRole role;
  final String semanticsLabel;

  const _SurveySingleRoleIndicator({
    required this.role,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.primary;

    return Tooltip(
      message: 'Only ${role.workspaceTitle} is available',
      child: Semantics(
        container: true,
        label: '$semanticsLabel: ${role.label}',
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_surveyRoleIcon(role), size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  role.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _surveyRoleIcon(SurveyRole role) {
  switch (role) {
    case SurveyRole.admin:
      return Icons.admin_panel_settings_outlined;
    case SurveyRole.interviewer:
      return Icons.assignment_ind_outlined;
    case SurveyRole.participant:
      return Icons.person_outline;
    case SurveyRole.analyst:
      return Icons.query_stats_outlined;
    case SurveyRole.reportViewer:
      return Icons.summarize_outlined;
  }
}
