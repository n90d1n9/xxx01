import 'package:flutter/material.dart';

import '../../logic/survey_evidence_sync_activity_summary.dart';
import '../../models/survey_role.dart';
import 'survey_evidence_sync_activity_strip.dart';
import 'survey_role_selector.dart';

/// Renders the dashboard title, role switcher, and sync activity action.
class SurveyDashboardHeader extends StatelessWidget {
  final SurveyRole role;
  final SurveyWorkspaceSection selectedSection;
  final bool isWide;
  final SurveyEvidenceSyncActivitySummary syncActivitySummary;
  final ValueChanged<SurveyRole> onRoleChanged;
  final List<SurveyRole> availableRoles;
  final VoidCallback? onOpenEvidenceSyncActivity;

  const SurveyDashboardHeader({
    super.key,
    required this.role,
    required this.selectedSection,
    required this.isWide,
    required this.syncActivitySummary,
    required this.onRoleChanged,
    this.availableRoles = SurveyRole.values,
    this.onOpenEvidenceSyncActivity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: isWide ? 520 : double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedSection.label,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${role.label} workspace',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SurveyRoleSelector(
              selectedRole: role,
              roles: availableRoles,
              onChanged: onRoleChanged,
            ),
          ],
        ),
        if (syncActivitySummary.hasActivity) ...[
          const SizedBox(height: 16),
          SurveyEvidenceSyncActivityStrip(
            summary: syncActivitySummary,
            onPressed: onOpenEvidenceSyncActivity,
          ),
        ],
      ],
    );
  }
}
