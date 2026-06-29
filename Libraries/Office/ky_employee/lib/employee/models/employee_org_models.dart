enum EmployeeOrgRelationshipType {
  dottedLineManager('Dotted-line manager'),
  buddy('Buddy'),
  backupApprover('Backup approver'),
  matrixPartner('Matrix partner');

  final String label;

  const EmployeeOrgRelationshipType(this.label);
}

enum EmployeeOrgRelationshipStatus {
  pending('Pending'),
  active('Active'),
  archived('Archived');

  final String label;

  const EmployeeOrgRelationshipStatus(this.label);
}

enum EmployeeOrgRiskType {
  reportingLoop('Reporting loop'),
  managerSpan('Manager span'),
  watchlistReport('Watchlist report'),
  successionGap('Succession gap');

  final String label;

  const EmployeeOrgRiskType(this.label);
}

class EmployeeOrgPerson {
  final String id;
  final String name;
  final String position;
  final String department;
  final String location;
  final double performance;
  final bool watchlist;

  const EmployeeOrgPerson({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.location,
    required this.performance,
    required this.watchlist,
  });

  bool get highPerformer => performance >= 4.6;
}

class EmployeeOrgRelationshipRecord {
  final String id;
  final String employeeId;
  final EmployeeOrgRelationshipType type;
  final String relatedEmployeeName;
  final String owner;
  final DateTime createdAt;
  final EmployeeOrgRelationshipStatus status;
  final String reason;

  const EmployeeOrgRelationshipRecord({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.relatedEmployeeName,
    required this.owner,
    required this.createdAt,
    required this.status,
    required this.reason,
  });

  bool get canActivate => status == EmployeeOrgRelationshipStatus.pending;

  bool get isPending => status == EmployeeOrgRelationshipStatus.pending;

  bool get isActive => status == EmployeeOrgRelationshipStatus.active;

  EmployeeOrgRelationshipRecord copyWith({
    EmployeeOrgRelationshipStatus? status,
  }) {
    return EmployeeOrgRelationshipRecord(
      id: id,
      employeeId: employeeId,
      type: type,
      relatedEmployeeName: relatedEmployeeName,
      owner: owner,
      createdAt: createdAt,
      status: status ?? this.status,
      reason: reason,
    );
  }
}

class EmployeeOrgRiskSignal {
  final String id;
  final EmployeeOrgRiskType type;
  final String title;
  final String detail;

  const EmployeeOrgRiskSignal({
    required this.id,
    required this.type,
    required this.title,
    required this.detail,
  });
}

class EmployeeOrgProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeOrgPerson? manager;
  final List<EmployeeOrgPerson> chain;
  final List<EmployeeOrgPerson> peers;
  final List<EmployeeOrgPerson> directReports;
  final List<EmployeeOrgRelationshipRecord> relationships;
  final List<EmployeeOrgRiskSignal> risks;

  const EmployeeOrgProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.manager,
    required this.chain,
    required this.peers,
    required this.directReports,
    required this.relationships,
    required this.risks,
  });

  EmployeeOrgProfile copyWith({
    List<EmployeeOrgRelationshipRecord>? relationships,
    List<EmployeeOrgRiskSignal>? risks,
  }) {
    return EmployeeOrgProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      manager: manager,
      chain: chain,
      peers: peers,
      directReports: directReports,
      relationships: relationships ?? this.relationships,
      risks: risks ?? this.risks,
    );
  }

  int get directReportCount => directReports.length;

  int get peerCount => peers.length;

  int get pendingRelationshipCount {
    return relationships.where((relationship) => relationship.isPending).length;
  }

  int get activeRelationshipCount {
    return relationships.where((relationship) => relationship.isActive).length;
  }

  int get riskCount => risks.length;

  int get attentionCount => riskCount + pendingRelationshipCount;

  bool get hasActiveBackupApprover {
    return relationships.any(
      (relationship) =>
          relationship.type == EmployeeOrgRelationshipType.backupApprover &&
          relationship.isActive,
    );
  }

  String get nextAction {
    if (risks.any((risk) => risk.type == EmployeeOrgRiskType.reportingLoop)) {
      return 'Resolve reporting-line loop.';
    }
    if (pendingRelationshipCount > 0) {
      return 'Activate $pendingRelationshipCount pending org relationship${pendingRelationshipCount == 1 ? '' : 's'}.';
    }
    if (riskCount > 0) {
      return 'Review $riskCount organization risk signal${riskCount == 1 ? '' : 's'}.';
    }
    return 'Reporting profile is aligned.';
  }
}

class EmployeeOrgRelationshipDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeOrgRelationshipType type;
  final String relatedEmployeeName;
  final String owner;
  final String reason;

  const EmployeeOrgRelationshipDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.relatedEmployeeName,
    required this.owner,
    required this.reason,
  });

  EmployeeOrgRelationshipDraft copyWith({
    EmployeeOrgRelationshipType? type,
    String? relatedEmployeeName,
    String? owner,
    String? reason,
  }) {
    return EmployeeOrgRelationshipDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      relatedEmployeeName: relatedEmployeeName ?? this.relatedEmployeeName,
      owner: owner ?? this.owner,
      reason: reason ?? this.reason,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (relatedEmployeeName.trim().length < 3) {
      errors.add('Related employee is required');
    }
    if (relatedEmployeeName.trim() == employeeName.trim()) {
      errors.add('Related employee must be different');
    }
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    if (reason.trim().length < 12) {
      errors.add('Reason must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          relatedEmployeeName.trim().length >= 3 &&
              relatedEmployeeName.trim() != employeeName.trim(),
          owner.trim().length >= 3,
          reason.trim().length >= 12,
        ].where((item) => item).length;
    return completed / 3;
  }

  EmployeeOrgRelationshipRecord toRecord({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeOrgRelationshipRecord(
      id: id,
      employeeId: employeeId,
      type: type,
      relatedEmployeeName: relatedEmployeeName.trim(),
      owner: owner.trim(),
      createdAt: asOfDate,
      status: EmployeeOrgRelationshipStatus.pending,
      reason: reason.trim(),
    );
  }
}
