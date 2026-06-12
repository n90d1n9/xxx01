import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/account_entry.dart';
import '../../models/account_entry_line.dart';

class MobileEntryLineItem extends StatelessWidget {
  final AccountingEntryLine line;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MobileEntryLineItem({
    super.key,
    required this.line,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$');

    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.accountName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (line.memo != null && line.memo!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        line.memo!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                line.entryType == EntryType.debit
                    ? formatter.format(line.amount)
                    : '',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                line.entryType == EntryType.credit
                    ? formatter.format(line.amount)
                    : '',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 40,
              child: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                tooltip: 'Delete Line',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
