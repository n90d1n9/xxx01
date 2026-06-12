enum EmployeeHrCaseType {
  inquiry('Inquiry'),
  employeeRelations('Employee relations'),
  performance('Performance'),
  accommodation('Accommodation'),
  payroll('Payroll'),
  benefits('Benefits'),
  documents('Documents'),
  onboarding('Onboarding'),
  grievance('Grievance'),
  policy('Policy');

  final String label;

  const EmployeeHrCaseType(this.label);
}

enum EmployeeHrCasePriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  final String label;

  const EmployeeHrCasePriority(this.label);
}

enum EmployeeHrCaseStatus {
  open('Open'),
  inProgress('In progress'),
  pendingEmployee('Pending employee'),
  resolved('Resolved'),
  archived('Archived');

  final String label;

  const EmployeeHrCaseStatus(this.label);
}

enum EmployeeHrCaseConfidentiality {
  standard('Standard'),
  sensitive('Sensitive'),
  restricted('Restricted');

  final String label;

  const EmployeeHrCaseConfidentiality(this.label);
}

class EmployeeHrCaseRecord {
  final String id;
  final String employeeId;
  final EmployeeHrCaseType type;
  final String title;
  final String owner;
  final DateTime openedAt;
  final DateTime followUpDate;
  final EmployeeHrCaseStatus status;
  final EmployeeHrCasePriority priority;
  final EmployeeHrCaseConfidentiality confidentiality;
  final String summary;

  const EmployeeHrCaseRecord({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.title,
    required this.owner,
    required this.openedAt,
    required this.followUpDate,
    required this.status,
    required this.priority,
    required this.confidentiality,
    required this.summary,
  });

  bool get isOpen {
    return status == EmployeeHrCaseStatus.open ||
        status == EmployeeHrCaseStatus.inProgress ||
        status == EmployeeHrCaseStatus.pendingEmployee;
  }

  bool get isHighPriority {
    return priority == EmployeeHrCasePriority.high ||
        priority == EmployeeHrCasePriority.critical;
  }

  bool isOverdue(DateTime asOfDate) {
    return isOpen && followUpDate.isBefore(_dateOnly(asOfDate));
  }

  bool needsAttention(DateTime asOfDate) {
    return isOpen && (isHighPriority || isOverdue(asOfDate));
  }

  EmployeeHrCaseRecord copyWith({
    DateTime? followUpDate,
    EmployeeHrCaseStatus? status,
    EmployeeHrCasePriority? priority,
  }) {
    return EmployeeHrCaseRecord(
      id: id,
      employeeId: employeeId,
      type: type,
      title: title,
      owner: owner,
      openedAt: openedAt,
      followUpDate: followUpDate ?? this.followUpDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      confidentiality: confidentiality,
      summary: summary,
    );
  }
}

class EmployeeHrCaseNote {
  final String id;
  final String employeeId;
  final String caseId;
  final String author;
  final DateTime createdAt;
  final String body;
  final bool confidential;

  const EmployeeHrCaseNote({
    required this.id,
    required this.employeeId,
    required this.caseId,
    required this.author,
    required this.createdAt,
    required this.body,
    required this.confidential,
  });
}

class EmployeeHrCaseLog {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeHrCaseRecord> cases;
  final List<EmployeeHrCaseNote> notes;

  const EmployeeHrCaseLog({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.cases,
    required this.notes,
  });

  EmployeeHrCaseLog copyWith({
    List<EmployeeHrCaseRecord>? cases,
    List<EmployeeHrCaseNote>? notes,
  }) {
    return EmployeeHrCaseLog(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      cases: cases ?? this.cases,
      notes: notes ?? this.notes,
    );
  }

  int get openCaseCount => cases.where((item) => item.isOpen).length;

  int get overdueFollowUpCount {
    return cases.where((item) => item.isOverdue(asOfDate)).length;
  }

  int get highPriorityCount {
    return cases.where((item) => item.isOpen && item.isHighPriority).length;
  }

  int get restrictedCaseCount {
    return cases
        .where(
          (item) =>
              item.confidentiality == EmployeeHrCaseConfidentiality.restricted,
        )
        .length;
  }

  int get confidentialNoteCount {
    return notes.where((note) => note.confidential).length;
  }

  int get attentionCount => overdueFollowUpCount + highPriorityCount;

  List<EmployeeHrCaseRecord> get sortedCases {
    final sorted = [...cases]..sort((a, b) {
      final aAttention = a.needsAttention(asOfDate);
      final bAttention = b.needsAttention(asOfDate);
      if (aAttention != bAttention) return aAttention ? -1 : 1;
      if (a.isOpen != b.isOpen) return a.isOpen ? -1 : 1;
      return a.followUpDate.compareTo(b.followUpDate);
    });
    return sorted;
  }

