import 'models/ledger_trx.dart';

final trx_dummy = [
  // Sample data
  LedgerTransaction(
    date: DateTime.now().subtract(const Duration(days: 5)),
    account: "1000 - Cash",
    description: "Initial investment",
    type: TransactionType.debit,
    amount: 10000.00,
    reference: "INV-001",
    category: "Capital",
  ),
  LedgerTransaction(
    date: DateTime.now().subtract(const Duration(days: 4)),
    account: "2000 - Accounts Payable",
    description: "Office supplies purchase",
    type: TransactionType.credit,
    amount: 500.00,
    reference: "INV-002",
    category: "Expenses",
  ),
  LedgerTransaction(
    date: DateTime.now().subtract(const Duration(days: 3)),
    account: "4000 - Revenue",
    description: "Client payment",
    type: TransactionType.debit,
    amount: 2500.00,
    reference: "PMT-001",
    category: "Income",
  ),
];
