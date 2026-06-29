import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_engagement_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_engagement_models.dart';
import 'employee_directory_provider.dart';

final employeeEngagementPlanProvider = StateNotifierProvider.family<
  EmployeeEngagementPlanNotifier,
  EmployeeEngagementPlan?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeEngagementPlanNotifier(null);
  }

  return EmployeeEngagementPlanNotifier(
    buildEmployeeEngagementPlan(member: member, asOfDate: asOfDate),
  );
});

final employeeEngagementPulseDraftProvider = StateNotifierProvider.family<
  EmployeeEngagementPulseDraftNotifier,
  EmployeeEngagementPulseDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeEngagementPulseDraftNotifier(null);
  }

  return EmployeeEngagementPulseDraftNotifier(
    buildEmployeeEngagementPulseDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeEngagementPlanNotifier
    extends StateNotifier<EmployeeEngagementPlan?> {
  EmployeeEngagementPlanNotifier(super.state);

  EmployeeEngagementPulse addPulse(EmployeeEngagementPulseDraft draft) {
    final plan = state;
    if (plan == null) {
      throw StateError('Employee engagement plan is unavailable');
    }

    final pulse = draft.toPulse(id: _nextPulseId(plan));
    state = _withAssessedStatus(plan.copyWith(pulses: [pulse, ...plan.pulses]));
    return pulse;
  }

  void updateSignalStatus(
    String signalId,
    EmployeeRetentionSignalStatus status,
  ) {
    final plan = state;
    if (plan == null) return;

    final updatedPlan = plan.copyWith(
      signals:
          plan.signals.map((signal) {
            if (signal.id == signalId) {
              return signal.copyWith(status: status);
            }
            return signal;
          }).toList(),
    );
    state = _withAssessedStatus(updatedPlan);
  }

  void resolveSignal(String signalId) {
    updateSignalStatus(signalId, EmployeeRetentionSignalStatus.resolved);
  }

  String _nextPulseId(EmployeeEngagementPlan plan) {
    return 'EEP-${plan.employeeId}-${(plan.pulses.length + 1).toString().padLeft(3, '0')}';
  }

  EmployeeEngagementPlan _withAssessedStatus(EmployeeEngagementPlan plan) {
    if (plan.criticalSignalCount > 0 || plan.averagePulseScore < 3) {
      return plan.copyWith(status: EmployeeEngagementStatus.critical);
    }
    if (plan.openSignalCount > 0 || plan.averagePulseScore < 4) {
      return plan.copyWith(status: EmployeeEngagementStatus.watch);
    }
    if (plan.averagePulseScore >= 4.5) {
      return plan.copyWith(status: EmployeeEngagementStatus.thriving);
    }
    return plan.copyWith(status: EmployeeEngagementStatus.steady);
  }
}

class EmployeeEngagementPulseDraftNotifier
    extends StateNotifier<EmployeeEngagementPulseDraft?> {
  final EmployeeEngagementPulseDraft? _initialDraft;

  EmployeeEngagementPulseDraftNotifier(super.state) : _initialDraft = state;

  void setSentiment(EmployeeEngagementSentiment value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(sentiment: value);
  }

  void setScore(int value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(score: value);
  }

  void setSummary(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(summary: value);
  }

  void setNextStep(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(nextStep: value);
  }

  void reset() {
    state = _initialDraft;
  }
}

EmployeeDirectoryMember? _findMember(
  List<EmployeeDirectoryMember> members,
  String employeeId,
) {
  for (final member in members) {
    if (member.id == employeeId) {
      return member;
    }
  }
  return null;
}
