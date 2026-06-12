import 'package:flutter/material.dart';

import '../../models/account_entry.dart';

class MobileEntryBalanceStatus extends StatelessWidget {
  final AccountingEntry entry;

  const MobileEntryBalanceStatus({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isBalanced = entry.isBalanced;
    final balancingType = entry.requiredBalancingType;
    final balancingLabel =
        balancingType == null ? '' : balancingType.name.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isBalanced ? Colors.green.shade100 : Colors.amber.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBalanced ? Icons.check_circle : Icons.warning_amber_rounded,
            color: isBalanced ? Colors.green.shade700 : Colors.amber.shade700,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isBalanced ? 'Balanced' : 'Needs $balancingLabel',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isBalanced ? Colors.green.shade700 : Colors.amber.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
