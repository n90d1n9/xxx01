import 'employee_document_vault_models.dart';

/// Readiness state for one required employee document vault requirement.
enum EmployeeDocumentVaultCoverageStatus {
  complete('Complete'),
  reviewNeeded('Review needed'),
  uploadNeeded('Upload needed'),
  expiringSoon('Expiring soon'),
  expired('Expired'),
  missing('Missing');

  final String label;

  const EmployeeDocumentVaultCoverageStatus(this.label);
}

/// Required document rule used to evaluate employee document vault coverage.
class EmployeeDocumentVaultCoverageRequirement {
  final String id;
  final EmployeeDocumentVaultCategory category;
  final String label;
  final String owner;
  final EmployeeDocumentVaultAccess access;
  final String description;

  const EmployeeDocumentVaultCoverageRequirement({
    required this.id,
    required this.category,
    required this.label,
    required this.owner,
    required this.access,
    required this.description,
  });
}

/// Coverage result for one required employee document vault requirement.
class EmployeeDocumentVaultCoverageItem {
  final EmployeeDocumentVaultCoverageRequirement requirement;
  final EmployeeDocumentVaultRecord? record;
  final EmployeeDocumentVaultCoverageStatus status;

  const EmployeeDocumentVaultCoverageItem({
    required this.requirement,
    required this.record,
    required this.status,
  });

  String get label => requirement.label;

  String get statusLabel => status.label;

  String get owner => record?.owner ?? requirement.owner;

  EmployeeDocumentVaultAccess get access =>
      record?.access ?? requirement.access;

  EmployeeDocumentVaultCategory get category => requirement.category;

  bool get isComplete => status == EmployeeDocumentVaultCoverageStatus.complete;

  bool get needsAttention => !isComplete;

  bool get canCreateRequest {
    return switch (status) {
      EmployeeDocumentVaultCoverageStatus.missing ||
      EmployeeDocumentVaultCoverageStatus.uploadNeeded ||
      EmployeeDocumentVaultCoverageStatus.expiringSoon ||
      EmployeeDocumentVaultCoverageStatus.expired => true,
      EmployeeDocumentVaultCoverageStatus.reviewNeeded ||
      EmployeeDocumentVaultCoverageStatus.complete => false,
    };
  }

  String get requestActionLabel {
    return switch (status) {
      EmployeeDocumentVaultCoverageStatus.expiringSoon ||
      EmployeeDocumentVaultCoverageStatus.expired => 'Request renewal',
      EmployeeDocumentVaultCoverageStatus.missing ||
      EmployeeDocumentVaultCoverageStatus.uploadNeeded => 'Request document',
      EmployeeDocumentVaultCoverageStatus.reviewNeeded ||
      EmployeeDocumentVaultCoverageStatus.complete => 'No request needed',
    };
  }

  String get actionLabel {
    return switch (status) {
      EmployeeDocumentVaultCoverageStatus.complete =>
        'Requirement covered by ${record!.title}.',
      EmployeeDocumentVaultCoverageStatus.reviewNeeded =>
        'Review uploaded document before it counts as covered.',
      EmployeeDocumentVaultCoverageStatus.uploadNeeded =>
        'Request upload or replacement from the employee.',
      EmployeeDocumentVaultCoverageStatus.expiringSoon =>
        'Renew document before the current evidence expires.',
      EmployeeDocumentVaultCoverageStatus.expired =>
        'Replace expired evidence before the next HR checkpoint.',
      EmployeeDocumentVaultCoverageStatus.missing =>
        'Collect this required document for a complete HRIS profile.',
    };
  }
}

