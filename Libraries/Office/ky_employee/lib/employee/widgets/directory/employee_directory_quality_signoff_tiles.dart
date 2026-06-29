import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_quality_gate_models.dart';
import '../../models/employee_directory_quality_signoff_models.dart';

/// Audit tile for a completed roster quality gate sign-off.
class EmployeeDirectoryQualityGateSignoffTile extends StatelessWidget {
  final EmployeeDirectoryQualityGateSignoff signoff;

  const EmployeeDirectoryQualityGateSignoffTile({
    super.key,
    required this.signoff,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(signoff.gateStatus);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.verified_user_outlined, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Gate signed off',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: signoff.statusLabel, color: color),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  signoff.summaryLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: Icons.person_outline,
                      label: signoff.reviewer,
                    ),
                    _MetaChip(
                      icon: Icons.schedule_outlined,
                      label: _formatDate(signoff.signedAt),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  signoff.note,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee quality gate sign-off tile')
Widget employeeDirectoryQualityGateSignoffTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryQualityGateSignoffTile(
          signoff: EmployeeDirectoryQualityGateSignoff(
            id: 'gate-1',
            reviewer: 'Alya Rahman',
            note: 'Reviewed roster quality and accepted one routing item.',
            signedAt: DateTime(2026, 6, 9),
            gateStatus: EmployeeDirectoryQualityGateStatus.review,
            readinessScore: 67,
            memberCount: 3,
            acceptedReviewCount: 1,
          ),
        ),
      ),
    ),
  );
}

/// Compact metadata chip used inside sign-off audit tiles.
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: HrisColors.muted),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(EmployeeDirectoryQualityGateStatus status) {
  return switch (status) {
    EmployeeDirectoryQualityGateStatus.blocked => const Color(0xFFB91C1C),
    EmployeeDirectoryQualityGateStatus.review => const Color(0xFFD97706),
    EmployeeDirectoryQualityGateStatus.ready => const Color(0xFF15803D),
  };
}

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
