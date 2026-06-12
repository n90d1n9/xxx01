import '../models/employee_directory_models.dart';
import '../models/employee_payroll_models.dart';

EmployeePayrollProfile buildEmployeePayrollProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeePayrollProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    bankAccount: _bankAccountFor(member, today),
    taxProfile: _taxProfileFor(member, today),
    schedule: _scheduleFor(member, today),
    changes: _changesFor(member, today),
  );
}

EmployeePayrollChangeDraft buildEmployeePayrollChangeDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeePayrollChangeDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    type: EmployeePayrollChangeType.bankAccount,
    title: 'Update payroll bank account',
    requestedBy: member.manager,
    effectiveDate: today.add(const Duration(days: 14)),
    detail: '',
  );
}

EmployeePayrollBankAccount _bankAccountFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return const EmployeePayrollBankAccount(
      bankName: 'Not configured',
      maskedAccount: 'Missing',
      routingCode: 'Missing',
      country: 'ID',
      verificationStatus: EmployeeBankVerificationStatus.missing,
      lastVerifiedAt: null,
    );
  }

  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return EmployeePayrollBankAccount(
      bankName: 'Bank Central Asia',
      maskedAccount: '**** 4391',
      routingCode: 'BCA-ID',
      country: 'ID',
      verificationStatus: EmployeeBankVerificationStatus.pending,
      lastVerifiedAt: today.subtract(const Duration(days: 120)),
    );
  }

  return EmployeePayrollBankAccount(
    bankName: member.location == 'Singapore' ? 'DBS Bank' : 'Bank Central Asia',
    maskedAccount: member.location == 'Singapore' ? '**** 8834' : '**** 2188',
    routingCode: member.location == 'Singapore' ? 'DBS-SG' : 'BCA-ID',
    country: member.location == 'Singapore' ? 'SG' : 'ID',
    verificationStatus: EmployeeBankVerificationStatus.verified,
    lastVerifiedAt: today.subtract(const Duration(days: 36)),
  );
}

EmployeePayrollTaxProfile _taxProfileFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return EmployeePayrollTaxProfile(
      taxIdMasked: 'Missing',
      formType: 'NPWP',
      filingStatus: 'Missing',
      allowanceCount: 0,
      status: EmployeeTaxFormStatus.missing,
      lastUpdatedAt: today.subtract(const Duration(days: 1)),
    );
  }

  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return EmployeePayrollTaxProfile(
      taxIdMasked: '***-***-781',
      formType: 'NPWP',
      filingStatus: 'Single',
      allowanceCount: 1,
      status: EmployeeTaxFormStatus.rejected,
      lastUpdatedAt: today.subtract(const Duration(days: 18)),
    );
  }

  return EmployeePayrollTaxProfile(
    taxIdMasked: member.location == 'Singapore' ? 'S****823D' : '***-***-218',
    formType: member.location == 'Singapore' ? 'IR8A' : 'NPWP',
    filingStatus: member.location == 'Singapore' ? 'Resident' : 'Single',
    allowanceCount: member.location == 'Singapore' ? 0 : 1,
    status:
        member.id == '2'
            ? EmployeeTaxFormStatus.expiring
            : EmployeeTaxFormStatus.current,
    lastUpdatedAt: today.subtract(const Duration(days: 270)),
  );
}

EmployeePayrollSchedule _scheduleFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  return EmployeePayrollSchedule(
    payGroup:
        member.location == 'Singapore' ? 'SG monthly payroll' : 'ID payroll',
    payCycle: 'Monthly',
    currencyCode: member.location == 'Singapore' ? 'SGD' : 'IDR',
    paymentMethod:
        member.status == EmployeeDirectoryStatus.onboarding
            ? EmployeePaymentMethod.manual
            : EmployeePaymentMethod.bankTransfer,
    nextPayDate: DateTime(today.year, today.month + 1, 25),
    cutoffDate: DateTime(today.year, today.month + 1, 15),
  );
}

List<EmployeePayrollChangeRequest> _changesFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeePayrollChangeRequest(
        id: 'EPC-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeePayrollChangeType.bankAccount,
        title: 'Initial direct deposit setup',
        requestedBy: member.manager,
        effectiveDate: today.add(const Duration(days: 5)),
        detail: 'Collect and verify bank account before first payroll.',
        status: EmployeePayrollChangeStatus.submitted,
        submittedAt: today,
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeePayrollChangeRequest(
        id: 'EPC-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeePayrollChangeType.taxWithholding,
        title: 'Tax withholding correction',
        requestedBy: 'People Operations',
        effectiveDate: today.add(const Duration(days: 8)),
        detail: 'Rejected tax form needs corrected withholding information.',
        status: EmployeePayrollChangeStatus.submitted,
        submittedAt: today.subtract(const Duration(days: 2)),
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      EmployeePayrollChangeRequest(
        id: 'EPC-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeePayrollChangeType.paymentMethod,
        title: 'Confirm payment method',
        requestedBy: member.manager,
        effectiveDate: today.add(const Duration(days: 20)),
        detail: 'Confirm payment method before approved compensation update.',
        status: EmployeePayrollChangeStatus.approved,
        submittedAt: today.subtract(const Duration(days: 5)),
      ),
    ];
  }

  return const [];
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
