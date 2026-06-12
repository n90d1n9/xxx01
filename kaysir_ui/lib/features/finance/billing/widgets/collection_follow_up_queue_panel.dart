import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_collection_task.dart';
import '../models/billing_invoice.dart';
import '../models/billing_invoice_status.dart';
import '../models/billing_tenant_preferences.dart';
import '../utils/billing_collection_tasks.dart';
import '../utils/collection_follow_up_queue.dart';
import 'follow_up_work_queue_panel.dart';

/// Queue view that adapts collection tasks into reusable follow-up work.
class BillingCollectionFollowUpQueuePanel extends StatelessWidget {
  final List<BillingCollectionTask> tasks;
  final int maxVisibleItems;
  final ValueChanged<BillingCollectionTask>? onTaskSelected;

  const BillingCollectionFollowUpQueuePanel({
    super.key,
    required this.tasks,
    this.maxVisibleItems = 4,
    this.onTaskSelected,
  }) : assert(maxVisibleItems > 0);

  @override
  Widget build(BuildContext context) {
    final queue = buildCollectionFollowUpWorkQueue(tasks: tasks);
    final taskByItemId = {
      for (final task in tasks) collectionFollowUpWorkItemId(task): task,
    };

    return BillingFollowUpWorkQueuePanel(
      queue: queue,
      maxVisibleItems: maxVisibleItems,
      onItemSelected:
          onTaskSelected == null
              ? null
              : (item) {
                final task = taskByItemId[item.id];
                if (task != null) onTaskSelected?.call(task);
              },
    );
  }
}

@Preview(name: 'Collection follow-up queue panel')
Widget billingCollectionFollowUpQueuePanelPreview() {
  final tasks = buildBillingCollectionTasks(
    [
      BillingInvoice(
        id: 'old-overdue',
        tenantId: 'tenant-demo',
        amount: 1000,
        date: _previewOldOverdueDate,
        status: BillingInvoiceStatus.pending,
      ),
      BillingInvoice(
        id: 'recent-overdue',
        tenantId: 'tenant-demo',
        amount: 800,
        date: _previewRecentOverdueDate,
        status: BillingInvoiceStatus.pending,
      ),
      BillingInvoice(
        id: 'due-soon',
        tenantId: 'tenant-demo',
        amount: 500,
        date: _previewDueSoonDate,
        status: BillingInvoiceStatus.pending,
      ),
    ],
    now: _previewNow,
    preferences: const BillingTenantPreferences(
      currencySymbol: 'Rp ',
      decimalDigits: 0,
      paymentTermsDays: 14,
    ),
  );

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SizedBox(
          width: 760,
          child: BillingCollectionFollowUpQueuePanel(tasks: tasks),
        ),
      ),
    ),
  );
}

final _previewNow = DateTime(2026, 6, 30);
final _previewOldOverdueDate = DateTime(2026, 5, 1);
final _previewRecentOverdueDate = DateTime(2026, 6, 10);
final _previewDueSoonDate = DateTime(2026, 6, 20);
