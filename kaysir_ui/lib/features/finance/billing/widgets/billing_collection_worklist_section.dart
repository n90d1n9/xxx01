import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_collection_task.dart';
import '../models/billing_tenant_preferences.dart';
import '../states/billing_dashboard_provider.dart';
import '../utils/billing_collection_tasks.dart';

class BillingCollectionWorklistSection extends ConsumerWidget {
  final String tenantId;
  final BillingTenantPreferences preferences;
  final DateTime? now;
  final int limit;
  final ValueChanged<BillingCollectionTask>? onTaskSelected;

  const BillingCollectionWorklistSection({
    super.key,
    required this.tenantId,
    this.preferences = const BillingTenantPreferences(),
    this.now,
    this.limit = 4,
    this.onTaskSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(billingInvoicesProvider(tenantId));

    return invoicesAsync.when(
      loading:
          () => const _CollectionWorklistFrame(
            child: SizedBox(
              height: 96,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      error:
          (error, stack) => const _CollectionWorklistFrame(
            child: SizedBox(
              height: 96,
              child: Center(child: Text('Unable to load collection worklist')),
            ),
          ),
      data: (invoices) {
        final tasks = buildBillingCollectionTasks(
          invoices,
          preferences: preferences,
          now: now,
          limit: limit,
        );

        return BillingCollectionWorklistPanel(
          tasks: tasks,
          onTaskSelected: onTaskSelected,
        );
      },
    );
  }
}

class BillingCollectionWorklistPanel extends StatelessWidget {
  final List<BillingCollectionTask> tasks;
  final ValueChanged<BillingCollectionTask>? onTaskSelected;

  const BillingCollectionWorklistPanel({
    super.key,
    required this.tasks,
    this.onTaskSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _CollectionWorklistFrame(
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
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Color(0xFF2563EB),
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Collection worklist',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _headlineFor(tasks),
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _supportingTextFor(tasks),
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (tasks.isEmpty)
            const _CollectionWorklistEmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 760;
                final itemWidth =
                    isWide
                        ? (constraints.maxWidth - 12) / 2
                        : constraints.maxWidth;

                return Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children:
                      tasks.map((task) {
                        return SizedBox(
                          width: itemWidth,
                          child: _CollectionTaskTile(
                            task: task,
                            onTap:
                                onTaskSelected == null
                                    ? null
                                    : () => onTaskSelected?.call(task),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  String _headlineFor(List<BillingCollectionTask> tasks) {
    if (tasks.isEmpty) return 'No collection tasks';

    final urgentCount =
        tasks
            .where(
              (task) => task.priority == BillingCollectionTaskPriority.urgent,
            )
            .length;
    if (urgentCount > 0) {
      return '$urgentCount urgent ${urgentCount == 1 ? 'task' : 'tasks'}';
    }
    return '${tasks.length} prioritized ${tasks.length == 1 ? 'task' : 'tasks'} ready';
  }

  String _supportingTextFor(List<BillingCollectionTask> tasks) {
    if (tasks.isEmpty) {
      return 'Open invoices are settled or not yet ready for collection follow-up.';
    }

    return 'Ranked by aging severity, due date, and amount so operators can act first.';
  }
}

class _CollectionWorklistFrame extends StatelessWidget {
  final Widget child;

  const _CollectionWorklistFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}

class _CollectionTaskTile extends StatelessWidget {
  final BillingCollectionTask task;
  final VoidCallback? onTap;

  const _CollectionTaskTile({required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    final visuals = _CollectionTaskVisuals.fromPriority(task.priority);

    return Material(
      color: visuals.surfaceColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 108),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: visuals.borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: visuals.badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _iconFor(task.action),
                  color: visuals.color,
                  size: 18,
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
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _PriorityPill(
                          label: task.priority.label,
                          color: visuals.color,
                          backgroundColor: visuals.badgeColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.description,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _TaskMetaChip(label: task.action.label),
                        _TaskMetaChip(label: 'Due ${task.dueText}'),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(BillingCollectionTaskAction action) {
    switch (action) {
      case BillingCollectionTaskAction.collectPayment:
        return Icons.payments_outlined;
      case BillingCollectionTaskAction.sendReminder:
        return Icons.mark_email_unread_outlined;
      case BillingCollectionTaskAction.monitor:
        return Icons.visibility_outlined;
    }
  }
}

class _PriorityPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;

  const _PriorityPill({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TaskMetaChip extends StatelessWidget {
  final String label;

  const _TaskMetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CollectionWorklistEmptyState extends StatelessWidget {
  const _CollectionWorklistEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Text(
        'No invoices need collection action right now.',
        style: TextStyle(
          color: Color(0xFF475569),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CollectionTaskVisuals {
  final Color color;
  final Color badgeColor;
  final Color surfaceColor;
  final Color borderColor;

  const _CollectionTaskVisuals({
    required this.color,
    required this.badgeColor,
    required this.surfaceColor,
    required this.borderColor,
  });

  factory _CollectionTaskVisuals.fromPriority(
    BillingCollectionTaskPriority priority,
  ) {
    switch (priority) {
      case BillingCollectionTaskPriority.urgent:
        return const _CollectionTaskVisuals(
          color: Color(0xFFBE123C),
          badgeColor: Color(0xFFFFE4E6),
          surfaceColor: Color(0xFFFFF7F7),
          borderColor: Color(0xFFFECDD3),
        );
      case BillingCollectionTaskPriority.high:
        return const _CollectionTaskVisuals(
          color: Color(0xFFB45309),
          badgeColor: Color(0xFFFEF3C7),
          surfaceColor: Color(0xFFFFFBEB),
          borderColor: Color(0xFFFDE68A),
        );
      case BillingCollectionTaskPriority.normal:
        return const _CollectionTaskVisuals(
          color: Color(0xFF2563EB),
          badgeColor: Color(0xFFDBEAFE),
          surfaceColor: Color(0xFFF8FAFC),
          borderColor: Color(0xFFBFDBFE),
        );
    }
  }
}
