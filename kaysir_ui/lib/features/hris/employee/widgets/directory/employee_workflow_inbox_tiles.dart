import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_next_action_models.dart';
import '../../models/employee_workflow_inbox_models.dart';
import 'employee_next_action_styles.dart';

/// Summary metrics for an employee HR workflow inbox.
class EmployeeWorkflowInboxSummaryStrip extends StatelessWidget {
  final EmployeeWorkflowInboxProfile profile;

  const EmployeeWorkflowInboxSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Inbox', value: '${profile.totalCount}'),
        HrisMetricStripItem(label: 'Ready', value: '${profile.readyCount}'),
        HrisMetricStripItem(label: 'Overdue', value: '${profile.overdueCount}'),
        HrisMetricStripItem(label: 'Payroll', value: '${profile.payrollCount}'),
      ],
    );
  }
}

/// Horizontal segmented filter for employee HR workflow inbox views.
class EmployeeWorkflowInboxFilterStrip extends StatelessWidget {
  final EmployeeWorkflowInboxProfile profile;
  final EmployeeWorkflowInboxFilter selected;
  final ValueChanged<EmployeeWorkflowInboxFilter> onChanged;

  const EmployeeWorkflowInboxFilterStrip({
    super.key,
    required this.profile,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<EmployeeWorkflowInboxFilter>(
        showSelectedIcon: false,
        segments:
            EmployeeWorkflowInboxFilter.values.map((filter) {
              return ButtonSegment(
                value: filter,
                icon: Icon(_filterIcon(filter), size: 18),
                label: Text(
                  '${filter.label} (${profile.countFor(filter)})',
                  key: ValueKey(
                    'employee-workflow-inbox-filter-${filter.name}',
                  ),
                ),
              );
            }).toList(),
        selected: {selected},
        onSelectionChanged: (selection) => onChanged(selection.single),
      ),
    );
  }
}

/// Owner workload selector for employee HR workflow inbox triage.
class EmployeeWorkflowInboxOwnerLoadStrip extends StatelessWidget {
  final EmployeeWorkflowInboxProfile profile;
  final String? selectedOwner;
  final ValueChanged<String?> onChanged;

