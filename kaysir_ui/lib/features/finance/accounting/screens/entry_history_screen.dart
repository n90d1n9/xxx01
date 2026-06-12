import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../models/account_entry.dart';
import '../states/adjusment/adjustment_provider.dart';

class EntryHistoryScreen extends ConsumerWidget {
  const EntryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryHistory = ref.watch(entryHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Entry History')),
      body:
          entryHistory.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No entry history',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Posted entries will appear here',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: entryHistory.length,
                itemBuilder: (context, index) {
                  final entry = entryHistory[entryHistory.length - index - 1];
                  return Card(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      title: Text(
                        entry.description,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(DateFormat('MM/dd/yyyy').format(entry.date)),
                              const SizedBox(width: 12),
                              if (entry.referenceNumber.isNotEmpty)
                                Text('Ref: ${entry.referenceNumber}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(symbol: '\$').format(
                              entry.lines
                                  .where(
                                    (line) => line.entryType == EntryType.debit,
                                  )
                                  .fold(0.0, (sum, line) => sum + line.amount),
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              for (final line in entry.lines)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              line.accountName,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (line.memo != null &&
                                                line.memo!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4,
                                                ),
                                                child: Text(
                                                  line.memo!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade700,
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          line.entryType == EntryType.debit
                                              ? NumberFormat.currency(
                                                symbol: '\$',
                                              ).format(line.amount)
                                              : '',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          line.entryType == EntryType.credit
                                              ? NumberFormat.currency(
                                                symbol: '\$',
                                              ).format(line.amount)
                                              : '',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        flex: 5,
                                        child: Text('Total'),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          NumberFormat.currency(
                                            symbol: '\$',
                                          ).format(
                                            entry.lines
                                                .where(
                                                  (line) =>
                                                      line.entryType ==
                                                      EntryType.debit,
                                                )
                                                .fold(
                                                  0.0,
                                                  (sum, line) =>
                                                      sum + line.amount,
                                                ),
                                          ),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          NumberFormat.currency(
                                            symbol: '\$',
                                          ).format(
                                            entry.lines
                                                .where(
                                                  (line) =>
                                                      line.entryType ==
                                                      EntryType.credit,
                                                )
                                                .fold(
                                                  0.0,
                                                  (sum, line) =>
                                                      sum + line.amount,
                                                ),
                                          ),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
