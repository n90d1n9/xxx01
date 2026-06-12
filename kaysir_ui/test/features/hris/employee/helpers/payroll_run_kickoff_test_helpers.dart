import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_roster_payroll_run_kickoff_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_payroll_run_kickoff_provider.dart';

EmployeeDirectoryRosterPayrollRunKickoffRecord
buildPayrollRunKickoffTestRecord({
  String id = 'payroll-run-kickoff-1',
  String validationRecordId = 'payroll-validation-1',
  String batchLabel = 'PAY-202605-001',
  String releaseVersion = '2026.05.30-001',
  String runReference = 'RUN-202605-001',
  String runOwner = 'Payroll Lead',
  DateTime? launchedAt,
  int loadedProfileCount = 18,
  int validationItemCount = 3,
  int payrollImpactCount = 2,
}) {
  return EmployeeDirectoryRosterPayrollRunKickoffRecord(
    id: id,
    validationRecordId: validationRecordId,
    batchLabel: batchLabel,
    releaseVersion: releaseVersion,
    runReference: runReference,
    runOwner: runOwner,
    kickoffNote: 'Funding and payroll launch controls prepared.',
    launchedAt: launchedAt ?? DateTime(2026, 5, 30),
    loadedProfileCount: loadedProfileCount,
    validationItemCount: validationItemCount,
    payrollImpactCount: payrollImpactCount,
  );
}

void seedPayrollRunKickoffTestRecord(ProviderContainer container) {
  container
      .read(employeeDirectoryRosterPayrollRunKickoffRecordsProvider.notifier)
      .add(buildPayrollRunKickoffTestRecord());
}
