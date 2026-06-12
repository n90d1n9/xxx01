// Desktop-specific entry line item
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/account_entry.dart';
import '../models/account_entry_line.dart';

class DesktopEntryLineItem extends StatelessWidget {
  final AccountingEntryLine line;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DesktopEntryLineItem({
    Key? key,
    required this.line,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$');

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                line.accountName,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                line.memo ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                line.entryType == EntryType.debit
                    ? formatter.format(line.amount)
                    : '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      line.entryType == EntryType.debit
                          ? FontWeight.w500
                          : null,
                ),
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                line.entryType == EntryType.credit
                    ? formatter.format(line.amount)
                    : '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      line.entryType == EntryType.credit
                          ? FontWeight.w500
                          : null,
                ),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: onEdit,
                    tooltip: 'Edit Line',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Delete Line',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
