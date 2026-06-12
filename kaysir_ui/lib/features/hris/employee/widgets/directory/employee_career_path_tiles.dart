import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_career_path_models.dart';
import 'employee_career_path_styles.dart';

class EmployeeCareerPathSummaryStrip extends StatelessWidget {
  final EmployeeCareerPathProfile profile;

  const EmployeeCareerPathSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Readiness',
          value: profile.path.readiness.label,
        ),
        HrisMetricStripItem(
          label: 'Coverage',
          value: profile.path.successionCoverage.label,
        ),
        HrisMetricStripItem(
          label: 'Proposed',
          value: '${profile.proposedMoveCount}',
        ),
        HrisMetricStripItem(
          label: 'Active',
          value: '${profile.activeMoveCount}',
        ),
      ],
    );
  }
}

class EmployeeCareerPathCard extends StatelessWidget {
  final EmployeeCareerPathSnapshot path;
  final DateTime asOfDate;
  final ValueChanged<EmployeeCareerReadiness> onReadinessChanged;
  final ValueChanged<EmployeeSuccessionCoverage> onCoverageChanged;
  final VoidCallback onMarkReviewed;

  const EmployeeCareerPathCard({
    super.key,
    required this.path,
    required this.asOfDate,
    required this.onReadinessChanged,
    required this.onCoverageChanged,
    required this.onMarkReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final readinessColor = employeeCareerReadinessColor(path.readiness);
    final coverageColor = employeeSuccessionCoverageColor(
      path.successionCoverage,
    );
    final reviewDue = path.isReviewDue(asOfDate);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: Icons.account_tree_outlined,
            title: path.targetRole,
            subtitle: '${path.currentRole} - sponsor ${path.sponsor}',
            color: path.hasSuccessionGap ? coverageColor : readinessColor,
            status: HrisStatusPill(
              label: path.readiness.label,
              color: readinessColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: employeeMobilityPreferenceIcon(path.mobilityPreference),
                label: path.mobilityPreference.label,
              ),
              _MetaChip(
                icon: Icons.security_outlined,
                label: path.successionCoverage.label,
                color: coverageColor,
              ),
              _MetaChip(
                icon: Icons.event_note_outlined,
                label: 'Review ${_formatDate(path.nextReviewDate)}',
                color: reviewDue ? const Color(0xFFB91C1C) : null,
              ),
              if (path.criticalRole)
                _MetaChip(
                  icon: Icons.priority_high_outlined,
                  label: 'Critical role',
                  color:
                      path.hasSuccessionGap
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFFB45309),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Readiness',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<EmployeeCareerReadiness>(
              showSelectedIcon: false,
              segments:
                  EmployeeCareerReadiness.values
                      .map(
                        (readiness) => ButtonSegment(
                          value: readiness,
                          label: Text(readiness.label),
                        ),
                      )
                      .toList(),
              selected: {path.readiness},
              onSelectionChanged:
                  (selection) => onReadinessChanged(selection.single),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Succession coverage',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<EmployeeSuccessionCoverage>(
              showSelectedIcon: false,
              segments:
                  EmployeeSuccessionCoverage.values
                      .map(
                        (coverage) => ButtonSegment(
                          value: coverage,
                          label: Text(coverage.label),
                        ),
                      )
                      .toList(),
              selected: {path.successionCoverage},
              onSelectionChanged:
                  (selection) => onCoverageChanged(selection.single),
            ),
          ),
          if (reviewDue) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onMarkReviewed,
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Mark reviewed'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EmployeeCareerMoveRequestTile extends StatelessWidget {
  final EmployeeCareerMoveRequest move;
  final VoidCallback onApprove;
  final VoidCallback onActivate;
  final VoidCallback onComplete;
  final VoidCallback onDecline;

  const EmployeeCareerMoveRequestTile({
    super.key,
    required this.move,
    required this.onApprove,
    required this.onActivate,
    required this.onComplete,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeCareerMoveStatusColor(move.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: employeeCareerMoveTypeIcon(move.type),
            title: move.title,
            subtitle: '${move.type.label} - ${move.sponsor}',
            color: color,
            status: HrisStatusPill(label: move.status.label, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            move.summary,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.badge_outlined, label: move.targetRole),
              _MetaChip(
                icon: Icons.event_available_outlined,
                label: 'Target ${_formatDate(move.targetDate)}',
              ),
            ],
          ),
          if (move.canApprove ||
              move.canActivate ||
              move.canComplete ||
              move.canDecline) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (move.canDecline)
                  OutlinedButton.icon(
                    onPressed: onDecline,
                    icon: const Icon(Icons.close_outlined),
                    label: const Text('Decline'),
                  ),
                if (move.canApprove)
                  FilledButton.tonalIcon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Approve'),
                  ),
                if (move.canActivate)
                  FilledButton.tonalIcon(
                    onPressed: onActivate,
                    icon: const Icon(Icons.play_arrow_outlined),
                    label: const Text('Activate'),
                  ),
                if (move.canComplete)
                  FilledButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.done_all_outlined),
                    label: const Text('Complete'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TileHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget status;

  const _TileHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        status,
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? HrisColors.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}
