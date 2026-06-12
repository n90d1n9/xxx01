import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/ledger_filter.dart';
import '../../models/ledger_trx.dart';
import 'ledger_provider.dart';

final filteredLedgerProvider =
    Provider.family<List<LedgerTransaction>, LedgerFilter>((ref, filter) {
      final transactions = ref.watch(combinedLedgerProvider);
      final searchTerm = filter.searchTerm?.trim().toLowerCase() ?? '';

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
              searchTerm.isEmpty ||
              transaction.id.toLowerCase().contains(searchTerm) ||
              (transaction.journalId?.toLowerCase().contains(searchTerm) ??
                  false) ||
              transaction.account.toLowerCase().contains(searchTerm) ||
              transaction.category.toLowerCase().contains(searchTerm) ||
              transaction.description.toLowerCase().contains(searchTerm) ||
              transaction.reference.toLowerCase().contains(searchTerm);

          final typeMatch =
              filter.type == null || transaction.type == filter.type;

          return dateInRange &&
              accountMatch &&
              categoryMatch &&
              searchMatch &&
              typeMatch;
        }).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });

final ledgerFilterProvider = StateProvider<LedgerFilter>((ref) {
  return const LedgerFilter();
});
