enum EmployeeAssetType {
  laptop('Laptop'),
  phone('Phone'),
  badge('Badge'),
  monitor('Monitor'),
  software('Software');

  final String label;

  const EmployeeAssetType(this.label);
}

enum EmployeeAssetStatus {
  active('Active'),
  provisioning('Provisioning'),
  dueReturn('Due return'),
  returned('Returned'),
  lost('Lost');

  final String label;

  const EmployeeAssetStatus(this.label);
}

enum EmployeeAssetCondition {
  newIssue('New'),
  good('Good'),
  repairNeeded('Repair needed'),
  replacementDue('Replacement due');

  final String label;

  const EmployeeAssetCondition(this.label);
}

enum EmployeeAccessScope {
  productivity('Productivity'),
  engineering('Engineering'),
  finance('Finance'),
  hris('HRIS'),
  admin('Admin');

  final String label;

  const EmployeeAccessScope(this.label);
}

enum EmployeeAccessStatus {
  requested('Requested'),
  active('Active'),
  reviewDue('Review due'),
  revoked('Revoked');

  final String label;

  const EmployeeAccessStatus(this.label);
}

class EmployeeAssetRecord {
  final String id;
  final String employeeId;
  final EmployeeAssetType type;
  final String label;
  final String assetTag;
  final String owner;
  final DateTime issuedAt;
  final DateTime? returnDueAt;
  final EmployeeAssetCondition condition;
  final EmployeeAssetStatus status;

  const EmployeeAssetRecord({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.label,
    required this.assetTag,
    required this.owner,
    required this.issuedAt,
    required this.returnDueAt,
    required this.condition,
    required this.status,
  });

  bool get isActive => status == EmployeeAssetStatus.active;

  bool get isPending => status == EmployeeAssetStatus.provisioning;

  bool isReturnDue(DateTime asOfDate) {
    final returnDue = returnDueAt;
    if (returnDue == null || status == EmployeeAssetStatus.returned) {
      return false;
    }
    return !returnDue.isAfter(
      _dateOnly(asOfDate).add(const Duration(days: 14)),
    );
  }

  bool needsAttention(DateTime asOfDate) {
    return status == EmployeeAssetStatus.provisioning ||
        status == EmployeeAssetStatus.dueReturn ||
        status == EmployeeAssetStatus.lost ||
        condition == EmployeeAssetCondition.repairNeeded ||
        condition == EmployeeAssetCondition.replacementDue ||
        isReturnDue(asOfDate);
  }

  EmployeeAssetRecord copyWith({
    DateTime? returnDueAt,
    EmployeeAssetCondition? condition,
    EmployeeAssetStatus? status,
  }) {
    return EmployeeAssetRecord(
      id: id,
      employeeId: employeeId,
      type: type,
      label: label,
      assetTag: assetTag,
      owner: owner,
      issuedAt: issuedAt,
      returnDueAt: returnDueAt ?? this.returnDueAt,
      condition: condition ?? this.condition,
      status: status ?? this.status,
    );
  }
}

class EmployeeAccessGrant {
  final String id;
  final String employeeId;
  final String systemName;
  final EmployeeAccessScope scope;
  final String owner;
  final DateTime grantedAt;
  final DateTime reviewDueAt;
  final EmployeeAccessStatus status;

  const EmployeeAccessGrant({
    required this.id,
    required this.employeeId,
    required this.systemName,
    required this.scope,
    required this.owner,
    required this.grantedAt,
    required this.reviewDueAt,
    required this.status,
  });

  bool get isActive => status == EmployeeAccessStatus.active;

  bool needsReview(DateTime asOfDate) {
    if (status == EmployeeAccessStatus.requested ||
        status == EmployeeAccessStatus.reviewDue) {
      return true;
    }
    if (status == EmployeeAccessStatus.revoked) {
      return false;
    }
    return !reviewDueAt.isAfter(
      _dateOnly(asOfDate).add(const Duration(days: 7)),
    );
  }

  EmployeeAccessGrant copyWith({
    DateTime? reviewDueAt,
    EmployeeAccessStatus? status,
  }) {
    return EmployeeAccessGrant(
      id: id,
      employeeId: employeeId,
      systemName: systemName,
      scope: scope,
      owner: owner,
      grantedAt: grantedAt,
      reviewDueAt: reviewDueAt ?? this.reviewDueAt,
      status: status ?? this.status,
    );
  }
}

class EmployeeAssetAccessProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeAssetRecord> assets;
  final List<EmployeeAccessGrant> accessGrants;

  const EmployeeAssetAccessProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.assets,
    required this.accessGrants,
  });

  EmployeeAssetAccessProfile copyWith({
    List<EmployeeAssetRecord>? assets,
    List<EmployeeAccessGrant>? accessGrants,
  }) {
    return EmployeeAssetAccessProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      assets: assets ?? this.assets,
      accessGrants: accessGrants ?? this.accessGrants,
    );
  }

  int get activeAssetCount => assets.where((asset) => asset.isActive).length;

  int get pendingAssetCount => assets.where((asset) => asset.isPending).length;

  int get assetAttentionCount {
    return assets.where((asset) => asset.needsAttention(asOfDate)).length;
  }

  int get returnDueCount {
    return assets.where((asset) => asset.isReturnDue(asOfDate)).length;
  }

  int get activeAccessCount {
    return accessGrants.where((grant) => grant.isActive).length;
  }

  int get accessReviewCount {
    return accessGrants.where((grant) => grant.needsReview(asOfDate)).length;
  }

  int get attentionCount => assetAttentionCount + accessReviewCount;

  String get nextAction {
    if (pendingAssetCount > 0) {
      return 'Complete $pendingAssetCount asset provisioning item${pendingAssetCount == 1 ? '' : 's'}.';
    }
    if (returnDueCount > 0) {
      return 'Collect $returnDueCount asset return${returnDueCount == 1 ? '' : 's'}.';
    }
    if (accessReviewCount > 0) {
      return 'Review $accessReviewCount access grant${accessReviewCount == 1 ? '' : 's'}.';
    }
    if (assetAttentionCount > 0) {
      return 'Resolve $assetAttentionCount asset exception${assetAttentionCount == 1 ? '' : 's'}.';
    }
    return 'Assets and access are current.';
  }
}

class EmployeeAssetAssignmentDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeAssetType type;
  final String label;
  final String assetTag;
  final String owner;

  const EmployeeAssetAssignmentDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.label,
    required this.assetTag,
    required this.owner,
  });

  EmployeeAssetAssignmentDraft copyWith({
    EmployeeAssetType? type,
    String? label,
    String? assetTag,
    String? owner,
  }) {
    return EmployeeAssetAssignmentDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      label: label ?? this.label,
      assetTag: assetTag ?? this.assetTag,
      owner: owner ?? this.owner,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (label.trim().length < 3) {
      errors.add('Asset label must be at least 3 characters');
    }
    if (assetTag.trim().length < 3) {
      errors.add('Asset tag is required');
    }
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var complete = 0;
    if (label.trim().length >= 3) complete++;
    if (assetTag.trim().length >= 3) complete++;
    if (owner.trim().length >= 3) complete++;
    return complete / 3;
  }

  EmployeeAssetRecord toAsset({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeAssetRecord(
      id: id,
      employeeId: employeeId,
      type: type,
      label: label.trim(),
      assetTag: assetTag.trim(),
      owner: owner.trim(),
      issuedAt: asOfDate,
      returnDueAt: null,
      condition: EmployeeAssetCondition.newIssue,
      status: EmployeeAssetStatus.provisioning,
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