/// Per-employee coverage summary for required document vault categories.
class EmployeeDocumentVaultCoverageProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeDocumentVaultCoverageItem> items;

  const EmployeeDocumentVaultCoverageProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.items,
  });

  factory EmployeeDocumentVaultCoverageProfile.fromVault(
    EmployeeDocumentVaultProfile profile,
  ) {
    final requirements = employeeDocumentVaultCoverageRequirementsFor(profile);
    return EmployeeDocumentVaultCoverageProfile(
      employeeId: profile.employeeId,
      employeeName: profile.employeeName,
      asOfDate: profile.asOfDate,
      items: [
        for (final requirement in requirements)
          _coverageItemFor(requirement: requirement, profile: profile),
      ],
    );
  }

  int get requiredCount => items.length;

  int get completeCount => items.where((item) => item.isComplete).length;

  int get attentionCount {
    return items.where((item) => item.needsAttention).length;
  }

  int get missingCount {
    return items
        .where(
          (item) => item.status == EmployeeDocumentVaultCoverageStatus.missing,
        )
        .length;
  }

  int get expiringCount {
    return items
        .where(
          (item) =>
              item.status == EmployeeDocumentVaultCoverageStatus.expiringSoon,
        )
        .length;
  }

  int get restrictedCount {
    return items
        .where((item) => item.access == EmployeeDocumentVaultAccess.restricted)
        .length;
  }

  double get completionRatio {
    if (requiredCount == 0) return 1;
    return completeCount / requiredCount;
  }

  String get completionLabel => '${(completionRatio * 100).round()}% covered';

  List<EmployeeDocumentVaultCoverageItem> get prioritizedItems {
    final sorted = [...items]..sort((a, b) {
      final statusCompare = _coverageStatusRank(
        a.status,
      ).compareTo(_coverageStatusRank(b.status));
      if (statusCompare != 0) return statusCompare;
      return a.label.compareTo(b.label);
    });
    return sorted;
  }

  String get nextAction {
    final expired = _count(EmployeeDocumentVaultCoverageStatus.expired);
    if (expired > 0) {
      return 'Replace $expired expired required document${expired == 1 ? '' : 's'}.';
    }
    if (missingCount > 0) {
      return 'Collect $missingCount required document${missingCount == 1 ? '' : 's'}.';
    }
    final uploads = _count(EmployeeDocumentVaultCoverageStatus.uploadNeeded);
    if (uploads > 0) {
      return 'Request $uploads document upload${uploads == 1 ? '' : 's'}.';
    }
    final review = _count(EmployeeDocumentVaultCoverageStatus.reviewNeeded);
    if (review > 0) {
      return 'Review $review required document${review == 1 ? '' : 's'}.';
    }
    if (expiringCount > 0) {
      return 'Renew $expiringCount required document${expiringCount == 1 ? '' : 's'}.';
    }
    return 'Required document coverage is complete.';
  }

  int _count(EmployeeDocumentVaultCoverageStatus status) {
    return items.where((item) => item.status == status).length;
  }
}

/// Builds document vault coverage requirements from the employee's tracked data.
List<EmployeeDocumentVaultCoverageRequirement>
employeeDocumentVaultCoverageRequirementsFor(
  EmployeeDocumentVaultProfile profile,
) {
  final categories = profile.records.map((record) => record.category).toSet();
  return [
    _identityRequirement,
    _contractRequirement,
    _payrollTaxRequirement,
    _complianceRequirement,
    if (categories.contains(EmployeeDocumentVaultCategory.workAuthorization))
      _workAuthorizationRequirement,
  ];
}

EmployeeDocumentVaultCoverageItem _coverageItemFor({
  required EmployeeDocumentVaultCoverageRequirement requirement,
  required EmployeeDocumentVaultProfile profile,
}) {
  final records =
      profile.records
          .where(
            (record) =>
                record.category == requirement.category &&
                record.status != EmployeeDocumentVaultStatus.archived,
          )
          .toList();
  if (records.isEmpty) {
    return EmployeeDocumentVaultCoverageItem(
      requirement: requirement,
      record: null,
      status: EmployeeDocumentVaultCoverageStatus.missing,
    );
  }

  records.sort((a, b) {
    final rankCompare = _recordCoverageRank(
      a,
      profile.asOfDate,
    ).compareTo(_recordCoverageRank(b, profile.asOfDate));
    if (rankCompare != 0) return rankCompare;
    return b.uploadedAt.compareTo(a.uploadedAt);
  });
  final record = records.first;

  return EmployeeDocumentVaultCoverageItem(
    requirement: requirement,
    record: record,
    status: _statusFor(record, profile.asOfDate),
  );
}

