enum CompanyPolicyStatus { ready, draft, needsReview }

extension CompanyPolicyStatusLabels on CompanyPolicyStatus {
  String get label {
    switch (this) {
      case CompanyPolicyStatus.ready:
        return 'Ready';
      case CompanyPolicyStatus.draft:
        return 'Draft';
      case CompanyPolicyStatus.needsReview:
        return 'Needs review';
    }
  }
}

class CompanyPolicySetting {
  final String id;
  final String name;
  final String ownerName;
  final String linkedModule;
  final String cadence;
  final CompanyPolicyStatus status;
  final String nextAction;

  const CompanyPolicySetting({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.linkedModule,
    required this.cadence,
    required this.status,
    required this.nextAction,
  });

  bool get requiresAttention => status != CompanyPolicyStatus.ready;

  CompanyPolicySetting copyWith({
    String? id,
    String? name,
    String? ownerName,
    String? linkedModule,
    String? cadence,
    CompanyPolicyStatus? status,
    String? nextAction,
  }) {
    return CompanyPolicySetting(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      linkedModule: linkedModule ?? this.linkedModule,
      cadence: cadence ?? this.cadence,
      status: status ?? this.status,
      nextAction: nextAction ?? this.nextAction,
    );
  }
}
