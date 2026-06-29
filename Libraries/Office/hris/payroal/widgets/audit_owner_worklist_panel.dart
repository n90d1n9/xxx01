import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

/// Shows audit close actions grouped by responsible owner.
class AuditOwnerWorklistPanel extends StatelessWidget {
  final AuditOwnerWorklistSummary summary;

  const AuditOwnerWorklistPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final color =
        summary.blockedCount > 0
            ? const Color(0xFFB91C1C)
            : const Color(0xFF2563EB);

    return HrisSectionPanel(
      icon: Icons.groups_2_outlined,
      title: 'Audit owner worklist',
      subtitle: summary.periodLabel,
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  HrisStatusPill(
                    label: summary.isClear ? 'Clear' : 'Open',
                    color: summary.isClear ? const Color(0xFF15803D) : color,
                  ),
                  _MetricChip(
                    icon: Icons.person_pin_circle_outlined,
                    label: '${summary.ownerCount} owners',
                  ),
                  _MetricChip(
                    icon: Icons.warning_amber_outlined,
                    label: '${summary.blockedCount} blocked',
                  ),
                  _MetricChip(
                    icon: Icons.playlist_add_check_outlined,
                    label: '${summary.actionCount} actions',
                  ),
                  _MetricChip(
                    icon: Icons.rate_review_outlined,
                    label: '${summary.readyReviewCount} review',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    summary.isClear
                        ? Icons.verified_outlined
                        : Icons.groups_2_outlined,
                    color: summary.isClear ? const Color(0xFF15803D) : color,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      summary.nextAction,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (summary.groups.isEmpty)
          const HrisEmptyState(message: 'No owner actions remain')
        else
          HrisListSurface(
            child: Column(
              children: [
                for (var index = 0; index < summary.groups.length; index++) ...[
                  _OwnerGroupRow(group: summary.groups[index]),
                  if (index < summary.groups.length - 1)
                    const Divider(height: 22, color: HrisColors.border),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _OwnerGroupRow extends StatelessWidget {
  final AuditOwnerWorklistGroup group;

  const _OwnerGroupRow({required this.group});

  @override
  Widget build(BuildContext context) {
    final firstItem = group.firstItem;
    final color =
        group.blockedCount > 0
            ? const Color(0xFFB91C1C)
            : group.actionCount > 0
            ? const Color(0xFF2563EB)
            : const Color(0xFF15803D);

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
          child: Icon(Icons.person_pin_circle_outlined, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      group.owner,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  HrisStatusPill(
                    label:
                        group.blockedCount > 0
                            ? '${group.blockedCount} blocked'
                            : '${group.items.length} open',
                    color: color,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _MetricChip(
                    icon: Icons.playlist_add_check_outlined,
                    label: '${group.actionCount} actions',
                  ),
                  _MetricChip(
                    icon: Icons.rate_review_outlined,
                    label: '${group.readyReviewCount} ready review',
                  ),
                  if (firstItem != null)
                    _MetricChip(
                      icon: Icons.source_outlined,
                      label: firstItem.source,
                    ),
                ],
              ),
              if (firstItem != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${firstItem.title}: ${firstItem.nextAction}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: HrisColors.primary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
