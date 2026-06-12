import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../data/employee_management_seed_data.dart';
import '../../models/employee_directory_models.dart';
import '../../models/employee_document_lifecycle_audit_filter_models.dart';
import '../../models/employee_document_lifecycle_audit_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_document_lifecycle_audit_export_receipt_provider.dart';
import '../../states/employee_document_lifecycle_audit_provider.dart';
import 'employee_document_lifecycle_audit_export_preview_panel.dart';
import 'employee_document_lifecycle_audit_export_receipt_history.dart';

/// Timeline panel for request, vault, and fulfillment document lifecycle events.
class EmployeeDocumentLifecycleAuditPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeDocumentLifecycleAuditPanel({
    super.key,
    required this.snapshot,
  });

  @override
  ConsumerState<EmployeeDocumentLifecycleAuditPanel> createState() {
    return _EmployeeDocumentLifecycleAuditPanelState();
  }
}

/// State holder for document lifecycle audit filtering controls.
class _EmployeeDocumentLifecycleAuditPanelState
    extends ConsumerState<EmployeeDocumentLifecycleAuditPanel> {
  final _searchController = TextEditingController();
  var _selectedGroup = EmployeeDocumentLifecycleAuditFilterGroup.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(
      employeeDocumentLifecycleAuditProvider(widget.snapshot.member.id),
    );
    if (profile == null) return const SizedBox.shrink();

    final query = EmployeeDocumentLifecycleAuditFilterQuery(
      group: _selectedGroup,
      searchText: _searchController.text,
    );
    final entries = query.applyTo(profile.sortedEntries);
    final receiptProfile = ref.watch(
      employeeDocumentLifecycleAuditExportReceiptProvider(
        widget.snapshot.member.id,
      ),
    );

    return HrisSectionPanel(
      icon: Icons.manage_history_outlined,
      title: 'Document lifecycle audit trail',
      subtitle: profile.nextAction,
      children: [
        EmployeeDocumentLifecycleAuditSummaryStrip(profile: profile),
        EmployeeDocumentLifecycleAuditFilterControls(
          query: query,
          totalCount: profile.totalCount,
          filteredCount: entries.length,
          searchController: _searchController,
          onGroupChanged: (group) {
            setState(() => _selectedGroup = group);
          },
          onSearchChanged: (_) {
            setState(() {});
          },
        ),
        if (profile.entries.isNotEmpty)
          EmployeeDocumentLifecycleAuditExportPreviewPanel(
            profile: profile,
            entries: entries,
            query: query,
            generatedAt: profile.asOfDate,
            onCopied: (preview) {
              ref
                  .read(
                    employeeDocumentLifecycleAuditExportReceiptProvider(
                      widget.snapshot.member.id,
                    ).notifier,
                  )
                  .recordCopy(preview: preview);
            },
          ),
        if (profile.entries.isNotEmpty && receiptProfile != null)
          EmployeeDocumentLifecycleAuditExportReceiptHistory(
            profile: receiptProfile,
          ),
        if (profile.entries.isEmpty)
          const HrisEmptyState(
            message: 'No document lifecycle audit events yet',
          )
        else if (entries.isEmpty)
          const HrisEmptyState(
            message: 'No document lifecycle audit events match this view',
          )
        else
          ...entries.map(
            (entry) => _DocumentLifecycleAuditEntryTile(entry: entry),
          ),
      ],
    );
  }
}

/// Summary metrics for the employee document lifecycle audit stream.
class EmployeeDocumentLifecycleAuditSummaryStrip extends StatelessWidget {
  final EmployeeDocumentLifecycleAuditProfile profile;

  const EmployeeDocumentLifecycleAuditSummaryStrip({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Events', value: '${profile.totalCount}'),
        HrisMetricStripItem(
          label: 'Requests',
          value: '${profile.requestCount}',
        ),
        HrisMetricStripItem(label: 'Vault', value: '${profile.vaultCount}'),
        HrisMetricStripItem(
          label: 'Fulfilled',
          value: '${profile.fulfillmentCount}',
        ),
      ],
    );
  }
}

/// Filter and search controls for document lifecycle audit events.
class EmployeeDocumentLifecycleAuditFilterControls extends StatelessWidget {
  final EmployeeDocumentLifecycleAuditFilterQuery query;
  final int totalCount;
  final int filteredCount;
  final TextEditingController searchController;
  final ValueChanged<EmployeeDocumentLifecycleAuditFilterGroup> onGroupChanged;
  final ValueChanged<String> onSearchChanged;

