import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_readiness_action_checklist.dart';
import 'registry_health_readiness_action_plan.dart';

class RegistryHealthReadinessActionPlanPanel extends StatefulWidget {
  const RegistryHealthReadinessActionPlanPanel({
    super.key,
    required this.plan,
    this.actionLimit = 6,
    this.initialFilter = RegistryHealthReadinessActionFilter.all,
    this.showFilters = true,
    this.showCopyAction = true,
    this.showChecklist = true,
    this.showChecklistCopyAction = true,
  });

  final RegistryHealthReadinessActionPlan plan;
  final int actionLimit;
  final RegistryHealthReadinessActionFilter initialFilter;
  final bool showFilters;
  final bool showCopyAction;
  final bool showChecklist;
  final bool showChecklistCopyAction;

  @override
  State<RegistryHealthReadinessActionPlanPanel> createState() =>
      _RegistryHealthReadinessActionPlanPanelState();
}

class _RegistryHealthReadinessActionPlanPanelState
    extends State<RegistryHealthReadinessActionPlanPanel> {
  late RegistryHealthReadinessActionFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  void didUpdateWidget(RegistryHealthReadinessActionPlanPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFilter != widget.initialFilter) {
      _filter = widget.initialFilter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final checklist = registryHealthReadinessActionChecklist(
      widget.plan,
      filter: _filter,
    );
    final visibleGroups = checklist.visibleGroups(
      itemLimit: widget.actionLimit,
    );
    final visibleActionCount = visibleGroups.fold<int>(
      0,
      (count, group) => count + group.actionCount,
    );

    if (widget.plan.isClear) {
      return const Text('No action plan items.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Action Plan',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (widget.showCopyAction)
                  TextButton.icon(
                    onPressed: () => _copyActionPlanJson(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy JSON'),
                  ),
                if (widget.showChecklistCopyAction)
                  TextButton.icon(
                    onPressed: () => _copyChecklist(context),
                    icon: const Icon(Icons.checklist_outlined, size: 16),
                    label: const Text('Copy Checklist'),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ActionMetricChip(
              label: 'Actions',
              value: widget.plan.actionCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _ActionMetricChip(
              label: 'Critical',
              value: widget.plan.criticalCount.toString(),
              color: widget.plan.criticalCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            _ActionMetricChip(
              label: 'High',
              value: widget.plan.highCount.toString(),
              color: widget.plan.highCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
          ],
        ),
        if (widget.showChecklist) ...[
          const SizedBox(height: 10),
          _ReadinessChecklistPhaseStrip(checklist: checklist),
        ],
        if (widget.showFilters) ...[
          const SizedBox(height: 10),
          _ReadinessActionFilterControl(
            filter: _filter,
            onChanged: (filter) => setState(() => _filter = filter),
          ),
        ],
        const SizedBox(height: 10),
        if (visibleGroups.isEmpty)
          Text(
            'No ${registryHealthReadinessActionFilterLabel(_filter).toLowerCase()} actions.',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          for (final group in visibleGroups)
            _ReadinessActionPhaseGroupView(group: group),
        if (checklist.actionCount > visibleActionCount)
          Text(
            '+${checklist.actionCount - visibleActionCount} more actions',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  void _copyActionPlanJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(
      registryHealthReadinessActionPlanJson(
        widget.plan,
        itemLimit: widget.actionLimit,
        filter: _filter,
      ),
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Action plan JSON copied')));
  }

  void _copyChecklist(BuildContext context) {
    final text = registryHealthReadinessActionChecklistText(
      widget.plan,
      itemLimit: widget.actionLimit,
      filter: _filter,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Action checklist copied')));
  }
}

Color registryHealthReadinessActionPriorityColor(
  RegistryHealthReadinessActionPriority priority,
) {
  switch (priority) {
    case RegistryHealthReadinessActionPriority.critical:
      return Colors.red.shade700;
    case RegistryHealthReadinessActionPriority.high:
      return Colors.orange.shade800;
    case RegistryHealthReadinessActionPriority.medium:
      return Colors.blueGrey.shade600;
  }
}

class _ActionMetricChip extends StatelessWidget {
  const _ActionMetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(Icons.playlist_add_check, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ReadinessChecklistPhaseStrip extends StatelessWidget {
  const _ReadinessChecklistPhaseStrip({required this.checklist});

  final RegistryHealthReadinessActionChecklist checklist;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final phase in RegistryHealthReadinessActionPhase.values)
          _ActionMetricChip(
            label: registryHealthReadinessActionPhaseLabel(phase),
            value: checklist.phaseCount(phase).toString(),
            color: _readinessActionPhaseColor(phase),
          ),
      ],
    );
  }
}

class _ReadinessActionFilterControl extends StatelessWidget {
  const _ReadinessActionFilterControl({
    required this.filter,
    required this.onChanged,
  });

  final RegistryHealthReadinessActionFilter filter;
  final ValueChanged<RegistryHealthReadinessActionFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<RegistryHealthReadinessActionFilter>(
      showSelectedIcon: false,
      selected: {filter},
      onSelectionChanged: (selection) => onChanged(selection.first),
      segments: [
        for (final value in RegistryHealthReadinessActionFilter.values)
          ButtonSegment(
            value: value,
            label: Text(registryHealthReadinessActionFilterLabel(value)),
          ),
      ],
    );
  }
}

class _ReadinessActionPhaseGroupView extends StatelessWidget {
  const _ReadinessActionPhaseGroupView({required this.group});

  final RegistryHealthReadinessActionPhaseGroup group;

  @override
  Widget build(BuildContext context) {
    final color = _readinessActionPhaseColor(group.phase);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${group.label} · ${group.actionCount} actions',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          for (final item in group.items) _ReadinessActionRow(item: item),
        ],
      ),
    );
  }
}

class _ReadinessActionRow extends StatelessWidget {
  const _ReadinessActionRow({required this.item});

  final RegistryHealthReadinessActionItem item;

  @override
  Widget build(BuildContext context) {
    final color = registryHealthReadinessActionPriorityColor(item.priority);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.priority_high_outlined, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      item.priorityLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(item.impact, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  item.action,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

Color _readinessActionPhaseColor(RegistryHealthReadinessActionPhase phase) {
  switch (phase) {
    case RegistryHealthReadinessActionPhase.now:
      return Colors.red.shade700;
    case RegistryHealthReadinessActionPhase.next:
      return Colors.orange.shade800;
    case RegistryHealthReadinessActionPhase.later:
      return Colors.blueGrey.shade600;
  }
}
