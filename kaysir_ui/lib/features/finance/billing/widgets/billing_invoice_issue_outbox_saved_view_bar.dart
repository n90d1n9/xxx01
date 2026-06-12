import 'package:flutter/material.dart';

import '../models/billing_invoice_issue_outbox_entry.dart';
import '../models/billing_invoice_issue_outbox_retry_snapshot.dart';
import '../models/billing_invoice_issue_outbox_saved_view.dart';

class BillingInvoiceIssueOutboxSavedViewBar extends StatelessWidget {
  final List<BillingInvoiceIssueOutboxEntry> entries;
  final Map<String, BillingInvoiceIssueOutboxRetrySnapshot> retrySnapshots;
  final BillingInvoiceIssueOutboxSavedView? selectedView;
  final ValueChanged<BillingInvoiceIssueOutboxSavedView> onSelected;
  final List<BillingInvoiceIssueOutboxSavedView> views;

  const BillingInvoiceIssueOutboxSavedViewBar({
    super.key,
    required this.entries,
    required this.retrySnapshots,
    required this.selectedView,
    required this.onSelected,
    this.views = billingInvoiceIssueOutboxDefaultSavedViews,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final view = views[index];

          return _SavedViewPill(
            view: view,
            count: view.count(entries, retrySnapshots: retrySnapshots),
            selected: selectedView?.id == view.id,
            onTap: () => onSelected(view),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemCount: views.length,
      ),
    );
  }
}

class _SavedViewPill extends StatelessWidget {
  final BillingInvoiceIssueOutboxSavedView view;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _SavedViewPill({
    required this.view,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(view.id);
    final accent = _accentFor(view.id);
    final foreground = selected ? const Color(0xFFFFFFFF) : accent;

    return Semantics(
      button: true,
      selected: selected,
      label: '${view.label}, $count commands',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 150,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: selected ? accent : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? accent : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: selected ? 0.10 : 0.04),
                  blurRadius: selected ? 14 : 8,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, size: 17, color: foreground),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    view.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _CountBadge(count: count, selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String id) {
    return switch (id) {
      'ready' => Icons.bolt_outlined,
      'waiting' => Icons.hourglass_bottom_outlined,
      'review' => Icons.report_problem_outlined,
      'active' => Icons.sync_outlined,
      'done' => Icons.cloud_done_outlined,
      _ => Icons.all_inbox_outlined,
    };
  }

  Color _accentFor(String id) {
    return switch (id) {
      'ready' => const Color(0xFF2563EB),
      'waiting' => const Color(0xFFD97706),
      'review' => const Color(0xFFDC2626),
      'active' => const Color(0xFF7C3AED),
      'done' => const Color(0xFF059669),
      _ => const Color(0xFF334155),
    };
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final bool selected;

  const _CountBadge({required this.count, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 24),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color:
            selected
                ? Colors.white.withValues(alpha: 0.18)
                : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF334155),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
