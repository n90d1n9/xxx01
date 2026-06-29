import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_document_request_coverage_models.dart';
import '../../models/employee_document_vault_coverage_models.dart';
import '../../models/employee_document_vault_models.dart';
import 'employee_document_vault_styles.dart';

/// Required document coverage checklist for an employee document vault.
class EmployeeDocumentVaultCoveragePanel extends StatelessWidget {
  final EmployeeDocumentVaultCoverageProfile profile;
  final Set<String> openCoverageRequestIds;
  final ValueChanged<EmployeeDocumentVaultCoverageItem>? onCreateRequest;

  const EmployeeDocumentVaultCoveragePanel({
    super.key,
    required this.profile,
    this.openCoverageRequestIds = const {},
    this.onCreateRequest,
  });

  @override
  Widget build(BuildContext context) {
    final items = profile.prioritizedItems;

    return HrisListSurface(
      key: const ValueKey('employee-document-vault-coverage-panel'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Required document coverage',
                  key: const ValueKey('employee-document-vault-coverage-title'),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: profile.completionLabel,
                color: _coverageHealthColor(profile),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            profile.nextAction,
            key: const ValueKey('employee-document-vault-coverage-action'),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Covered',
                value: '${profile.completeCount}/${profile.requiredCount}',
              ),
              HrisMetricStripItem(
                label: 'Attention',
                value: '${profile.attentionCount}',
              ),
              HrisMetricStripItem(
                label: 'Missing',
                value: '${profile.missingCount}',
              ),
              HrisMetricStripItem(
                label: 'Restricted',
                value: '${profile.restrictedCount}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: profile.completionRatio,
            color: _coverageHealthColor(profile),
            label: profile.completionLabel,
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0) const Divider(height: 18),
            _EmployeeDocumentVaultCoverageItemRow(
              item: items[index],
              hasOpenRequest: openCoverageRequestIds.contains(
                EmployeeDocumentCoverageRequestFactory.correlationIdFor(
                  items[index],
                ),
              ),
              onCreateRequest: onCreateRequest,
            ),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Employee document vault coverage')
Widget employeeDocumentVaultCoveragePanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeDocumentVaultCoveragePanel(
          profile: EmployeeDocumentVaultCoverageProfile.fromVault(
            _previewVaultProfile,
          ),
        ),
      ),
    ),
  );
}

/// One requirement row in the employee document vault coverage checklist.
class _EmployeeDocumentVaultCoverageItemRow extends StatelessWidget {
  final EmployeeDocumentVaultCoverageItem item;
  final bool hasOpenRequest;
  final ValueChanged<EmployeeDocumentVaultCoverageItem>? onCreateRequest;

  const _EmployeeDocumentVaultCoverageItemRow({
    required this.item,
    required this.hasOpenRequest,
    required this.onCreateRequest,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);
    final showRequestAction = item.canCreateRequest && onCreateRequest != null;

    return Row(
      key: ValueKey('employee-document-vault-coverage-${item.requirement.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            employeeDocumentVaultCategoryIcon(item.category),
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
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  HrisStatusPill(label: item.statusLabel, color: color),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.actionLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _CoverageMetaChip(
                    icon: Icons.person_outline,
                    label: item.owner,
                  ),
                  _CoverageMetaChip(
                    icon: employeeDocumentVaultAccessIcon(item.access),
                    label: item.access.label,
                    color: employeeDocumentVaultAccessColor(item.access),
                  ),
                  _CoverageMetaChip(
                    icon: Icons.folder_copy_outlined,
                    label: item.category.label,
                  ),
                ],
              ),
              if (showRequestAction) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  key: ValueKey(
                    'employee-document-vault-coverage-request-${item.requirement.id}',
                  ),
                  onPressed:
                      hasOpenRequest ? null : () => onCreateRequest?.call(item),
                  icon: Icon(
                    hasOpenRequest
                        ? Icons.pending_actions_outlined
                        : Icons.note_add_outlined,
                  ),
                  label: Text(
                    hasOpenRequest ? 'Request open' : item.requestActionLabel,
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

/// Small metadata chip used by document vault coverage rows.
class _CoverageMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _CoverageMetaChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? HrisColors.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 5),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
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

EmployeeDocumentVaultProfile get _previewVaultProfile {
  final today = DateTime(2026, 6, 1);
  return EmployeeDocumentVaultProfile(
    employeeId: '4',
    employeeName: 'David Kim',
    asOfDate: today,
    records: [
      EmployeeDocumentVaultRecord(
        id: 'EDV-4-001',
        employeeId: '4',
        employeeName: 'David Kim',
        category: EmployeeDocumentVaultCategory.identity,
        status: EmployeeDocumentVaultStatus.verified,
        access: EmployeeDocumentVaultAccess.employeeVisible,
        title: 'Government ID',
        owner: 'People Operations',
        source: 'Personal records',
        uploadedAt: today.subtract(const Duration(days: 600)),
        expiresAt: today.add(const Duration(days: 900)),
        verifiedAt: today.subtract(const Duration(days: 590)),
        summary: 'Identity document is verified.',
      ),
      EmployeeDocumentVaultRecord(
        id: 'EDV-4-002',
        employeeId: '4',
        employeeName: 'David Kim',
        category: EmployeeDocumentVaultCategory.contract,
        status: EmployeeDocumentVaultStatus.verified,
        access: EmployeeDocumentVaultAccess.hrOnly,
        title: 'Employment agreement',
        owner: 'People Operations',
        source: 'Contract lifecycle',
        uploadedAt: today.subtract(const Duration(days: 480)),
        expiresAt: null,
        verifiedAt: today.subtract(const Duration(days: 478)),
        summary: 'Signed agreement is verified.',
      ),
      EmployeeDocumentVaultRecord(
        id: 'EDV-4-003',
        employeeId: '4',
        employeeName: 'David Kim',
        category: EmployeeDocumentVaultCategory.workAuthorization,
        status: EmployeeDocumentVaultStatus.expiringSoon,
        access: EmployeeDocumentVaultAccess.restricted,
        title: 'Work permit renewal packet',
        owner: 'People Operations',
        source: 'Work authorization',
        uploadedAt: today.subtract(const Duration(days: 330)),
        expiresAt: today.add(const Duration(days: 28)),
        verifiedAt: today.subtract(const Duration(days: 320)),
        summary: 'Renewal packet needs refreshed evidence.',
      ),
    ],
  );
}

Color _coverageHealthColor(EmployeeDocumentVaultCoverageProfile profile) {
  if (profile.attentionCount == 0) return const Color(0xFF15803D);
  if (profile.missingCount > 0) return const Color(0xFFB45309);
  return const Color(0xFF2563EB);
}

Color _statusColor(EmployeeDocumentVaultCoverageStatus status) {
  return switch (status) {
    EmployeeDocumentVaultCoverageStatus.complete => const Color(0xFF15803D),
    EmployeeDocumentVaultCoverageStatus.reviewNeeded => const Color(0xFF2563EB),
    EmployeeDocumentVaultCoverageStatus.uploadNeeded => const Color(0xFFB45309),
    EmployeeDocumentVaultCoverageStatus.expiringSoon => const Color(0xFFB45309),
    EmployeeDocumentVaultCoverageStatus.expired => const Color(0xFFB91C1C),
    EmployeeDocumentVaultCoverageStatus.missing => const Color(0xFFB45309),
  };
}
