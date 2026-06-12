import 'package:flutter/material.dart';

import '../models/billing_invoice_issue_outbox_entry.dart';
import '../models/billing_invoice_issue_outbox_filter.dart';
import '../models/billing_invoice_issue_outbox_retry_snapshot.dart';

class BillingInvoiceIssueOutboxFilterBar extends StatelessWidget {
  final List<BillingInvoiceIssueOutboxEntry> entries;
  final Map<String, BillingInvoiceIssueOutboxRetrySnapshot> retrySnapshots;
  final BillingInvoiceIssueOutboxFilter filter;
  final ValueChanged<BillingInvoiceIssueOutboxFilter> onChanged;

  const BillingInvoiceIssueOutboxFilterBar({
    super.key,
    required this.entries,
    required this.retrySnapshots,
    required this.filter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IssueOutboxChipStrip(
          chips: [
            _IssueOutboxFilterChipData(
              label: 'All',
              count: entries.length,
              selected: filter.status == null,
              onSelected: () => onChanged(filter.withStatus(null)),
            ),
            for (final status in BillingInvoiceIssueOutboxStatus.values)
              _IssueOutboxFilterChipData(
                label: billingInvoiceIssueOutboxStatusLabel(status),
                count: entries.where((entry) => entry.status == status).length,
                selected: filter.status == status,
                onSelected: () => onChanged(filter.withStatus(status)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _IssueOutboxChipStrip(
          chips: [
            for (final readiness
                in BillingInvoiceIssueOutboxReadinessFilter.values)
              _IssueOutboxFilterChipData(
                label: readiness.label,
                count: _readinessCount(readiness),
                selected: filter.readiness == readiness,
                onSelected: () => onChanged(filter.withReadiness(readiness)),
              ),
          ],
        ),
      ],
    );
  }

  int _readinessCount(BillingInvoiceIssueOutboxReadinessFilter readiness) {
    if (readiness == BillingInvoiceIssueOutboxReadinessFilter.all) {
      return entries.length;
    }

    return retrySnapshots.values
        .where((snapshot) => readiness.matches(snapshot.readiness))
        .length;
  }
}

class _IssueOutboxChipStrip extends StatelessWidget {
  final List<_IssueOutboxFilterChipData> chips;

  const _IssueOutboxChipStrip({required this.chips});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children:
            chips
                .map(
                  (chip) => _IssueOutboxFilterChip(
                    label: chip.label,
                    count: chip.count,
                    selected: chip.selected,
                    onSelected: chip.onSelected,
                  ),
                )
                .toList(),
      ),
    );
  }
}

class _IssueOutboxFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onSelected;

  const _IssueOutboxFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => onSelected(),
        label: Text('$label $count'),
        showCheckmark: false,
        selectedColor: const Color(0xFFE0E7FF),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? const Color(0xFF3730A3) : const Color(0xFF475569),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        side: BorderSide(
          color: selected ? const Color(0xFFA5B4FC) : const Color(0xFFE2E8F0),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _IssueOutboxFilterChipData {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onSelected;

  const _IssueOutboxFilterChipData({
    required this.label,
    required this.count,
    required this.selected,
    required this.onSelected,
  });
}