  List<EmployeeHrCaseNote> get latestNotes {
    final sorted = [...notes]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(4).toList();
  }

  String get nextAction {
    if (overdueFollowUpCount > 0) {
      return 'Follow up on $overdueFollowUpCount overdue HR case${overdueFollowUpCount == 1 ? '' : 's'}.';
    }
    if (highPriorityCount > 0) {
      return 'Prioritize $highPriorityCount high-priority HR case${highPriorityCount == 1 ? '' : 's'}.';
    }
    if (openCaseCount > 0) {
      return 'Keep $openCaseCount HR case${openCaseCount == 1 ? '' : 's'} moving.';
    }
    return 'HR case log is current.';
  }
}

class EmployeeHrCaseIntakeDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String title;
  final String summary;
  final String owner;
  final EmployeeHrCaseType type;
  final EmployeeHrCasePriority priority;
  final EmployeeHrCaseConfidentiality confidentiality;
  final DateTime? followUpDate;

  const EmployeeHrCaseIntakeDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.title,
    required this.summary,
    required this.owner,
    required this.type,
    required this.priority,
    required this.confidentiality,
    required this.followUpDate,
  });

  EmployeeHrCaseIntakeDraft copyWith({
    String? title,
    String? summary,
    String? owner,
    EmployeeHrCaseType? type,
    EmployeeHrCasePriority? priority,
    EmployeeHrCaseConfidentiality? confidentiality,
    DateTime? followUpDate,
  }) {
    return EmployeeHrCaseIntakeDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      owner: owner ?? this.owner,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      confidentiality: confidentiality ?? this.confidentiality,
      followUpDate: followUpDate ?? this.followUpDate,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    final due = followUpDate == null ? null : _dateOnly(followUpDate!);

    if (title.trim().length < 6) {
      errors.add('Case title must be at least 6 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Assign a case owner');
    }
    if (summary.trim().length < 14) {
      errors.add('Case summary must be at least 14 characters');
    }
    if (due == null) {
      errors.add('Select a follow-up date');
    } else if (due.isBefore(_dateOnly(asOfDate))) {
      errors.add('Follow-up date cannot be in the past');
    }

    return errors;
  }

  bool get isReadyToCreate => validationErrors.isEmpty;

  double get completionRatio {
    var complete = 0;
    if (title.trim().length >= 6) complete++;
    if (owner.trim().length >= 3) complete++;
    if (summary.trim().length >= 14) complete++;
    if (followUpDate != null && !_dateOnly(followUpDate!).isBefore(asOfDate)) {
      complete++;
    }
    return complete / 4;
  }

  EmployeeHrCaseRecord toRecord({required String id}) {
    if (!isReadyToCreate) {
      throw StateError(validationErrors.first);
    }

    return EmployeeHrCaseRecord(
      id: id,
      employeeId: employeeId,
      type: type,
      title: title.trim(),
      owner: owner.trim(),
      openedAt: _dateOnly(asOfDate),
      followUpDate: _dateOnly(followUpDate!),
      status: EmployeeHrCaseStatus.open,
      priority: priority,
      confidentiality: confidentiality,
      summary: summary.trim(),
    );
  }
}

class EmployeeHrCaseNoteDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String caseId;
  final String author;
  final String body;
  final bool confidential;

  const EmployeeHrCaseNoteDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.caseId,
    required this.author,
    required this.body,
    required this.confidential,
  });

  EmployeeHrCaseNoteDraft copyWith({
    String? caseId,
    String? author,
    String? body,
    bool? confidential,
  }) {
    return EmployeeHrCaseNoteDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      caseId: caseId ?? this.caseId,
      author: author ?? this.author,
      body: body ?? this.body,
      confidential: confidential ?? this.confidential,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (caseId.trim().isEmpty) {
      errors.add('Select a case');
    }
    if (author.trim().length < 3) {
      errors.add('Author is required');
    }
    if (body.trim().length < 12) {
      errors.add('Case note must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var complete = 0;
    if (caseId.trim().isNotEmpty) complete++;
    if (author.trim().length >= 3) complete++;
    if (body.trim().length >= 12) complete++;
    return complete / 3;
  }

  EmployeeHrCaseNote toNote({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeHrCaseNote(
      id: id,
      employeeId: employeeId,
      caseId: caseId,
      author: author.trim(),
      createdAt: asOfDate,
      body: body.trim(),
      confidential: confidential,
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
