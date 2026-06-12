enum EmployeeSkillStatus {
  gap('Gap'),
  building('Building'),
  proficient('Proficient'),
  verified('Verified');

  final String label;

  const EmployeeSkillStatus(this.label);
}

enum EmployeeLearningStatus {
  assigned('Assigned'),
  inProgress('In progress'),
  completed('Completed'),
  overdue('Overdue');

  final String label;

  const EmployeeLearningStatus(this.label);
}

enum EmployeeCertificationStatus {
  active('Active'),
  expiring('Expiring'),
  expired('Expired'),
  missing('Missing');

  final String label;

  const EmployeeCertificationStatus(this.label);
}

class EmployeeSkillTarget {
  final String id;
  final String employeeId;
  final String skill;
  final String mentor;
  final int currentLevel;
  final int targetLevel;
  final EmployeeSkillStatus status;

  const EmployeeSkillTarget({
    required this.id,
    required this.employeeId,
    required this.skill,
    required this.mentor,
    required this.currentLevel,
    required this.targetLevel,
    required this.status,
  });

  int get levelGap => (targetLevel - currentLevel).clamp(0, 5).toInt();

  double get progress {
    if (targetLevel <= 0) return 0;
    return (currentLevel / targetLevel).clamp(0, 1).toDouble();
  }

  bool get needsAttention => status == EmployeeSkillStatus.gap || levelGap > 1;

  EmployeeSkillTarget copyWith({
    int? currentLevel,
    EmployeeSkillStatus? status,
  }) {
    final resolvedLevel =
        (currentLevel ?? this.currentLevel).clamp(1, 5).toInt();
    final resolvedStatus =
        status ??
        (resolvedLevel >= targetLevel
            ? EmployeeSkillStatus.verified
            : resolvedLevel >= targetLevel - 1
            ? EmployeeSkillStatus.building
            : this.status);

    return EmployeeSkillTarget(
      id: id,
      employeeId: employeeId,
      skill: skill,
      mentor: mentor,
      currentLevel: resolvedLevel,
      targetLevel: targetLevel,
      status: resolvedStatus,
    );
  }
}

class EmployeeLearningAssignment {
  final String id;
  final String employeeId;
  final String title;
  final String provider;
  final String skillFocus;
  final DateTime dueDate;
  final double progress;
  final EmployeeLearningStatus status;

  const EmployeeLearningAssignment({
    required this.id,
    required this.employeeId,
    required this.title,
    required this.provider,
    required this.skillFocus,
    required this.dueDate,
    required this.progress,
    required this.status,
  });

  bool get isComplete => status == EmployeeLearningStatus.completed;

  bool isOverdue(DateTime asOfDate) {
    return !isComplete && dueDate.isBefore(_dateOnly(asOfDate));
  }

  EmployeeLearningAssignment copyWith({
    double? progress,
    EmployeeLearningStatus? status,
  }) {
    final resolvedProgress = progress?.clamp(0, 1).toDouble() ?? this.progress;
    final resolvedStatus =
        status ??
        (resolvedProgress >= 1
            ? EmployeeLearningStatus.completed
            : resolvedProgress > 0
            ? EmployeeLearningStatus.inProgress
            : this.status);

    return EmployeeLearningAssignment(
      id: id,
      employeeId: employeeId,
      title: title,
      provider: provider,
      skillFocus: skillFocus,
      dueDate: dueDate,
      progress: resolvedProgress,
      status: resolvedStatus,
    );
  }
}

class EmployeeCertificationTarget {
  final String id;
  final String employeeId;
  final String name;
  final String authority;
  final DateTime expiryDate;
  final EmployeeCertificationStatus status;

  const EmployeeCertificationTarget({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.authority,
    required this.expiryDate,
    required this.status,
  });

  bool isExpired(DateTime asOfDate) {
    return status == EmployeeCertificationStatus.expired ||
        expiryDate.isBefore(_dateOnly(asOfDate));
  }

