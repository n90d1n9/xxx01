import '../models/employee_directory_models.dart';
import '../models/employee_reimbursement_models.dart';

EmployeeReimbursementProfile buildEmployeeReimbursementProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeReimbursementProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    allowances: _allowancesFor(member),
    claims: _claimsFor(member, today),
  );
}

EmployeeExpenseDraft buildEmployeeExpenseDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeExpenseDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    category: EmployeeExpenseCategory.travel,
    merchant: '',
    amount: 0,
    currencyCode: _currencyFor(member),
    incurredOn: today,
    description: '',
    receiptAttached: true,
  );
}

List<EmployeeExpenseAllowance> _allowancesFor(EmployeeDirectoryMember member) {
  final currency = _currencyFor(member);
  final singapore = member.location == 'Singapore';
  final multiplier = singapore ? 1.0 : 10000.0;
  final travelLimit = 3000 * multiplier;
  final learningLimit = 1500 * multiplier;
  final wellnessLimit = 700 * multiplier;

  final isWatchlist = member.status == EmployeeDirectoryStatus.watchlist;

  return [
    EmployeeExpenseAllowance(
      id: 'EXP-${member.id}-TRAVEL',
      category: EmployeeExpenseCategory.travel,
      label: 'Travel allowance',
      currencyCode: currency,
      annualLimit: travelLimit,
      usedAmount: isWatchlist ? travelLimit * 0.94 : travelLimit * 0.22,
      pendingAmount: isWatchlist ? travelLimit * 0.04 : 0,
    ),
    EmployeeExpenseAllowance(
      id: 'EXP-${member.id}-LEARN',
      category: EmployeeExpenseCategory.learning,
      label: 'Learning budget',
      currencyCode: currency,
      annualLimit: learningLimit,
      usedAmount:
          member.isHighPerformer ? learningLimit * 0.64 : learningLimit * 0.28,
      pendingAmount: 0,
    ),
    EmployeeExpenseAllowance(
      id: 'EXP-${member.id}-WELL',
      category: EmployeeExpenseCategory.wellness,
      label: 'Wellness stipend',
      currencyCode: currency,
      annualLimit: wellnessLimit,
      usedAmount: wellnessLimit * 0.18,
      pendingAmount: 0,
    ),
  ];
}

List<EmployeeExpenseClaim> _claimsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  final currency = _currencyFor(member);
  final multiplier = member.location == 'Singapore' ? 1.0 : 10000.0;

  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeeExpenseClaim(
        id: 'EEX-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        category: EmployeeExpenseCategory.meal,
        merchant: 'Client dinner',
        amount: 18.5 * multiplier,
        currencyCode: currency,
        incurredOn: today.subtract(const Duration(days: 4)),
        submittedAt: today.subtract(const Duration(days: 2)),
        description: 'Missing meal receipt from customer onsite session.',
        receiptStatus: EmployeeExpenseReceiptStatus.missing,
        status: EmployeeExpenseClaimStatus.submitted,
      ),
      EmployeeExpenseClaim(
        id: 'EEX-${member.id}-002',
        employeeId: member.id,
        employeeName: member.name,
        category: EmployeeExpenseCategory.travel,
        merchant: 'Rail transfer',
        amount: 125 * multiplier,
        currencyCode: currency,
        incurredOn: today.subtract(const Duration(days: 7)),
        submittedAt: today.subtract(const Duration(days: 5)),
        description: 'Approved travel claim waiting for reimbursement run.',
        receiptStatus: EmployeeExpenseReceiptStatus.attached,
        status: EmployeeExpenseClaimStatus.approved,
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeExpenseClaim(
        id: 'EEX-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        category: EmployeeExpenseCategory.equipment,
        merchant: 'Home office setup',
        amount: 85 * multiplier,
        currencyCode: currency,
        incurredOn: today.subtract(const Duration(days: 1)),
        submittedAt: today,
        description: 'Initial home office equipment claim for onboarding.',
        receiptStatus: EmployeeExpenseReceiptStatus.attached,
        status: EmployeeExpenseClaimStatus.submitted,
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      EmployeeExpenseClaim(
        id: 'EEX-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        category: EmployeeExpenseCategory.learning,
        merchant: 'Design leadership course',
        amount: 220 * multiplier,
        currencyCode: currency,
        incurredOn: today.subtract(const Duration(days: 12)),
        submittedAt: today.subtract(const Duration(days: 9)),
        description: 'Professional learning reimbursement already completed.',
        receiptStatus: EmployeeExpenseReceiptStatus.attached,
        status: EmployeeExpenseClaimStatus.reimbursed,
      ),
    ];
  }

  return const [];
}

String _currencyFor(EmployeeDirectoryMember member) {
  return member.location == 'Singapore' ? 'SGD' : 'IDR';
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
