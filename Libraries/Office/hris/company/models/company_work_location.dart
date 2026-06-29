enum CompanyWorkLocationType {
  headquarters,
  branchOffice,
  retailOutlet,
  fulfillmentHub,
  remoteHub,
}

enum CompanyWorkLocationStatus { open, onboarding, needsReview, closed }

enum CompanyWorkLocationIssue {
  missingEntity,
  missingAddress,
  missingCoverageOwner,
  attendanceNotLinked,
  overCapacity,
  needsReview,
  closed,
}

extension CompanyWorkLocationTypeLabels on CompanyWorkLocationType {
  String get label {
    switch (this) {
      case CompanyWorkLocationType.headquarters:
        return 'Headquarters';
      case CompanyWorkLocationType.branchOffice:
        return 'Branch office';
      case CompanyWorkLocationType.retailOutlet:
        return 'Retail outlet';
      case CompanyWorkLocationType.fulfillmentHub:
        return 'Fulfillment hub';
      case CompanyWorkLocationType.remoteHub:
        return 'Remote hub';
    }
  }
}

extension CompanyWorkLocationStatusLabels on CompanyWorkLocationStatus {
  String get label {
    switch (this) {
      case CompanyWorkLocationStatus.open:
        return 'Open';
      case CompanyWorkLocationStatus.onboarding:
        return 'Onboarding';
      case CompanyWorkLocationStatus.needsReview:
        return 'Needs review';
      case CompanyWorkLocationStatus.closed:
        return 'Closed';
    }
  }
}

extension CompanyWorkLocationIssueLabels on CompanyWorkLocationIssue {
  String get label {
    switch (this) {
      case CompanyWorkLocationIssue.missingEntity:
        return 'Assign entity';
      case CompanyWorkLocationIssue.missingAddress:
        return 'Add address';
      case CompanyWorkLocationIssue.missingCoverageOwner:
        return 'Assign owner';
      case CompanyWorkLocationIssue.attendanceNotLinked:
        return 'Link attendance';
      case CompanyWorkLocationIssue.overCapacity:
        return 'Review capacity';
      case CompanyWorkLocationIssue.needsReview:
        return 'Review location';
      case CompanyWorkLocationIssue.closed:
        return 'Resolve closure';
    }
  }
}

class CompanyWorkLocation {
  final String id;
  final String name;
  final String entityName;
  final CompanyWorkLocationType type;
  final String city;
  final String region;
  final String address;
  final String coverageOwner;
  final int capacity;
  final int assignedHeadcount;
  final bool attendancePolicyLinked;
  final CompanyWorkLocationStatus status;

  const CompanyWorkLocation({
    required this.id,
    required this.name,
    required this.entityName,
    required this.type,
    required this.city,
    required this.region,
    required this.address,
    required this.coverageOwner,
    required this.capacity,
    required this.assignedHeadcount,
    required this.attendancePolicyLinked,
    required this.status,
  });

  double get occupancyRatio {
    if (capacity <= 0) return 0;
    return (assignedHeadcount / capacity).clamp(0, 1.5);
  }

  List<CompanyWorkLocationIssue> get issues {
    return [
      if (entityName.trim().isEmpty) CompanyWorkLocationIssue.missingEntity,
      if (address.trim().isEmpty) CompanyWorkLocationIssue.missingAddress,
      if (coverageOwner.trim().isEmpty)
        CompanyWorkLocationIssue.missingCoverageOwner,
      if (!attendancePolicyLinked) CompanyWorkLocationIssue.attendanceNotLinked,
      if (capacity > 0 && assignedHeadcount > capacity)
        CompanyWorkLocationIssue.overCapacity,
      if (status == CompanyWorkLocationStatus.needsReview)
        CompanyWorkLocationIssue.needsReview,
      if (status == CompanyWorkLocationStatus.closed)
        CompanyWorkLocationIssue.closed,
    ];
  }

  bool get requiresAttention => issues.isNotEmpty;

