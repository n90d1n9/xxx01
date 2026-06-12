import 'package:flutter/material.dart';

import '../models/billing_invoice_issue_outbox_sort.dart';

class BillingInvoiceIssueOutboxSortMenu extends StatelessWidget {
  final BillingInvoiceIssueOutboxSortOption value;
  final ValueChanged<BillingInvoiceIssueOutboxSortOption> onChanged;

  const BillingInvoiceIssueOutboxSortMenu({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<BillingInvoiceIssueOutboxSortOption>(
      tooltip: 'Sort issue outbox',
      initialValue: value,
      onSelected: onChanged,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder:
          (context) => [
            for (final option in BillingInvoiceIssueOutboxSortOption.values)
              PopupMenuItem<BillingInvoiceIssueOutboxSortOption>(
                value: option,
                child: _IssueOutboxSortMenuItem(
                  label: option.label,
                  selected: option == value,
                ),
              ),
          ],
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort_outlined, size: 17, color: Color(0xFF475569)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueOutboxSortMenuItem extends StatelessWidget {
  final String label;
  final bool selected;

  const _IssueOutboxSortMenuItem({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child:
              selected
                  ? const Icon(Icons.check, size: 18, color: Color(0xFF2563EB))
                  : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color:
                  selected ? const Color(0xFF1D4ED8) : const Color(0xFF334155),
              fontSize: 13,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