  const EmployeeDocumentLifecycleAuditFilterControls({
    super.key,
    required this.query,
    required this.totalCount,
    required this.filteredCount,
    required this.searchController,
    required this.onGroupChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DocumentLifecycleAuditSearchField(
            controller: searchController,
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                EmployeeDocumentLifecycleAuditFilterGroup.values.map((group) {
                  final selected = group == query.group;
                  return ChoiceChip(
                    key: Key(
                      'employee-document-lifecycle-audit-filter-${group.name}',
                    ),
                    label: Text(group.label),
                    selected: selected,
                    onSelected: (_) => onGroupChanged(group),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    selectedColor: HrisColors.primary.withValues(alpha: 0.12),
                    side: BorderSide(
                      color: selected ? HrisColors.primary : HrisColors.border,
                    ),
                    labelStyle: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(
                      color: selected ? HrisColors.primary : HrisColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 10),
          Text(
            'Showing $filteredCount of $totalCount document lifecycle events',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee document lifecycle audit filters')
Widget employeeDocumentLifecycleAuditFilterControlsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeDocumentLifecycleAuditFilterControls(
          query: const EmployeeDocumentLifecycleAuditFilterQuery(),
          totalCount: 12,
          filteredCount: 12,
          searchController: TextEditingController(),
          onGroupChanged: (_) {},
          onSearchChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Employee document lifecycle audit trail')
Widget employeeDocumentLifecycleAuditPanelPreview() {
  final snapshot = buildEmployeeManagementSnapshot(
    member: EmployeeDirectoryMember(
      id: '4',
      name: 'David Kim',
      position: 'Product Manager',
      department: 'Product',
      avatarUrl: '',
      email: 'david.kim@company.com',
      phone: '+1 (555) 789-0123',
      joiningDate: DateTime(2023, 2, 14),
      performance: 4.3,
      location: 'Jakarta',
      manager: 'Olivia Wilson',
      status: EmployeeDirectoryStatus.watchlist,
    ),
    asOfDate: DateTime(2026, 6, 1),
  );

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: EmployeeDocumentLifecycleAuditPanel(snapshot: snapshot),
        ),
      ),
    ),
  );
}

/// Text search input for document lifecycle audit event metadata.
class _DocumentLifecycleAuditSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _DocumentLifecycleAuditSearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasSearch = controller.text.trim().isNotEmpty;

    return TextField(
      key: const Key('employee-document-lifecycle-audit-search-field'),
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon:
            hasSearch
                ? IconButton(
                  tooltip: 'Clear document lifecycle audit search',
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: const Icon(Icons.close_rounded),
                )
                : null,
        hintText: 'Search audit events',
        isDense: true,
        filled: true,
        fillColor: HrisColors.surface,
        border: _inputBorder(HrisColors.border),
        enabledBorder: _inputBorder(HrisColors.border),
        focusedBorder: _inputBorder(HrisColors.primary),
      ),
    );
  }
}

/// Compact row for one document lifecycle audit event.
class _DocumentLifecycleAuditEntryTile extends StatelessWidget {
  final EmployeeDocumentLifecycleAuditEntry entry;

  const _DocumentLifecycleAuditEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = _eventColor(entry.type);

    return HrisListSurface(
      key: ValueKey('employee-document-lifecycle-audit-${entry.id}'),
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
            child: Icon(_eventIcon(entry.type), color: color, size: 20),
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
                        entry.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: entry.typeLabel, color: color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _AuditMetaChip(
                      icon: Icons.person_outline,
                      label: entry.ownershipLabel,
                    ),
                    _AuditMetaChip(
                      icon: Icons.event_outlined,
                      label: _formatTimestamp(entry.occurredAt),
                    ),
                    _AuditMetaChip(
                      icon: Icons.tag_outlined,
                      label: entry.subjectId,
                    ),
                    if (entry.correlationId.isNotEmpty)
                      _AuditMetaChip(
                        icon: Icons.link_outlined,
                        label: entry.groupLabel,
                        color: const Color(0xFF2563EB),
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

/// Small metadata chip used by document lifecycle audit rows.
class _AuditMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _AuditMetaChip({required this.icon, required this.label, this.color});

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

Color _eventColor(EmployeeDocumentLifecycleAuditEventType type) {
  return switch (type) {
    EmployeeDocumentLifecycleAuditEventType.requestCreated ||
    EmployeeDocumentLifecycleAuditEventType.requestReviewing ||
    EmployeeDocumentLifecycleAuditEventType
        .requestIssued => const Color(0xFF2563EB),
    EmployeeDocumentLifecycleAuditEventType.requestAcknowledged ||
    EmployeeDocumentLifecycleAuditEventType.vaultVerified ||
    EmployeeDocumentLifecycleAuditEventType
        .vaultFulfilled => const Color(0xFF15803D),
    EmployeeDocumentLifecycleAuditEventType.vaultUploaded ||
    EmployeeDocumentLifecycleAuditEventType
        .vaultUploadRequested => const Color(0xFFB45309),
    EmployeeDocumentLifecycleAuditEventType.requestRejected ||
    EmployeeDocumentLifecycleAuditEventType
        .vaultRejected => const Color(0xFFB91C1C),
    EmployeeDocumentLifecycleAuditEventType.vaultArchived => const Color(
      0xFF64748B,
    ),
  };
}

IconData _eventIcon(EmployeeDocumentLifecycleAuditEventType type) {
  return switch (type) {
    EmployeeDocumentLifecycleAuditEventType.requestCreated =>
      Icons.note_add_outlined,
    EmployeeDocumentLifecycleAuditEventType.requestReviewing =>
      Icons.rate_review_outlined,
    EmployeeDocumentLifecycleAuditEventType.requestIssued =>
      Icons.upload_file_outlined,
    EmployeeDocumentLifecycleAuditEventType.requestAcknowledged =>
      Icons.task_alt_outlined,
    EmployeeDocumentLifecycleAuditEventType.requestRejected =>
      Icons.cancel_outlined,
    EmployeeDocumentLifecycleAuditEventType.vaultUploaded =>
      Icons.folder_copy_outlined,
    EmployeeDocumentLifecycleAuditEventType.vaultUploadRequested =>
      Icons.pending_actions_outlined,
    EmployeeDocumentLifecycleAuditEventType.vaultVerified =>
      Icons.verified_outlined,
    EmployeeDocumentLifecycleAuditEventType.vaultRejected =>
      Icons.close_outlined,
    EmployeeDocumentLifecycleAuditEventType.vaultArchived =>
      Icons.archive_outlined,
    EmployeeDocumentLifecycleAuditEventType.vaultFulfilled =>
      Icons.fact_check_outlined,
  };
}

OutlineInputBorder _inputBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );
}

String _formatTimestamp(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
