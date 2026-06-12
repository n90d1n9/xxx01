enum AccountingPolicyFramework { sakIndonesia, sakEntitasPrivat, sakEmkm, ifrs }

extension AccountingPolicyFrameworkLabel on AccountingPolicyFramework {
  String get label {
    switch (this) {
      case AccountingPolicyFramework.sakIndonesia:
        return 'SAK Indonesia';
      case AccountingPolicyFramework.sakEntitasPrivat:
        return 'SAK Entitas Privat';
      case AccountingPolicyFramework.sakEmkm:
        return 'SAK EMKM';
      case AccountingPolicyFramework.ifrs:
        return 'IFRS';
    }
  }

  String get frameworkName {
    switch (this) {
      case AccountingPolicyFramework.sakIndonesia:
        return 'SAK Indonesia (IFRS-converged)';
      case AccountingPolicyFramework.sakEntitasPrivat:
        return 'SAK Entitas Privat';
      case AccountingPolicyFramework.sakEmkm:
        return 'SAK EMKM';
      case AccountingPolicyFramework.ifrs:
        return 'IFRS Accounting Standards';
    }
  }

  String get standardReference {
    switch (this) {
      case AccountingPolicyFramework.sakIndonesia:
        return 'PSAK 201';
      case AccountingPolicyFramework.sakEntitasPrivat:
        return 'SAK EP';
      case AccountingPolicyFramework.sakEmkm:
        return 'SAK EMKM';
      case AccountingPolicyFramework.ifrs:
        return 'IAS 1 / IFRS';
    }
  }

  String get description {
    switch (this) {
      case AccountingPolicyFramework.sakIndonesia:
        return 'General-purpose Indonesian financial statements using IFRS-converged SAK presentation concepts.';
      case AccountingPolicyFramework.sakEntitasPrivat:
        return 'Private-entity reporting basis for entities without public accountability.';
      case AccountingPolicyFramework.sakEmkm:
        return 'Simplified Indonesian micro, small, and medium entity reporting basis.';
      case AccountingPolicyFramework.ifrs:
        return 'IFRS-style reporting basis for cross-border management or group reporting.';
    }
  }
}

enum AccountingPolicyCloseCadence { monthly, quarterly, annual }

extension AccountingPolicyCloseCadenceLabel on AccountingPolicyCloseCadence {
  String get label {
    switch (this) {
      case AccountingPolicyCloseCadence.monthly:
        return 'Monthly';
      case AccountingPolicyCloseCadence.quarterly:
        return 'Quarterly';
      case AccountingPolicyCloseCadence.annual:
        return 'Annual';
    }
  }
}

enum AccountingPolicyReviewStatus { ready, review }

extension AccountingPolicyReviewStatusLabel on AccountingPolicyReviewStatus {
  String get label {
    switch (this) {
      case AccountingPolicyReviewStatus.ready:
        return 'Ready';
      case AccountingPolicyReviewStatus.review:
        return 'Review';
    }
  }
}

class AccountingPolicyProfile {
  final String entityName;
  final AccountingPolicyFramework framework;
  final String jurisdiction;
  final String functionalCurrency;
  final String presentationCurrency;
  final AccountingPolicyCloseCadence closeCadence;
  final bool accrualBasis;
  final bool requireComparatives;
  final bool ppnRegistered;
  final bool includeManagementAssertions;
  final DateTime? updatedAt;

  const AccountingPolicyProfile({
    required this.entityName,
    required this.framework,
    required this.jurisdiction,
    required this.functionalCurrency,
    required this.presentationCurrency,
    required this.closeCadence,
    required this.accrualBasis,
    required this.requireComparatives,
    required this.ppnRegistered,
    required this.includeManagementAssertions,
    required this.updatedAt,
  });

