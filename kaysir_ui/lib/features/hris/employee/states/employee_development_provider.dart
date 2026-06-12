import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_development_seed_data.dart';
import '../models/employee_development_models.dart';
import '../models/employee_directory_models.dart';
import 'employee_directory_provider.dart';

final employeeDevelopmentPlanProvider = StateNotifierProvider.family<
  EmployeeDevelopmentPlanNotifier,
  EmployeeDevelopmentPlan?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeDevelopmentPlanNotifier(null);
  }

  return EmployeeDevelopmentPlanNotifier(
    buildEmployeeDevelopmentPlan(member: member, asOfDate: asOfDate),
  );
});

final employeeLearningAssignmentDraftProvider = StateNotifierProvider.family<
  EmployeeLearningAssignmentDraftNotifier,
  EmployeeLearningAssignmentDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeLearningAssignmentDraftNotifier(null);
  }

  return EmployeeLearningAssignmentDraftNotifier(
    buildEmployeeLearningAssignmentDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeDevelopmentPlanNotifier
    extends StateNotifier<EmployeeDevelopmentPlan?> {
  EmployeeDevelopmentPlanNotifier(super.state);

  void updateSkillLevel(String skillId, int currentLevel) {
    final plan = state;
    if (plan == null) return;

    state = plan.copyWith(
      skills:
          plan.skills.map((skill) {
            if (skill.id == skillId) {
              return skill.copyWith(currentLevel: currentLevel);
            }
            return skill;
          }).toList(),
    );
  }

  void advanceLearning(String learningId, double delta) {
    final plan = state;
    if (plan == null) return;

    state = plan.copyWith(
      learning:
          plan.learning.map((item) {
            if (item.id == learningId) {
              return item.copyWith(progress: item.progress + delta);
            }
            return item;
          }).toList(),
    );
  }

  void completeLearning(String learningId) {
    final plan = state;
    if (plan == null) return;

    state = plan.copyWith(
      learning:
          plan.learning.map((item) {
            if (item.id == learningId) {
              return item.copyWith(
                progress: 1,
                status: EmployeeLearningStatus.completed,
              );
            }
            return item;
          }).toList(),
    );
  }

  EmployeeLearningAssignment addLearning(
    EmployeeLearningAssignmentDraft draft,
  ) {
    final plan = state;
    if (plan == null) {
      throw StateError('Employee development plan is unavailable');
    }

    final assignment = draft.toAssignment(id: _nextLearningId(plan));
    state = plan.copyWith(learning: [assignment, ...plan.learning]);
    return assignment;
  }

  void renewCertification(String certificationId, DateTime expiryDate) {
    final plan = state;
    if (plan == null) return;

    state = plan.copyWith(
      certifications:
          plan.certifications.map((certification) {
            if (certification.id == certificationId) {
              return certification.copyWith(
                expiryDate: DateTime(
                  expiryDate.year,
                  expiryDate.month,
                  expiryDate.day,
                ),
                status: EmployeeCertificationStatus.active,
              );
            }
            return certification;
          }).toList(),
    );
  }

  String _nextLearningId(EmployeeDevelopmentPlan plan) {
    return 'EDL-${plan.employeeId}-${(plan.learning.length + 1).toString().padLeft(3, '0')}';
  }
}

class EmployeeLearningAssignmentDraftNotifier
    extends StateNotifier<EmployeeLearningAssignmentDraft?> {
  final EmployeeLearningAssignmentDraft? _initialDraft;

  EmployeeLearningAssignmentDraftNotifier(super.state) : _initialDraft = state;

  void setTitle(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(title: value);
  }

  void setProvider(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(provider: value);
  }

  void setSkillFocus(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(skillFocus: value);
  }

  void setDueDate(DateTime value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(
      dueDate: DateTime(value.year, value.month, value.day),
    );
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