  bool isExpiringSoon(DateTime asOfDate) {
    if (isExpired(asOfDate)) return false;
    return !expiryDate.isAfter(
          _dateOnly(asOfDate).add(const Duration(days: 45)),
        ) ||
        status == EmployeeCertificationStatus.expiring;
  }

  bool needsAttention(DateTime asOfDate) {
    return status == EmployeeCertificationStatus.missing ||
        isExpired(asOfDate) ||
        isExpiringSoon(asOfDate);
  }

  EmployeeCertificationTarget copyWith({
    DateTime? expiryDate,
    EmployeeCertificationStatus? status,
  }) {
    return EmployeeCertificationTarget(
      id: id,
      employeeId: employeeId,
      name: name,
      authority: authority,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
    );
  }
}

class EmployeeDevelopmentPlan {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeSkillTarget> skills;
  final List<EmployeeLearningAssignment> learning;
  final List<EmployeeCertificationTarget> certifications;

  const EmployeeDevelopmentPlan({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.skills,
    required this.learning,
    required this.certifications,
  });

  EmployeeDevelopmentPlan copyWith({
    List<EmployeeSkillTarget>? skills,
    List<EmployeeLearningAssignment>? learning,
    List<EmployeeCertificationTarget>? certifications,
  }) {
    return EmployeeDevelopmentPlan(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      skills: skills ?? this.skills,
      learning: learning ?? this.learning,
      certifications: certifications ?? this.certifications,
    );
  }

  int get skillGapCount => skills.where((skill) => skill.needsAttention).length;

  int get learningDueCount {
    return learning.where((item) => item.isOverdue(asOfDate)).length;
  }

  int get activeLearningCount {
    return learning.where((item) => !item.isComplete).length;
  }

  int get certificationRiskCount {
    return certifications
        .where((certification) => certification.needsAttention(asOfDate))
        .length;
  }

  double get averageLearningCompletion {
    if (learning.isEmpty) return 0;
    return learning.fold<double>(0, (total, item) => total + item.progress) /
        learning.length;
  }

  String get nextAction {
    if (certificationRiskCount > 0) {
      return 'Resolve $certificationRiskCount certification risk${certificationRiskCount == 1 ? '' : 's'}.';
    }
    if (learningDueCount > 0) {
      return 'Follow up on $learningDueCount overdue learning item${learningDueCount == 1 ? '' : 's'}.';
    }
    if (skillGapCount > 0) {
      return 'Coach $skillGapCount priority skill gap${skillGapCount == 1 ? '' : 's'}.';
    }
    return 'Development plan is on track.';
  }
}

class EmployeeLearningAssignmentDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String title;
  final String provider;
  final String skillFocus;
  final DateTime? dueDate;

  const EmployeeLearningAssignmentDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.title,
    required this.provider,
    required this.skillFocus,
    required this.dueDate,
  });

  EmployeeLearningAssignmentDraft copyWith({
    String? title,
    String? provider,
    String? skillFocus,
    DateTime? dueDate,
  }) {
    return EmployeeLearningAssignmentDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      title: title ?? this.title,
      provider: provider ?? this.provider,
      skillFocus: skillFocus ?? this.skillFocus,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Learning title must be at least 4 characters');
    }
    if (provider.trim().length < 3) {
      errors.add('Learning provider is required');
    }
    if (skillFocus.trim().length < 3) {
      errors.add('Skill focus is required');
    }
    if (dueDate == null) {
      errors.add('Due date is required');
    } else if (dueDate!.isBefore(asOfDate)) {
      errors.add('Due date cannot be before today');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var complete = 0;
    if (title.trim().length >= 4) complete++;
    if (provider.trim().length >= 3) complete++;
    if (skillFocus.trim().length >= 3) complete++;
    if (dueDate != null && !dueDate!.isBefore(asOfDate)) complete++;
    return complete / 4;
  }

  EmployeeLearningAssignment toAssignment({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeLearningAssignment(
      id: id,
      employeeId: employeeId,
      title: title.trim(),
      provider: provider.trim(),
      skillFocus: skillFocus.trim(),
      dueDate: dueDate!,
      progress: 0,
      status: EmployeeLearningStatus.assigned,
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
