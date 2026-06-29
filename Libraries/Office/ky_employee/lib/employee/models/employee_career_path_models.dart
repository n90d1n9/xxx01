enum EmployeeCareerReadiness {
  readyNow('Ready now'),
  readySoon('Ready soon'),
  developing('Developing'),
  exploratory('Exploratory');

  final String label;

  const EmployeeCareerReadiness(this.label);
}

enum EmployeeMobilityPreference {
  sameTeam('Same team'),
  crossFunctional('Cross-functional'),
  managerTrack('Manager track'),
  specialistTrack('Specialist track'),
  remoteFirst('Remote first');

  final String label;

  const EmployeeMobilityPreference(this.label);
}

enum EmployeeSuccessionCoverage {
  covered('Covered'),
  partial('Partial'),
  uncovered('Uncovered'),
  notCritical('Not critical');

  final String label;

  const EmployeeSuccessionCoverage(this.label);
}

enum EmployeeCareerMoveType {
  promotion('Promotion'),
  lateralMove('Lateral move'),
  stretchAssignment('Stretch assignment'),
  mentorship('Mentorship'),
  successionNomination('Succession nomination');

  final String label;

  const EmployeeCareerMoveType(this.label);
}

enum EmployeeCareerMoveStatus {
  proposed('Proposed'),
  approved('Approved'),
  active('Active'),
  completed('Completed'),
  declined('Declined');

  final String label;

  const EmployeeCareerMoveStatus(this.label);
}

class EmployeeCareerPathSnapshot {
  final String employeeId;
  final String employeeName;
  final String currentRole;
  final String targetRole;
  final String sponsor;
  final EmployeeCareerReadiness readiness;
  final EmployeeMobilityPreference mobilityPreference;
  final EmployeeSuccessionCoverage successionCoverage;
  final bool criticalRole;
  final DateTime lastTalentReviewAt;
  final DateTime nextReviewDate;

  const EmployeeCareerPathSnapshot({
    required this.employeeId,
    required this.employeeName,
    required this.currentRole,
    required this.targetRole,
    required this.sponsor,
    required this.readiness,
    required this.mobilityPreference,
    required this.successionCoverage,
    required this.criticalRole,
    required this.lastTalentReviewAt,
    required this.nextReviewDate,
  });

  bool get hasSuccessionGap {
    return criticalRole &&
        (successionCoverage == EmployeeSuccessionCoverage.uncovered ||
            successionCoverage == EmployeeSuccessionCoverage.partial);
  }

  bool isReviewDue(DateTime asOfDate) {
    return !nextReviewDate.isAfter(_dateOnly(asOfDate));
  }

  EmployeeCareerPathSnapshot copyWith({
    EmployeeCareerReadiness? readiness,
    EmployeeSuccessionCoverage? successionCoverage,
    DateTime? lastTalentReviewAt,
    DateTime? nextReviewDate,
  }) {
    return EmployeeCareerPathSnapshot(
      employeeId: employeeId,
      employeeName: employeeName,
      currentRole: currentRole,
      targetRole: targetRole,
      sponsor: sponsor,
      readiness: readiness ?? this.readiness,
      mobilityPreference: mobilityPreference,
      successionCoverage: successionCoverage ?? this.successionCoverage,
      criticalRole: criticalRole,
      lastTalentReviewAt: lastTalentReviewAt ?? this.lastTalentReviewAt,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    );
  }
}

class EmployeeCareerMoveRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeeCareerMoveType type;
  final String title;
  final String sponsor;
  final String targetRole;
  final DateTime targetDate;
  final EmployeeCareerMoveStatus status;
  final String summary;

  const EmployeeCareerMoveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.title,
    required this.sponsor,
    required this.targetRole,
    required this.targetDate,
    required this.status,
    required this.summary,
  });

  bool get canApprove => status == EmployeeCareerMoveStatus.proposed;

  bool get canActivate => status == EmployeeCareerMoveStatus.approved;

  bool get canComplete => status == EmployeeCareerMoveStatus.active;

  bool get canDecline =>
      status == EmployeeCareerMoveStatus.proposed ||
      status == EmployeeCareerMoveStatus.approved;

  EmployeeCareerMoveRequest copyWith({EmployeeCareerMoveStatus? status}) {
    return EmployeeCareerMoveRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      title: title,
      sponsor: sponsor,
      targetRole: targetRole,
      targetDate: targetDate,
      status: status ?? this.status,
      summary: summary,
    );
  }
}

class EmployeeCareerPathProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeCareerPathSnapshot path;
  final List<EmployeeCareerMoveRequest> moves;

  const EmployeeCareerPathProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.path,
    required this.moves,
  });

  EmployeeCareerPathProfile copyWith({
    EmployeeCareerPathSnapshot? path,
    List<EmployeeCareerMoveRequest>? moves,
  }) {
    return EmployeeCareerPathProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      path: path ?? this.path,
      moves: moves ?? this.moves,
    );
  }

  int get successionGapCount => path.hasSuccessionGap ? 1 : 0;

  int get reviewDueCount => path.isReviewDue(asOfDate) ? 1 : 0;

  int get proposedMoveCount {
    return moves
        .where((move) => move.status == EmployeeCareerMoveStatus.proposed)
        .length;
  }

  int get approvedMoveCount {
    return moves
        .where((move) => move.status == EmployeeCareerMoveStatus.approved)
        .length;
  }

  int get activeMoveCount {
    return moves
        .where((move) => move.status == EmployeeCareerMoveStatus.active)
        .length;
  }

  int get attentionCount {
    return successionGapCount +
        reviewDueCount +
        proposedMoveCount +
        approvedMoveCount +
        activeMoveCount;
  }

  String get nextAction {
    if (successionGapCount > 0) {
      return 'Close uncovered critical-role succession coverage.';
    }
    if (reviewDueCount > 0) {
      return 'Run talent review for ${path.targetRole}.';
    }
    if (approvedMoveCount > 0) {
      return 'Activate $approvedMoveCount approved career move${approvedMoveCount == 1 ? '' : 's'}.';
    }
    if (activeMoveCount > 0) {
      return 'Complete $activeMoveCount active career move${activeMoveCount == 1 ? '' : 's'}.';
    }
    if (proposedMoveCount > 0) {
      return 'Review $proposedMoveCount proposed career move${proposedMoveCount == 1 ? '' : 's'}.';
    }
    return 'Career path is current.';
  }
}

class EmployeeCareerMoveDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeCareerMoveType type;
  final String title;
  final String sponsor;
  final String targetRole;
  final DateTime targetDate;
  final String summary;

  const EmployeeCareerMoveDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.title,
    required this.sponsor,
    required this.targetRole,
    required this.targetDate,
    required this.summary,
  });

  EmployeeCareerMoveDraft copyWith({
    EmployeeCareerMoveType? type,
    String? title,
    String? sponsor,
    String? targetRole,
    DateTime? targetDate,
    String? summary,
  }) {
    return EmployeeCareerMoveDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      title: title ?? this.title,
      sponsor: sponsor ?? this.sponsor,
      targetRole: targetRole ?? this.targetRole,
      targetDate: targetDate ?? this.targetDate,
      summary: summary ?? this.summary,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Move title must be at least 4 characters');
    }
    if (sponsor.trim().length < 3) {
      errors.add('Sponsor is required');
    }
    if (targetRole.trim().length < 3) {
      errors.add('Target role is required');
    }
    if (targetDate.isBefore(asOfDate)) {
      errors.add('Target date cannot be before today');
    }
    if (summary.trim().length < 12) {
      errors.add('Move summary must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final complete =
        [
          title.trim().length >= 4,
          sponsor.trim().length >= 3,
          targetRole.trim().length >= 3,
          !targetDate.isBefore(asOfDate),
          summary.trim().length >= 12,
        ].where((item) => item).length;
    return complete / 5;
  }

  EmployeeCareerMoveRequest toRequest({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeCareerMoveRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      title: title.trim(),
      sponsor: sponsor.trim(),
      targetRole: targetRole.trim(),
      targetDate: targetDate,
      status: EmployeeCareerMoveStatus.proposed,
      summary: summary.trim(),
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
