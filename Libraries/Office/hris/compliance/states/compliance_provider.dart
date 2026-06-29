import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/compliance_seed_data.dart';
import '../models/compliance_models.dart';

const complianceAllDepartments = 'All';

final complianceDepartmentProvider = StateProvider<String>(
  (ref) => complianceAllDepartments,
);
final complianceAttentionOnlyProvider = StateProvider<bool>((ref) => false);
final complianceAsOfDateProvider = Provider<DateTime>((ref) => DateTime.now());

final complianceControlsProvider = Provider<List<ComplianceControl>>((ref) {
  return buildComplianceControls(ref.watch(complianceAsOfDateProvider));
});

final policyAcknowledgementsProvider = Provider<List<PolicyAcknowledgement>>((
  ref,
) {
  return buildPolicyAcknowledgements(ref.watch(complianceAsOfDateProvider));
});

final complianceDocumentsProvider = Provider<List<ComplianceDocument>>((ref) {
  return buildComplianceDocuments(ref.watch(complianceAsOfDateProvider));
});

final auditFindingsProvider = Provider<List<AuditFinding>>((ref) {
  return buildAuditFindings(ref.watch(complianceAsOfDateProvider));
});

final complianceDepartmentsProvider = Provider<List<String>>((ref) {
  final departments =
      <String>{
          ...ref
              .watch(complianceControlsProvider)
              .map((item) => item.department),
          ...ref
              .watch(policyAcknowledgementsProvider)
              .map((item) => item.department),
          ...ref
              .watch(complianceDocumentsProvider)
              .map((item) => item.department),
          ...ref.watch(auditFindingsProvider).map((item) => item.department),
        }.toList()
        ..sort();

  return [
    complianceAllDepartments,
    ...departments.where((item) => item != complianceAllDepartments),
  ];
});

final filteredComplianceControlsProvider = Provider<List<ComplianceControl>>((
  ref,
) {
  return ref
      .watch(complianceControlsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(
              ref,
              item.status == ComplianceControlStatus.overdue ||
                  item.status == ComplianceControlStatus.blocked ||
                  item.status == ComplianceControlStatus.dueSoon,
            ),
      )
      .toList();
});

final filteredPolicyAcknowledgementsProvider =
    Provider<List<PolicyAcknowledgement>>((ref) {
      return ref
          .watch(policyAcknowledgementsProvider)
          .where(
            (item) =>
                _matchesDepartment(ref, item.department, includeGlobal: true) &&
                _matchesAttention(
                  ref,
                  item.status == PolicyAcknowledgementStatus.escalated ||
                      item.status == PolicyAcknowledgementStatus.draft ||
                      item.pendingCount > 0,
                ),
          )
          .toList();
    });

final filteredComplianceDocumentsProvider = Provider<List<ComplianceDocument>>((
  ref,
) {
  return ref
      .watch(complianceDocumentsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(ref, item.risk != DocumentExpiryRisk.low),
      )
      .toList();
});

final filteredAuditFindingsProvider = Provider<List<AuditFinding>>((ref) {
  return ref
      .watch(auditFindingsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(
              ref,
              item.status == AuditFindingStatus.open ||
                  item.status == AuditFindingStatus.remediating ||
                  item.severity == AuditFindingSeverity.critical ||
                  item.severity == AuditFindingSeverity.high,
            ),
      )
      .toList();
});

final complianceEscalationSummaryProvider =
    Provider<ComplianceEscalationSummary>((ref) {
      return ComplianceEscalationSummary.fromData(
        controls: ref.watch(filteredComplianceControlsProvider),
        policies: ref.watch(filteredPolicyAcknowledgementsProvider),
        documents: ref.watch(filteredComplianceDocumentsProvider),
        findings: ref.watch(filteredAuditFindingsProvider),
        asOfDate: ref.watch(complianceAsOfDateProvider),
      );
    });

final complianceSummaryProvider = Provider<ComplianceSummary>((ref) {
  final controls = ref.watch(filteredComplianceControlsProvider);
  final acknowledgements = ref.watch(filteredPolicyAcknowledgementsProvider);
  final documents = ref.watch(filteredComplianceDocumentsProvider);
  final findings = ref.watch(filteredAuditFindingsProvider);

  return ComplianceSummary(
    controlsDue:
        controls
            .where((item) => item.status != ComplianceControlStatus.compliant)
            .length,
    overdueControls:
        controls
            .where((item) => item.status == ComplianceControlStatus.overdue)
            .length,
    pendingAcknowledgements: acknowledgements.fold<int>(
      0,
      (sum, item) => sum + item.pendingCount,
    ),
    documentRisks:
        documents.where((item) => item.risk != DocumentExpiryRisk.low).length,
    openFindings:
        findings
            .where(
              (item) =>
                  item.status == AuditFindingStatus.open ||
                  item.status == AuditFindingStatus.remediating,
            )
            .length,
    criticalFindings:
        findings
            .where((item) => item.severity == AuditFindingSeverity.critical)
            .length,
  );
});

bool _matchesDepartment(
  Ref ref,
  String department, {
  bool includeGlobal = false,
}) {
  final selectedDepartment = ref.watch(complianceDepartmentProvider);
  return selectedDepartment == complianceAllDepartments ||
      department == selectedDepartment ||
      (includeGlobal && department == complianceAllDepartments);
}

bool _matchesAttention(Ref ref, bool needsAttention) {
  return !ref.watch(complianceAttentionOnlyProvider) || needsAttention;
}
