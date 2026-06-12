import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_report_release_archive.dart';
import '../services/financial_report_release_archive_service.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_release_signoff_shared.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportReleaseArchivePanel extends StatelessWidget {
  const FinancialReportReleaseArchivePanel({
    required this.summary,
    this.onArchive,
    this.onClear,
    super.key,
  });

  final FinancialReportReleaseArchiveSummary summary;
  final VoidCallback? onArchive;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _statusColor(summary.status, colorScheme);
    final record = summary.record;

    return FinancialReportReleaseSignOffSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final title = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FinancialReportReleaseSignOffIcon(
                    icon: Icons.archive_rounded,
                    color: color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Release Archive Register',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          summary.nextAction,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  FinancialReportReleaseSignOffBadge(
                    label: summary.status.label,
                    color: color,
                  ),
                  if (record == null)
                    FilledButton.icon(
                      onPressed: summary.canArchive ? onArchive : null,
                      icon: const Icon(Icons.archive_rounded, size: 18),
                      label: const Text('Archive pack'),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.lock_open_rounded, size: 18),
                      label: const Text('Clear archive'),
                    ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 12), actions],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 14),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FinancialReportReleaseSignOffBadge(
                label:
                    '${summary.readyEvidenceCount}/${summary.evidenceItemCount} evidence ready',
                color:
                    summary.evidenceReady
                        ? Colors.teal.shade700
                        : colorScheme.error,
              ),
              FinancialReportReleaseSignOffBadge(
                label:
                    '${FinancialReportReleaseArchiveService.defaultRetentionYears} year retention',
                color: colorScheme.primary,
              ),
              if (record != null)
                FinancialReportReleaseSignOffBadge(
                  label: record.shortFingerprint,
                  color: colorScheme.secondary,
                ),
            ],
          ),
          if (record != null) ...[
            const SizedBox(height: 12),
            _ArchiveRecordGrid(record: record),
          ],
        ],
      ),
    );
  }
}

class FinancialReportReleaseArchiveDialog extends StatefulWidget {
  const FinancialReportReleaseArchiveDialog({
    this.initialArchivedBy = 'Current user',
    this.initialCustodian =
        FinancialReportReleaseArchiveService.defaultCustodian,
    this.initialStorageLocation =
        FinancialReportReleaseArchiveService.defaultStorageLocation,
    super.key,
  });

  final String initialArchivedBy;
  final String initialCustodian;
  final String initialStorageLocation;

  @override
  State<FinancialReportReleaseArchiveDialog> createState() =>
      _FinancialReportReleaseArchiveDialogState();
}

class FinancialReportReleaseArchiveInput {
  final String archivedBy;
  final String custodian;
  final String storageLocation;
  final String note;

  const FinancialReportReleaseArchiveInput({
    required this.archivedBy,
    required this.custodian,
    required this.storageLocation,
    required this.note,
  });
}

class _FinancialReportReleaseArchiveDialogState
    extends State<FinancialReportReleaseArchiveDialog> {
  late final TextEditingController _archivedByController;
  late final TextEditingController _custodianController;
  late final TextEditingController _storageLocationController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _archivedByController = TextEditingController(
      text: widget.initialArchivedBy,
    );
    _custodianController = TextEditingController(text: widget.initialCustodian);
    _storageLocationController = TextEditingController(
      text: widget.initialStorageLocation,
    );
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _archivedByController.dispose();
    _custodianController.dispose();
    _storageLocationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Archive release pack'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _archivedByController,
              decoration: const InputDecoration(
                labelText: 'Archived by',
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _custodianController,
              decoration: const InputDecoration(
                labelText: 'Custodian',
                prefixIcon: Icon(Icons.admin_panel_settings_rounded),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _storageLocationController,
              decoration: const InputDecoration(
                labelText: 'Storage location',
                prefixIcon: Icon(Icons.folder_rounded),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop(
              FinancialReportReleaseArchiveInput(
                archivedBy: _archivedByController.text,
                custodian: _custodianController.text,
                storageLocation: _storageLocationController.text,
                note: _noteController.text,
              ),
            );
          },
          icon: const Icon(Icons.archive_rounded, size: 18),
          label: const Text('Archive'),
        ),
      ],
    );
  }
}

class _ArchiveRecordGrid extends StatelessWidget {
  const _ArchiveRecordGrid({required this.record});

  final FinancialReportReleaseArchiveRecord record;

  @override
  Widget build(BuildContext context) {
    final facts = [
      _ArchiveFactData(
        icon: Icons.tag_rounded,
        label: 'Archive ID',
        value: record.archiveId,
      ),
      _ArchiveFactData(
        icon: Icons.event_available_rounded,
        label: 'Archived',
        value: '${_dateTime(record.archivedAt)} by ${record.archivedBy}',
      ),
      _ArchiveFactData(
        icon: Icons.admin_panel_settings_rounded,
        label: 'Custodian',
        value: record.custodian,
      ),
      _ArchiveFactData(
        icon: Icons.folder_rounded,
        label: 'Location',
        value: record.storageLocation,
      ),
      _ArchiveFactData(
        icon: Icons.policy_rounded,
        label: 'Retention',
        value:
            '${record.retentionPolicy}; retain until ${_date(record.retainUntil)}',
      ),
      _ArchiveFactData(
        icon: Icons.inventory_2_rounded,
        label: 'Package',
        value:
            '${record.evidenceItemCount} item(s) / ${record.packageFingerprintAlgorithm} ${record.shortFingerprint}',
      ),
    ];

    return FinancialReportResponsiveWrapGrid<_ArchiveFactData>(
      items: facts,
      spacing: 8,
      breakpoints: const [
        FinancialReportResponsiveGridBreakpoint(minWidth: 680, columns: 2),
      ],
      itemBuilder: (_, fact) => _ArchiveFact(fact: fact),
    );
  }
}

class _ArchiveFactData {
  const _ArchiveFactData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _ArchiveFact extends StatelessWidget {
  const _ArchiveFact({required this.fact});

  final _ArchiveFactData fact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return FinancialReportTintedSurface(
      color: colorScheme.primary,
      minHeight: 76,
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.48,
      ),
      borderAlpha: 0.18,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(fact.icon, color: colorScheme.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fact.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  fact.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(
  FinancialReportReleaseArchiveStatus status,
  ColorScheme colorScheme,
) {
  switch (status) {
    case FinancialReportReleaseArchiveStatus.blocked:
      return colorScheme.error;
    case FinancialReportReleaseArchiveStatus.ready:
      return colorScheme.tertiary;
    case FinancialReportReleaseArchiveStatus.archived:
      return Colors.teal.shade700;
  }
}

String _date(DateTime value) {
  return DateFormat('MMM d, yyyy').format(value);
}

String _dateTime(DateTime value) {
  return DateFormat('MMM d, yyyy HH:mm').format(value);
}
