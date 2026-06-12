import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../models/account_entry.dart';

class EntryBalanceIndicator extends ConsumerWidget {
  final AccountingEntry entry;

  const EntryBalanceIndicator({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBalanced = entry.isBalanced;
    final balancingType = entry.requiredBalancingType;
    final balancingLabel =
        balancingType == null ? '' : balancingType.name.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isBalanced ? Colors.green.shade100 : Colors.amber.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBalanced ? Icons.check_circle : Icons.warning_amber_rounded,
            color: isBalanced ? Colors.green.shade700 : Colors.amber.shade700,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            isBalanced
                ? 'Balanced'
                : 'Needs $balancingLabel ${NumberFormat.currency(symbol: '\$').format(entry.requiredBalancingAmount)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isBalanced ? Colors.green.shade700 : Colors.amber.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
