import 'employee_directory_roster_payroll_run_kickoff_models.dart';

/// Directory-level launch context shared with employee payroll run workflows.
class EmployeePayrollRunLaunchContext {
  final String validationRecordId;
  final String runReference;
  final String importBatchLabel;
  final String releaseVersion;
  final String runOwner;
  final DateTime launchedAt;
  final int loadedProfileCount;
  final int payrollImpactCount;

  const EmployeePayrollRunLaunchContext({
    required this.validationRecordId,
    required this.runReference,
    required this.importBatchLabel,
    required this.releaseVersion,
    required this.runOwner,
    required this.launchedAt,
    required this.loadedProfileCount,
    required this.payrollImpactCount,
  });

  factory EmployeePayrollRunLaunchContext.fromKickoffRecord(
    EmployeeDirectoryRosterPayrollRunKickoffRecord record,
  ) {
    return EmployeePayrollRunLaunchContext(
      validationRecordId: record.validationRecordId,
      runReference: record.runReference,
      importBatchLabel: record.batchLabel,
      releaseVersion: record.releaseVersion,
      runOwner: record.runOwner,
      launchedAt: record.launchedAt,
      loadedProfileCount: record.loadedProfileCount,
      payrollImpactCount: record.payrollImpactCount,
    );
  }

  String get sourceLabel {
    return '$importBatchLabel / $releaseVersion';
  }

  String get coverageLabel {
    return '$loadedProfileCount profile'
        '${loadedProfileCount == 1 ? '' : 's'} in launched run';
  }
}
