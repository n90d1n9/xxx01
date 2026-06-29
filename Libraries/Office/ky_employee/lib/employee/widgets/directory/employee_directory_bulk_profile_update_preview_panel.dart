import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_bulk_profile_update_preview_models.dart';

class EmployeeDirectoryBulkProfileUpdatePreviewPanel extends StatelessWidget {
  final EmployeeDirectoryBulkProfileUpdatePreview preview;
  final ValueChanged<bool> onApprovalChanged;

  const EmployeeDirectoryBulkProfileUpdatePreviewPanel({
    super.key,
    required this.preview,
    required this.onApprovalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      key: const ValueKey('employee-directory-bulk-profile-preview-panel'),
      icon: Icons.rule_outlined,
      title: 'Bulk update preview',
      subtitle:
          preview.canApply
              ? '${preview.changedProfileCount} profiles approved for update'
              : 'Review row-level changes before applying updates',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Profiles',
              value: '${preview.selectedCount}',
            ),
            HrisMetricStripItem(
              label: 'Changed',
              value: '${preview.changedProfileCount}',
            ),
            HrisMetricStripItem(
              label: 'Updates',
              value: '${preview.effectiveChangeCount}',
            ),
            HrisMetricStripItem(
              label: 'Approval',
              value: preview.approvalLabel,
            ),
          ],
        ),
        if (preview.errors.isNotEmpty)
          HrisListSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  preview.errors
                      .map(
                        (error) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            error,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFB91C1C),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          )
        else
          ...preview.visibleRows.map(
            (row) => _PreviewRowTile(
              key: ValueKey(
                'employee-directory-bulk-profile-preview-row-${row.member.id}',
              ),
              row: row,
            ),
          ),
        if (preview.rows.length > preview.visibleRows.length)
          HrisListSurface(
            child: Text(
              '${preview.rows.length - preview.visibleRows.length} more changed profiles included in this preview.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        HrisListSurface(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                key: const ValueKey(
                  'employee-directory-bulk-profile-preview-approval-checkbox',
                ),
                value: preview.isApproved,
                onChanged:
                    preview.isReady
                        ? (value) =>
                            onApprovalChanged(value ?? preview.isApproved)
                        : null,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Approve preview',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preview.isReady
                          ? 'Apply updates only after this preview matches the intended HR change.'
                          : 'Complete selection, fields, and audit note before approval.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewRowTile extends StatelessWidget {
  final EmployeeDirectoryBulkProfileUpdatePreviewRow row;

  const _PreviewRowTile({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.member.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(
                label: '${row.changeCount} changes',
                color: HrisColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                row.changes
                    .map((change) => _ChangeChip(change: change))
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class _ChangeChip extends StatelessWidget {
  final EmployeeDirectoryBulkProfileUpdateChange change;

  const _ChangeChip({required this.change});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            change.fieldLabel,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: HrisColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${change.currentValue} -> ${change.nextValue}',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
