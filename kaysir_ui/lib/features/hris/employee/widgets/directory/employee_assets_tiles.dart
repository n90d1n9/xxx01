import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_assets_models.dart';
import 'employee_assets_styles.dart';

class EmployeeAssetAccessSummaryStrip extends StatelessWidget {
  final EmployeeAssetAccessProfile profile;

  const EmployeeAssetAccessSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Assets',
          value: '${profile.activeAssetCount}',
        ),
        HrisMetricStripItem(
          label: 'Pending',
          value: '${profile.pendingAssetCount}',
        ),
        HrisMetricStripItem(
          label: 'Access',
          value: '${profile.activeAccessCount}',
        ),
        HrisMetricStripItem(
          label: 'Review',
          value: '${profile.accessReviewCount}',
        ),
      ],
    );
  }
}

class EmployeeAssetRecordTile extends StatelessWidget {
  final EmployeeAssetRecord asset;
  final DateTime asOfDate;
  final VoidCallback onCompleteProvisioning;
  final VoidCallback onReturn;

  const EmployeeAssetRecordTile({
    super.key,
    required this.asset,
    required this.asOfDate,
    required this.onCompleteProvisioning,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final returnDue = asset.isReturnDue(asOfDate);
    final statusColor =
        returnDue
            ? const Color(0xFFB45309)
            : employeeAssetStatusColor(asset.status);
    final conditionColor = employeeAssetConditionColor(asset.condition);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeAssetTypeIcon(asset.type),
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${asset.assetTag} - ${asset.owner}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(
                label: returnDue ? 'Return due' : asset.status.label,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.inventory_2_outlined,
                label: asset.type.label,
              ),
              _MetaChip(
                icon: Icons.health_and_safety_outlined,
                label: asset.condition.label,
                color: conditionColor,
              ),
              _MetaChip(
                icon: Icons.event_available_outlined,
                label: 'Issued ${DateFormat('MMM d').format(asset.issuedAt)}',
              ),
              if (asset.returnDueAt != null)
                _MetaChip(
                  icon: Icons.assignment_return_outlined,
                  label:
                      'Return ${DateFormat('MMM d').format(asset.returnDueAt!)}',
                  color: returnDue ? const Color(0xFFB45309) : null,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed:
                    asset.status == EmployeeAssetStatus.provisioning
                        ? onCompleteProvisioning
                        : null,
                icon: const Icon(Icons.done_outline),
                label: const Text('Activate'),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed:
                    asset.status == EmployeeAssetStatus.returned
                        ? null
                        : onReturn,
                icon: const Icon(Icons.assignment_return_outlined),
                label: const Text('Return'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeeAccessGrantTile extends StatelessWidget {
  final EmployeeAccessGrant grant;
  final DateTime asOfDate;
  final VoidCallback onApprove;
  final VoidCallback onRevoke;

  const EmployeeAccessGrantTile({
    super.key,
    required this.grant,
    required this.asOfDate,
    required this.onApprove,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final needsReview = grant.needsReview(asOfDate);
    final color =
        needsReview
            ? const Color(0xFFB45309)
            : employeeAccessStatusColor(grant.status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              employeeAccessScopeIcon(grant.scope),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        grant.systemName,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(
                      label: needsReview ? 'Review due' : grant.status.label,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: Icons.security_outlined,
                      label: grant.scope.label,
                    ),
                    _MetaChip(icon: Icons.person_outline, label: grant.owner),
                    _MetaChip(
                      icon: Icons.event_outlined,
                      label:
                          'Review ${DateFormat('MMM d').format(grant.reviewDueAt)}',
                      color: needsReview ? const Color(0xFFB45309) : null,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed:
                          grant.status == EmployeeAccessStatus.active &&
                                  !needsReview
                              ? null
                              : onApprove,
                      icon: const Icon(Icons.verified_user_outlined),
                      label: const Text('Approve'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonalIcon(
                      onPressed:
                          grant.status == EmployeeAccessStatus.revoked
                              ? null
                              : onRevoke,
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('Revoke'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
    final resolvedColor = color ?? HrisColors.muted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: resolvedColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: resolvedColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