  factory AccountingPolicyProfile.fromJson(Map<String, dynamic> json) {
    return AccountingPolicyProfile(
      entityName: json['entityName'] as String? ?? 'Kaysir',
      framework: _frameworkFromJson(json['framework'] as String?),
      jurisdiction: json['jurisdiction'] as String? ?? 'Indonesia',
      functionalCurrency: json['functionalCurrency'] as String? ?? 'IDR',
      presentationCurrency: json['presentationCurrency'] as String? ?? 'IDR',
      closeCadence: _closeCadenceFromJson(json['closeCadence'] as String?),
      accrualBasis: json['accrualBasis'] as bool? ?? true,
      requireComparatives: json['requireComparatives'] as bool? ?? true,
      ppnRegistered: json['ppnRegistered'] as bool? ?? true,
      includeManagementAssertions:
          json['includeManagementAssertions'] as bool? ?? true,
      updatedAt: _dateTimeFromJson(json['updatedAt']) ?? DateTime.now(),
    );
  }

  String get frameworkName => framework.frameworkName;

  String get standardReference => framework.standardReference;

  bool get currencyTranslated => functionalCurrency != presentationCurrency;

  AccountingPolicyProfile copyWith({
    String? entityName,
    AccountingPolicyFramework? framework,
    String? jurisdiction,
    String? functionalCurrency,
    String? presentationCurrency,
    AccountingPolicyCloseCadence? closeCadence,
    bool? accrualBasis,
    bool? requireComparatives,
    bool? ppnRegistered,
    bool? includeManagementAssertions,
    DateTime? updatedAt,
  }) {
    return AccountingPolicyProfile(
      entityName: entityName ?? this.entityName,
      framework: framework ?? this.framework,
      jurisdiction: jurisdiction ?? this.jurisdiction,
      functionalCurrency: functionalCurrency ?? this.functionalCurrency,
      presentationCurrency: presentationCurrency ?? this.presentationCurrency,
      closeCadence: closeCadence ?? this.closeCadence,
      accrualBasis: accrualBasis ?? this.accrualBasis,
      requireComparatives: requireComparatives ?? this.requireComparatives,
      ppnRegistered: ppnRegistered ?? this.ppnRegistered,
      includeManagementAssertions:
          includeManagementAssertions ?? this.includeManagementAssertions,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': 1,
      'entityName': entityName,
      'framework': framework.name,
      'jurisdiction': jurisdiction,
      'functionalCurrency': functionalCurrency,
      'presentationCurrency': presentationCurrency,
      'closeCadence': closeCadence.name,
      'accrualBasis': accrualBasis,
      'requireComparatives': requireComparatives,
      'ppnRegistered': ppnRegistered,
      'includeManagementAssertions': includeManagementAssertions,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class AccountingPolicyReviewItem {
  final String id;
  final String title;
  final String description;
  final String reference;
  final AccountingPolicyReviewStatus status;

  const AccountingPolicyReviewItem({
    required this.id,
    required this.title,
    required this.description,
    required this.reference,
    required this.status,
  });
}

abstract final class AccountingPolicyProfiles {
  static const defaultProfile = AccountingPolicyProfile(
    entityName: 'Kaysir',
    framework: AccountingPolicyFramework.sakIndonesia,
    jurisdiction: 'Indonesia',
    functionalCurrency: 'IDR',
    presentationCurrency: 'IDR',
    closeCadence: AccountingPolicyCloseCadence.monthly,
    accrualBasis: true,
    requireComparatives: true,
    ppnRegistered: true,
    includeManagementAssertions: true,
    updatedAt: null,
  );
}

AccountingPolicyFramework _frameworkFromJson(String? value) {
  for (final framework in AccountingPolicyFramework.values) {
    if (framework.name == value) {
      return framework;
    }
  }
  return AccountingPolicyFramework.sakIndonesia;
}

AccountingPolicyCloseCadence _closeCadenceFromJson(String? value) {
  for (final cadence in AccountingPolicyCloseCadence.values) {
    if (cadence.name == value) {
      return cadence;
    }
  }
  return AccountingPolicyCloseCadence.monthly;
}

DateTime? _dateTimeFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value as String);
}
