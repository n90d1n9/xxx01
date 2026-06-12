import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_approval_policy_seed_data.dart';
import '../models/employee_approval_policy_models.dart';
import '../models/employee_directory_models.dart';
import 'employee_directory_provider.dart';

final employeeApprovalPolicyProfileProvider = StateNotifierProvider.family<
  EmployeeApprovalPolicyProfileNotifier,
  EmployeeApprovalPolicyProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeApprovalPolicyProfileNotifier(null);
  }

  return EmployeeApprovalPolicyProfileNotifier(
    buildEmployeeApprovalPolicyProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeApprovalPolicyDraftProvider = StateNotifierProvider.family<
  EmployeeApprovalPolicyRuleDraftNotifier,
  EmployeeApprovalPolicyRuleDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeApprovalPolicyRuleDraftNotifier(null);
  }

  return EmployeeApprovalPolicyRuleDraftNotifier(
    buildEmployeeApprovalPolicyRuleDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeApprovalPolicyProfileNotifier
    extends StateNotifier<EmployeeApprovalPolicyProfile?> {
  EmployeeApprovalPolicyProfileNotifier(super.state);

  EmployeeApprovalPolicyRule submitDraft(
    EmployeeApprovalPolicyRuleDraft draft,
  ) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee approval policy profile is unavailable');
    }

    final rule = draft.toRule(id: _nextRuleId(profile));
    state = profile.copyWith(rules: [rule, ...profile.rules]);
    return rule;
  }

  void activate(String ruleId) {
    _updateRule(
      ruleId,
      (rule) => rule.copyWith(status: EmployeeApprovalPolicyStatus.active),
    );
  }

  void requestReview(String ruleId) {
    _updateRule(
      ruleId,
      (rule) =>
          rule.copyWith(status: EmployeeApprovalPolicyStatus.reviewRequired),
    );
  }

  void suspend(String ruleId) {
    _updateRule(
      ruleId,
      (rule) => rule.copyWith(status: EmployeeApprovalPolicyStatus.suspended),
    );
  }

  void renew(String ruleId, {DateTime? expiresOn}) {
    final profile = state;
    if (profile == null) return;
    final nextExpiry =
        expiresOn ?? profile.asOfDate.add(const Duration(days: 90));

    _updateRule(
      ruleId,
      (rule) => rule.copyWith(
        expiresOn: DateTime(nextExpiry.year, nextExpiry.month, nextExpiry.day),
        status: EmployeeApprovalPolicyStatus.active,
      ),
    );
  }

  void remove(String ruleId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      rules: profile.rules.where((rule) => rule.id != ruleId).toList(),
    );
  }

  void _updateRule(
    String ruleId,
    EmployeeApprovalPolicyRule Function(EmployeeApprovalPolicyRule rule) update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      rules:
          profile.rules.map((rule) {
            if (rule.id != ruleId) return rule;
            return update(rule);
          }).toList(),
    );
  }

  String _nextRuleId(EmployeeApprovalPolicyProfile profile) {
    var index = profile.rules.length + 1;
    while (true) {
      final id =
          'APR-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.rules.any((rule) => rule.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeApprovalPolicyRuleDraftNotifier
    extends StateNotifier<EmployeeApprovalPolicyRuleDraft?> {
  final EmployeeApprovalPolicyRuleDraft? _initialDraft;

  EmployeeApprovalPolicyRuleDraftNotifier(super.state) : _initialDraft = state;

  void setArea(EmployeeApprovalPolicyArea value) {
    state = state?.copyWith(area: value);
  }

  void setName(String value) {
    state = state?.copyWith(name: value);
  }

  void setPrimaryRoute(EmployeeApprovalRoute value) {
    state = state?.copyWith(primaryRoute: value);
  }

  void setFallbackRoute(EmployeeApprovalRoute value) {
    state = state?.copyWith(fallbackRoute: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setThresholdLabel(String value) {
    state = state?.copyWith(thresholdLabel: value);
  }

  void setEscalationHours(int value) {
    state = state?.copyWith(escalationHours: value);
  }

  void setEscalationMode(EmployeeApprovalEscalationMode value) {
    state = state?.copyWith(escalationMode: value);
  }

  void setExpiresOn(DateTime value) {
    state = state?.copyWith(
      expiresOn: DateTime(value.year, value.month, value.day),
    );
  }

  void setRisk(EmployeeApprovalPolicyRisk value) {
    state = state?.copyWith(risk: value);
  }

  void setNotes(String value) {
    state = state?.copyWith(notes: value);
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