  CompanyWorkLocation copyWith({
    String? id,
    String? name,
    String? entityName,
    CompanyWorkLocationType? type,
    String? city,
    String? region,
    String? address,
    String? coverageOwner,
    int? capacity,
    int? assignedHeadcount,
    bool? attendancePolicyLinked,
    CompanyWorkLocationStatus? status,
  }) {
    return CompanyWorkLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      city: city ?? this.city,
      region: region ?? this.region,
      address: address ?? this.address,
      coverageOwner: coverageOwner ?? this.coverageOwner,
      capacity: capacity ?? this.capacity,
      assignedHeadcount: assignedHeadcount ?? this.assignedHeadcount,
      attendancePolicyLinked:
          attendancePolicyLinked ?? this.attendancePolicyLinked,
      status: status ?? this.status,
    );
  }
}

class CompanyWorkLocationDraft {
  final String name;
  final String entityName;
  final CompanyWorkLocationType type;
  final String city;
  final String region;
  final String address;
  final String coverageOwner;
  final String capacityText;
  final String assignedHeadcountText;
  final bool attendancePolicyLinked;
  final CompanyWorkLocationStatus status;

  const CompanyWorkLocationDraft({
    required this.name,
    required this.entityName,
    required this.type,
    required this.city,
    required this.region,
    required this.address,
    required this.coverageOwner,
    required this.capacityText,
    required this.assignedHeadcountText,
    required this.attendancePolicyLinked,
    required this.status,
  });

  factory CompanyWorkLocationDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
  }) {
    return CompanyWorkLocationDraft(
      name: '',
      entityName: entityName,
      type: CompanyWorkLocationType.branchOffice,
      city: '',
      region: '',
      address: '',
      coverageOwner: '',
      capacityText: '',
      assignedHeadcountText: '',
      attendancePolicyLinked: true,
      status: CompanyWorkLocationStatus.onboarding,
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validatePositiveNumber(String? value, String label) {
    final count = int.tryParse(value?.trim() ?? '');
    if (count == null || count <= 0) return 'Enter $label';
    return null;
  }

  static String? validateZeroOrGreater(String? value) {
    final count = int.tryParse(value?.trim() ?? '');
    if (count == null || count < 0) return 'Enter zero or greater';
    return null;
  }

  int? get capacity => int.tryParse(capacityText.trim());

  int? get assignedHeadcount => int.tryParse(assignedHeadcountText.trim());

  bool get isReady {
    return name.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        city.trim().isNotEmpty &&
        region.trim().isNotEmpty &&
        address.trim().isNotEmpty &&
        coverageOwner.trim().isNotEmpty &&
        capacity != null &&
        capacity! > 0 &&
        assignedHeadcount != null &&
        assignedHeadcount! >= 0;
  }

  CompanyWorkLocation toLocation(String id) {
    if (!isReady) {
      throw StateError('Complete work location fields before saving.');
    }

    return CompanyWorkLocation(
      id: id,
      name: name.trim(),
      entityName: entityName.trim(),
      type: type,
      city: city.trim(),
      region: region.trim(),
      address: address.trim(),
      coverageOwner: coverageOwner.trim(),
      capacity: capacity!,
      assignedHeadcount: assignedHeadcount!,
      attendancePolicyLinked: attendancePolicyLinked,
      status: status,
    );
  }

  CompanyWorkLocationDraft copyWith({
    String? name,
    String? entityName,
    CompanyWorkLocationType? type,
    String? city,
    String? region,
    String? address,
    String? coverageOwner,
    String? capacityText,
    String? assignedHeadcountText,
    bool? attendancePolicyLinked,
    CompanyWorkLocationStatus? status,
  }) {
    return CompanyWorkLocationDraft(
      name: name ?? this.name,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      city: city ?? this.city,
      region: region ?? this.region,
      address: address ?? this.address,
      coverageOwner: coverageOwner ?? this.coverageOwner,
      capacityText: capacityText ?? this.capacityText,
      assignedHeadcountText:
          assignedHeadcountText ?? this.assignedHeadcountText,
      attendancePolicyLinked:
          attendancePolicyLinked ?? this.attendancePolicyLinked,
      status: status ?? this.status,
    );
  }
}
