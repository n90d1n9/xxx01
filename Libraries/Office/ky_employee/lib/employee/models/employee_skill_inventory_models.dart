enum EmployeeSkillInventoryCategory {
  technical('Technical'),
  domain('Domain'),
  leadership('Leadership'),
  compliance('Compliance'),
  operations('Operations');

  final String label;

  const EmployeeSkillInventoryCategory(this.label);
}

enum EmployeeSkillCriticality {
  critical('Critical'),
  core('Core'),
  growth('Growth'),
  optional('Optional');

  final String label;

  const EmployeeSkillCriticality(this.label);
}

enum EmployeeSkillVerificationStatus {
  evidenceDue('Evidence due'),
  inReview('In review'),
  verified('Verified'),
  expired('Expired'),
  waived('Waived');

  final String label;

  const EmployeeSkillVerificationStatus(this.label);
}

enum EmployeeSkillEvidenceType {
  managerObservation('Manager observation'),
  projectDelivery('Project delivery'),
  assessment('Assessment'),
  certification('Certification'),
  peerReview('Peer review');

  final String label;

  const EmployeeSkillEvidenceType(this.label);
}

class EmployeeSkillRecord {
  final String id;
  final String employeeId;
  final EmployeeSkillInventoryCategory category;
  final String skillName;
  final String owner;
  final int currentLevel;
  final int requiredLevel;
  final EmployeeSkillCriticality criticality;
  final EmployeeSkillVerificationStatus status;
  final DateTime? lastVerifiedDate;
  final DateTime nextReviewDate;
  final int evidenceCount;
  final String evidenceSummary;

  const EmployeeSkillRecord({
    required this.id,
    required this.employeeId,
    required this.category,
    required this.skillName,
    required this.owner,
    required this.currentLevel,
    required this.requiredLevel,
    required this.criticality,
    required this.status,
    required this.lastVerifiedDate,
    required this.nextReviewDate,
    required this.evidenceCount,
    required this.evidenceSummary,
  });

  int get levelGap => (requiredLevel - currentLevel).clamp(0, 5).toInt();

  double get coverageRatio {
    if (requiredLevel <= 0) return 0;
    return (currentLevel / requiredLevel).clamp(0, 1).toDouble();
  }

  bool get isVerified => status == EmployeeSkillVerificationStatus.verified;

  bool get isWaived => status == EmployeeSkillVerificationStatus.waived;

  bool get hasCriticalGap {
    return criticality == EmployeeSkillCriticality.critical && levelGap > 0;
  }

  bool isReviewOverdue(DateTime asOfDate) {
    if (isWaived) return false;
    return nextReviewDate.isBefore(_dateOnly(asOfDate));
  }

  bool needsAttention(DateTime asOfDate) {
    return status == EmployeeSkillVerificationStatus.evidenceDue ||
        status == EmployeeSkillVerificationStatus.expired ||
        status == EmployeeSkillVerificationStatus.inReview ||
        hasCriticalGap ||
        isReviewOverdue(asOfDate);
  }

  EmployeeSkillRecord copyWith({
    String? owner,
    int? currentLevel,
    int? requiredLevel,
    EmployeeSkillCriticality? criticality,
    EmployeeSkillVerificationStatus? status,
    DateTime? lastVerifiedDate,
    DateTime? nextReviewDate,
    int? evidenceCount,
    String? evidenceSummary,
  }) {
    return EmployeeSkillRecord(
      id: id,
      employeeId: employeeId,
      category: category,
      skillName: skillName,
      owner: owner ?? this.owner,
      currentLevel: (currentLevel ?? this.currentLevel).clamp(1, 5).toInt(),
      requiredLevel: (requiredLevel ?? this.requiredLevel).clamp(1, 5).toInt(),
      criticality: criticality ?? this.criticality,
      status: status ?? this.status,
      lastVerifiedDate: lastVerifiedDate ?? this.lastVerifiedDate,
      nextReviewDate: _dateOnly(nextReviewDate ?? this.nextReviewDate),
      evidenceCount: (evidenceCount ?? this.evidenceCount).clamp(0, 999),
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
    );
  }
}

class EmployeeSkillInventoryProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeSkillRecord> records;

  const EmployeeSkillInventoryProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.records,
  });

  EmployeeSkillInventoryProfile copyWith({List<EmployeeSkillRecord>? records}) {
    return EmployeeSkillInventoryProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      records: records ?? this.records,
    );
  }

  List<EmployeeSkillRecord> get priorityRecords {
    final sorted = [...records];
    sorted.sort((a, b) {
      final aAttention = a.needsAttention(asOfDate);
      final bAttention = b.needsAttention(asOfDate);
      if (aAttention != bAttention) return aAttention ? -1 : 1;

      final criticalityCompare = _criticalityRank(
        a.criticality,
      ).compareTo(_criticalityRank(b.criticality));
      if (criticalityCompare != 0) return criticalityCompare;

      final gapCompare = b.levelGap.compareTo(a.levelGap);
      if (gapCompare != 0) return gapCompare;

      return a.nextReviewDate.compareTo(b.nextReviewDate);
    });
    return sorted;
  }

  int get verifiedCount {
    return records.where((record) => record.isVerified).length;
  }

  int get criticalGapCount {
    return records.where((record) => record.hasCriticalGap).length;
  }

  int get evidenceDueCount {
    return records
        .where(
          (record) =>
              record.status == EmployeeSkillVerificationStatus.evidenceDue,
        )
        .length;
  }

  int get reviewDueCount {
    return records.where((record) => record.isReviewOverdue(asOfDate)).length;
  }

  int get attentionCount {
    return records.where((record) => record.needsAttention(asOfDate)).length;
  }

  double get coverageRatio {
    if (records.isEmpty) return 0;
    return records.fold<double>(
          0,
          (total, record) => total + record.coverageRatio,
        ) /
        records.length;
  }

  String get nextAction {
    if (criticalGapCount > 0) {
      return 'Close $criticalGapCount critical skill gap${criticalGapCount == 1 ? '' : 's'}.';
    }
    if (reviewDueCount > 0) {
      return 'Review $reviewDueCount overdue skill record${reviewDueCount == 1 ? '' : 's'}.';
    }
    if (evidenceDueCount > 0) {
      return 'Collect evidence for $evidenceDueCount skill record${evidenceDueCount == 1 ? '' : 's'}.';
    }
    return 'Skill inventory is verified and current.';
  }
}

class EmployeeSkillEvidenceDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String skillName;
  final EmployeeSkillInventoryCategory category;
  final EmployeeSkillEvidenceType evidenceType;
  final String verifier;
  final String evidenceSummary;
  final int observedLevel;
  final int requiredLevel;
  final EmployeeSkillCriticality criticality;
  final DateTime? nextReviewDate;

  const EmployeeSkillEvidenceDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.skillName,
    required this.category,
    required this.evidenceType,
    required this.verifier,
    required this.evidenceSummary,
    required this.observedLevel,
    required this.requiredLevel,
    required this.criticality,
    required this.nextReviewDate,
  });

  EmployeeSkillEvidenceDraft copyWith({
    String? skillName,
    EmployeeSkillInventoryCategory? category,
    EmployeeSkillEvidenceType? evidenceType,
    String? verifier,
    String? evidenceSummary,
    int? observedLevel,
    int? requiredLevel,
    EmployeeSkillCriticality? criticality,
    DateTime? nextReviewDate,
  }) {
    return EmployeeSkillEvidenceDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      skillName: skillName ?? this.skillName,
      category: category ?? this.category,
      evidenceType: evidenceType ?? this.evidenceType,
      verifier: verifier ?? this.verifier,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      observedLevel: (observedLevel ?? this.observedLevel).clamp(1, 5).toInt(),
      requiredLevel: (requiredLevel ?? this.requiredLevel).clamp(1, 5).toInt(),
      criticality: criticality ?? this.criticality,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (skillName.trim().length < 3) {
      errors.add('Skill name must be at least 3 characters');
    }
    if (verifier.trim().length < 3) {
      errors.add('Verifier is required');
    }
    if (evidenceSummary.trim().length < 10) {
      errors.add('Evidence summary must be at least 10 characters');
    }
    if (nextReviewDate == null) {
      errors.add('Next review date is required');
    } else if (nextReviewDate!.isBefore(asOfDate)) {
      errors.add('Next review date cannot be before today');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var complete = 0;
    if (skillName.trim().length >= 3) complete++;
    if (verifier.trim().length >= 3) complete++;
    if (evidenceSummary.trim().length >= 10) complete++;
    if (nextReviewDate != null && !nextReviewDate!.isBefore(asOfDate)) {
      complete++;
    }
    return complete / 4;
  }

  EmployeeSkillRecord toRecord({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeSkillRecord(
      id: id,
      employeeId: employeeId,
      category: category,
      skillName: skillName.trim(),
      owner: verifier.trim(),
      currentLevel: observedLevel,
      requiredLevel: requiredLevel,
      criticality: criticality,
      status: EmployeeSkillVerificationStatus.inReview,
      lastVerifiedDate: null,
      nextReviewDate: _dateOnly(nextReviewDate!),
      evidenceCount: 1,
      evidenceSummary: '${evidenceType.label}: ${evidenceSummary.trim()}',
    );
  }
}

int _criticalityRank(EmployeeSkillCriticality criticality) {
  return switch (criticality) {
    EmployeeSkillCriticality.critical => 0,
    EmployeeSkillCriticality.core => 1,
    EmployeeSkillCriticality.growth => 2,
    EmployeeSkillCriticality.optional => 3,
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