EmployeeDocumentVaultCoverageStatus _statusFor(
  EmployeeDocumentVaultRecord record,
  DateTime asOfDate,
) {
  if (record.isExpired(asOfDate)) {
    return EmployeeDocumentVaultCoverageStatus.expired;
  }
  if (record.isExpiringSoon(asOfDate)) {
    return EmployeeDocumentVaultCoverageStatus.expiringSoon;
  }
  return switch (record.status) {
    EmployeeDocumentVaultStatus.verified =>
      EmployeeDocumentVaultCoverageStatus.complete,
    EmployeeDocumentVaultStatus.pendingReview =>
      EmployeeDocumentVaultCoverageStatus.reviewNeeded,
    EmployeeDocumentVaultStatus.needsUpload ||
    EmployeeDocumentVaultStatus
        .rejected => EmployeeDocumentVaultCoverageStatus.uploadNeeded,
    EmployeeDocumentVaultStatus.expiringSoon =>
      EmployeeDocumentVaultCoverageStatus.expiringSoon,
    EmployeeDocumentVaultStatus.expired =>
      EmployeeDocumentVaultCoverageStatus.expired,
    EmployeeDocumentVaultStatus.archived =>
      EmployeeDocumentVaultCoverageStatus.missing,
  };
}

int _recordCoverageRank(EmployeeDocumentVaultRecord record, DateTime asOfDate) {
  return _coverageStatusRank(_statusFor(record, asOfDate));
}

int _coverageStatusRank(EmployeeDocumentVaultCoverageStatus status) {
  return switch (status) {
    EmployeeDocumentVaultCoverageStatus.expired => 0,
    EmployeeDocumentVaultCoverageStatus.missing => 1,
    EmployeeDocumentVaultCoverageStatus.uploadNeeded => 2,
    EmployeeDocumentVaultCoverageStatus.reviewNeeded => 3,
    EmployeeDocumentVaultCoverageStatus.expiringSoon => 4,
    EmployeeDocumentVaultCoverageStatus.complete => 5,
  };
}

const _identityRequirement = EmployeeDocumentVaultCoverageRequirement(
  id: 'identity',
  category: EmployeeDocumentVaultCategory.identity,
  label: 'Identity evidence',
  owner: 'People Operations',
  access: EmployeeDocumentVaultAccess.employeeVisible,
  description: 'Government identity evidence required for employee records.',
);

const _contractRequirement = EmployeeDocumentVaultCoverageRequirement(
  id: 'contract',
  category: EmployeeDocumentVaultCategory.contract,
  label: 'Employment agreement',
  owner: 'People Operations',
  access: EmployeeDocumentVaultAccess.hrOnly,
  description: 'Signed employment agreement or active contract addendum.',
);

const _payrollTaxRequirement = EmployeeDocumentVaultCoverageRequirement(
  id: 'payroll-tax',
  category: EmployeeDocumentVaultCategory.payrollTax,
  label: 'Payroll and tax evidence',
  owner: 'Payroll Operations',
  access: EmployeeDocumentVaultAccess.hrOnly,
  description: 'Tax, bank, or payroll eligibility evidence for pay runs.',
);

const _complianceRequirement = EmployeeDocumentVaultCoverageRequirement(
  id: 'compliance',
  category: EmployeeDocumentVaultCategory.compliance,
  label: 'Policy acknowledgement',
  owner: 'People Operations',
  access: EmployeeDocumentVaultAccess.employeeVisible,
  description: 'Required employee policy acknowledgement for audit coverage.',
);

const _workAuthorizationRequirement = EmployeeDocumentVaultCoverageRequirement(
  id: 'work-authorization',
  category: EmployeeDocumentVaultCategory.workAuthorization,
  label: 'Work authorization',
  owner: 'People Operations',
  access: EmployeeDocumentVaultAccess.restricted,
  description: 'Restricted right-to-work evidence for location compliance.',
);
