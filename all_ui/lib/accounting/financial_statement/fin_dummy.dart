import 'models/financial_entry.dart';

final financeDummy = [
  // Income
  FinancialEntry(
    name: 'Sales Revenue',
    amount: 150000,
    date: DateTime(2025, 1, 15),
    category: 'Revenue',
    type: 'income',
  ),
  FinancialEntry(
    name: 'Service Fees',
    amount: 25000,
    date: DateTime(2025, 1, 20),
    category: 'Revenue',
    type: 'income',
  ),
  FinancialEntry(
    name: 'Interest Income',
    amount: 5000,
    date: DateTime(2025, 1, 25),
    category: 'Other Income',
    type: 'income',
  ),

  // Expenses
  FinancialEntry(
    name: 'Rent',
    amount: 12000,
    date: DateTime(2025, 1, 5),
    category: 'Operating Expenses',
    type: 'expense',
  ),
  FinancialEntry(
    name: 'Salaries',
    amount: 60000,
    date: DateTime(2025, 1, 15),
    category: 'Operating Expenses',
    type: 'expense',
  ),
  FinancialEntry(
    name: 'Utilities',
    amount: 4500,
    date: DateTime(2025, 1, 10),
    category: 'Operating Expenses',
    type: 'expense',
  ),
  FinancialEntry(
    name: 'Supplies',
    amount: 7500,
    date: DateTime(2025, 1, 12),
    category: 'Operating Expenses',
    type: 'expense',
  ),
  FinancialEntry(
    name: 'Marketing',
    amount: 15000,
    date: DateTime(2025, 1, 8),
    category: 'Marketing Expenses',
    type: 'expense',
  ),
  FinancialEntry(
    name: 'Insurance',
    amount: 3500,
    date: DateTime(2025, 1, 3),
    category: 'Operating Expenses',
    type: 'expense',
  ),
  FinancialEntry(
    name: 'Interest Expense',
    amount: 2000,
    date: DateTime(2025, 1, 28),
    category: 'Financial Expenses',
    type: 'expense',
  ),

  // Assets
  FinancialEntry(
    name: 'Cash',
    amount: 75000,
    date: DateTime(2025, 1, 31),
    category: 'Current Assets',
    type: 'asset',
  ),
  FinancialEntry(
    name: 'Accounts Receivable',
    amount: 35000,
    date: DateTime(2025, 1, 31),
    category: 'Current Assets',
    type: 'asset',
  ),
  FinancialEntry(
    name: 'Inventory',
    amount: 45000,
    date: DateTime(2025, 1, 31),
    category: 'Current Assets',
    type: 'asset',
  ),
  FinancialEntry(
    name: 'Office Equipment',
    amount: 25000,
    date: DateTime(2025, 1, 31),
    category: 'Fixed Assets',
    type: 'asset',
  ),
  FinancialEntry(
    name: 'Vehicles',
    amount: 35000,
    date: DateTime(2025, 1, 31),
    category: 'Fixed Assets',
    type: 'asset',
  ),
  FinancialEntry(
    name: 'Building',
    amount: 250000,
    date: DateTime(2025, 1, 31),
    category: 'Fixed Assets',
    type: 'asset',
  ),

  // Liabilities
  FinancialEntry(
    name: 'Accounts Payable',
    amount: 28000,
    date: DateTime(2025, 1, 31),
    category: 'Current Liabilities',
    type: 'liability',
  ),
  FinancialEntry(
    name: 'Short Term Loans',
    amount: 15000,
    date: DateTime(2025, 1, 31),
    category: 'Current Liabilities',
    type: 'liability',
  ),
  FinancialEntry(
    name: 'Long Term Loans',
    amount: 120000,
    date: DateTime(2025, 1, 31),
    category: 'Long Term Liabilities',
    type: 'liability',
  ),
  FinancialEntry(
    name: 'Mortgage',
    amount: 180000,
    date: DateTime(2025, 1, 31),
    category: 'Long Term Liabilities',
    type: 'liability',
  ),
];