  const EmployeeWorkflowInboxOwnerLoadStrip({
    super.key,
    required this.profile,
    required this.selectedOwner,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loads = profile.ownerLoads;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            key: const ValueKey('employee-workflow-inbox-owner-all'),
            label: Text('All owners (${profile.totalCount})'),
            selected: selectedOwner == null,
            avatar: const Icon(Icons.groups_outlined, size: 18),
            onSelected: (_) => onChanged(null),
          ),
          for (final load in loads) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              key: ValueKey(
                'employee-workflow-inbox-owner-${_ownerKey(load.owner)}',
              ),
              label: Text('${load.owner} - ${load.loadLabel}'),
              selected: selectedOwner == load.owner,
              avatar: Icon(
                load.needsTriage ? Icons.bolt_outlined : Icons.person_outline,
                size: 18,
              ),
              onSelected: (_) => onChanged(load.owner),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact card for one normalized employee HR workflow inbox item.
class EmployeeWorkflowInboxItemTile extends StatelessWidget {
  final EmployeeWorkflowInboxItem item;
  final DateTime asOfDate;
  final VoidCallback? onPrimaryAction;

  const EmployeeWorkflowInboxItemTile({
    super.key,
    required this.item,
    required this.asOfDate,
    this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = employeeNextActionPriorityColor(item.priority);
    final readyColor =
        item.isReady ? const Color(0xFF15803D) : const Color(0xFFB45309);
    final overdue = item.isOverdue(asOfDate);

    return Container(
      key: ValueKey('employee-workflow-inbox-item-${item.id}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HrisColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeNextActionAreaIcon(item.area),
                  color: priorityColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: item.statusLabel, color: readyColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              HrisStatusPill(label: item.priority.label, color: priorityColor),
              _InboxMetaChip(icon: Icons.hub_outlined, label: item.sourceLabel),
              _InboxMetaChip(
                icon: Icons.person_outline,
                label: item.owner,
                color: HrisColors.ink,
              ),
              _InboxMetaChip(
                icon: Icons.category_outlined,
                label: item.area.label,
              ),
              _InboxMetaChip(
                icon: Icons.event_outlined,
                label: 'Due ${_formatDate(item.dueDate)}',
                color: overdue ? const Color(0xFFB91C1C) : HrisColors.muted,
              ),
              if (item.isReady)
                const _InboxMetaChip(
                  icon: Icons.bolt_outlined,
                  label: 'Ready',
                  color: Color(0xFF15803D),
                ),
            ],
          ),
          if (item.hasPrimaryAction) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                key: ValueKey(
                  'employee-workflow-inbox-primary-action-${item.id}',
                ),
                onPressed: onPrimaryAction,
                icon: Icon(_actionIcon(item.primaryAction), size: 18),
                label: Text(item.primaryActionLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Employee workflow inbox item')
Widget employeeWorkflowInboxItemTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeWorkflowInboxItemTile(
          asOfDate: DateTime(2026, 6, 1),
          item: EmployeeWorkflowInboxItem(
            id: 'profile-change-EPC-4-001',
            sourceRecordId: 'EPC-4-001',
            employeeId: '4',
            employeeName: 'David Kim',
            title: 'Manager change',
            detail: 'Manager: Olivia Wilson -> Emma Rodriguez',
            owner: 'People Operations',
            source: EmployeeWorkflowInboxSource.profileChange,
            area: EmployeeNextActionArea.work,
            priority: EmployeeNextActionPriority.high,
            statusLabel: 'Scheduled',
            dueDate: DateTime(2026, 6, 1),
            isReady: true,
            primaryAction: EmployeeWorkflowInboxAction.apply,
          ),
        ),
      ),
    ),
  );
}

@Preview(name: 'Employee workflow inbox filters')
Widget employeeWorkflowInboxFilterStripPreview() {
  final profile = EmployeeWorkflowInboxProfile(
    employeeId: '4',
    employeeName: 'David Kim',
    asOfDate: DateTime(2026, 6, 1),
    items: [
      EmployeeWorkflowInboxItem(
        id: 'profile-change-EPC-4-001',
        sourceRecordId: 'EPC-4-001',
        employeeId: '4',
        employeeName: 'David Kim',
        title: 'Manager change',
        detail: 'Manager: Olivia Wilson -> Emma Rodriguez',
        owner: 'People Operations',
        source: EmployeeWorkflowInboxSource.profileChange,
        area: EmployeeNextActionArea.work,
        priority: EmployeeNextActionPriority.high,
        statusLabel: 'Scheduled',
        dueDate: DateTime(2026, 6, 1),
        isReady: true,
        primaryAction: EmployeeWorkflowInboxAction.apply,
      ),
    ],
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeWorkflowInboxFilterStrip(
          profile: profile,
          selected: EmployeeWorkflowInboxFilter.ready,
          onChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Employee workflow inbox owner loads')
Widget employeeWorkflowInboxOwnerLoadStripPreview() {
  final profile = EmployeeWorkflowInboxProfile(
    employeeId: '4',
    employeeName: 'David Kim',
    asOfDate: DateTime(2026, 6, 1),
    items: [
      EmployeeWorkflowInboxItem(
        id: 'profile-change-EPC-4-001',
        sourceRecordId: 'EPC-4-001',
        employeeId: '4',
        employeeName: 'David Kim',
        title: 'Manager change',
        detail: 'Manager: Olivia Wilson -> Emma Rodriguez',
        owner: 'People Operations',
        source: EmployeeWorkflowInboxSource.profileChange,
        area: EmployeeNextActionArea.work,
        priority: EmployeeNextActionPriority.high,
        statusLabel: 'Scheduled',
        dueDate: DateTime(2026, 6, 1),
        isReady: true,
        primaryAction: EmployeeWorkflowInboxAction.apply,
      ),
      EmployeeWorkflowInboxItem(
        id: 'action-EAW-4-001',
        sourceRecordId: 'EAW-4-001',
        employeeId: '4',
        employeeName: 'David Kim',
        title: 'Complete manager notes',
        detail: 'Upload support plan evidence.',
        owner: 'HR Business Partner',
        source: EmployeeWorkflowInboxSource.actionWorkflow,
        area: EmployeeNextActionArea.records,
        priority: EmployeeNextActionPriority.medium,
        statusLabel: 'Open',
        dueDate: DateTime(2026, 6, 5),
        isReady: true,
        primaryAction: EmployeeWorkflowInboxAction.start,
      ),
    ],
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeWorkflowInboxOwnerLoadStrip(
          profile: profile,
          selectedOwner: 'People Operations',
          onChanged: (_) {},
        ),
      ),
    ),
  );
}

/// Compact metadata chip used by employee workflow inbox cards.
class _InboxMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InboxMetaChip({
    required this.icon,
    required this.label,
    this.color = HrisColors.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime value) {
  return DateFormat('MMM d, yyyy').format(value);
}

IconData _filterIcon(EmployeeWorkflowInboxFilter filter) {
  return switch (filter) {
    EmployeeWorkflowInboxFilter.all => Icons.inbox_outlined,
    EmployeeWorkflowInboxFilter.ready => Icons.bolt_outlined,
    EmployeeWorkflowInboxFilter.overdue => Icons.warning_amber_outlined,
    EmployeeWorkflowInboxFilter.highPriority => Icons.priority_high_outlined,
    EmployeeWorkflowInboxFilter.payroll => Icons.payments_outlined,
    EmployeeWorkflowInboxFilter.profileChange => Icons.rule_folder_outlined,
    EmployeeWorkflowInboxFilter.dataCorrection => Icons.edit_note_outlined,
    EmployeeWorkflowInboxFilter.jobAssignment => Icons.badge_outlined,
  };
}

IconData _actionIcon(EmployeeWorkflowInboxAction action) {
  return switch (action) {
    EmployeeWorkflowInboxAction.none => Icons.more_horiz,
    EmployeeWorkflowInboxAction.start => Icons.play_arrow_outlined,
    EmployeeWorkflowInboxAction.complete => Icons.check_circle_outline,
    EmployeeWorkflowInboxAction.review => Icons.rate_review_outlined,
    EmployeeWorkflowInboxAction.approve => Icons.verified_outlined,
    EmployeeWorkflowInboxAction.schedule => Icons.event_available_outlined,
    EmployeeWorkflowInboxAction.apply => Icons.publish_outlined,
    EmployeeWorkflowInboxAction.activate => Icons.bolt_outlined,
  };
}

String _ownerKey(String owner) {
  final key = owner
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp('-+'), '-')
      .replaceAll(RegExp('^-|-\$'), '');
  return key.isEmpty ? 'unknown' : key;
}
