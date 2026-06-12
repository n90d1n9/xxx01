import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_data_correction_governance_models.dart';
import '../models/employee_data_correction_models.dart';
import 'employee_data_correction_provider.dart';

final employeeDataCorrectionGovernanceProvider = StateNotifierProvider.family<
  EmployeeDataCorrectionGovernanceNotifier,
  EmployeeDataCorrectionGovernanceProfile?,
  String
>((ref, employeeId) {
  final correction = ref.watch(employeeDataCorrectionProvider(employeeId));
  if (correction == null) {
    return EmployeeDataCorrectionGovernanceNotifier(null);
  }

  return EmployeeDataCorrectionGovernanceNotifier(
    EmployeeDataCorrectionGovernanceProfile(
      employeeId: correction.employeeId,
      employeeName: correction.employeeName,
      asOfDate: correction.asOfDate,
      requests: correction.sortedRequests,
      evidence: _seedEvidence(correction),
      waivedRuleIds: const {},
    ),
  );
});

final employeeDataCorrectionEvidenceDraftProvider =
    StateNotifierProvider.family<
      EmployeeDataCorrectionEvidenceDraftNotifier,
      EmployeeDataCorrectionEvidenceDraft?,
      String
    >((ref, employeeId) {
      final correction = ref.watch(employeeDataCorrectionProvider(employeeId));
      if (correction == null) {
        return EmployeeDataCorrectionEvidenceDraftNotifier(null);
      }

      return EmployeeDataCorrectionEvidenceDraftNotifier(
        EmployeeDataCorrectionEvidenceDraft(
          employeeId: correction.employeeId,
          employeeName: correction.employeeName,
          asOfDate: correction.asOfDate,
          requestId:
              correction.sortedRequests.isEmpty
                  ? ''
                  : correction.sortedRequests.first.id,
          author: 'People Operations',
          summary: '',
        ),
      );
    });

class EmployeeDataCorrectionGovernanceNotifier
    extends StateNotifier<EmployeeDataCorrectionGovernanceProfile?> {
  EmployeeDataCorrectionGovernanceNotifier(super.state);

  EmployeeDataCorrectionEvidence addEvidence(
    EmployeeDataCorrectionEvidenceDraft draft,
  ) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee correction governance is unavailable');
    }
    if (!profile.requests.any((request) => request.id == draft.requestId)) {
      throw StateError('Selected correction request is unavailable');
    }

    final evidence = draft.toEvidence(id: _nextEvidenceId(profile));
    state = profile.copyWith(evidence: [evidence, ...profile.evidence]);
    return evidence;
  }

  void waiveRule(String ruleId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(waivedRuleIds: {...profile.waivedRuleIds, ruleId});
  }

  void reinstateRule(String ruleId) {
    final profile = state;
    if (profile == null) return;

    final updated = {...profile.waivedRuleIds}..remove(ruleId);
    state = profile.copyWith(waivedRuleIds: updated);
  }

  String _nextEvidenceId(EmployeeDataCorrectionGovernanceProfile profile) {
    var index = profile.evidence.length + 1;
    while (true) {
      final id =
          'EDCE-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.evidence.any((item) => item.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeDataCorrectionEvidenceDraftNotifier
    extends StateNotifier<EmployeeDataCorrectionEvidenceDraft?> {
  final EmployeeDataCorrectionEvidenceDraft? _initialDraft;

  EmployeeDataCorrectionEvidenceDraftNotifier(super.state)
    : _initialDraft = state;

  void setRequestId(String value) {
    state = state?.copyWith(requestId: value);
  }

  void setAuthor(String value) {
    state = state?.copyWith(author: value);
  }

  void setSummary(String value) {
    state = state?.copyWith(summary: value);
  }

  void reset() {
    state = _initialDraft;
  }
}

List<EmployeeDataCorrectionEvidence> _seedEvidence(
  EmployeeDataCorrectionProfile correction,
) {
  return correction.requests
      .where(
        (request) => request.status == EmployeeDataCorrectionStatus.applied,
      )
      .map(
        (request) => EmployeeDataCorrectionEvidence(
          id: 'EDCE-${request.id}-applied',
          employeeId: request.employeeId,
          requestId: request.id,
          author: request.reviewer,
          summary: 'Correction was applied after review approval.',
          createdAt: correction.asOfDate,
        ),
      )
      .toList();
}
