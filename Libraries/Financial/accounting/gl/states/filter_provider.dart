import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/ledger_filter.dart';
import '../models/ledger_trx.dart';
import 'ledger_provider.dart';

final filteredLedgerProvider =
    Provider.family<List<LedgerTransaction>, LedgerFilter>((ref, filter) {
      final transactions = ref.watch(ledgerProvider);

      return transactions.where((transaction) {
        // Apply date range filter
        final dateInRange =
            (filter.startDate == null ||
                !transaction.date.isBefore(filter.startDate!)) &&
            (filter.endDate == null ||
                !transaction.date.isAfter(
                  filter.endDate!.add(const Duration(days: 1)),
                ));

        // Apply account filter
        final accountMatch =
            filter.account == null ||
            filter.account!.isEmpty ||
            transaction.account.toLowerCase().contains(
              filter.account!.toLowerCase(),
            );

        // Apply category filter
        final categoryMatch =
            filter.category == null ||
            filter.category!.isEmpty ||
            transaction.category == filter.category;

        // Apply search term filter
        final searchMatch =
            filter.searchTerm == null ||
            filter.searchTerm!.isEmpty ||
            transaction.description.toLowerCase().contains(
              filter.searchTerm!.toLowerCase(),
            ) ||
            transaction.reference.toLowerCase().contains(
              filter.searchTerm!.toLowerCase(),
            );

        return dateInRange && accountMatch && categoryMatch && searchMatch;
      }).toList();
    });

final ledgerFilterProvider = StateProvider<LedgerFilter>((ref) {
  return const LedgerFilter();
});
