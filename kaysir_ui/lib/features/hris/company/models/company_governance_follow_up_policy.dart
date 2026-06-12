import 'company_governance_owner_load.dart';

/// Configures governance owner follow-up timing by workload risk.
class CompanyGovernanceFollowUpPolicy {
  static const defaultPolicy = CompanyGovernanceFollowUpPolicy(
    criticalCadenceDays: 1,
    highCadenceDays: 2,
    steadyCadenceDays: 3,
  );

  final int criticalCadenceDays;
  final int highCadenceDays;
  final int steadyCadenceDays;

  const CompanyGovernanceFollowUpPolicy({
    required this.criticalCadenceDays,
    required this.highCadenceDays,
    required this.steadyCadenceDays,
  });

  int cadenceDaysFor(CompanyGovernanceOwnerLoadRisk risk) {
    switch (risk) {
      case CompanyGovernanceOwnerLoadRisk.critical:
        return criticalCadenceDays;
      case CompanyGovernanceOwnerLoadRisk.high:
        return highCadenceDays;
      case CompanyGovernanceOwnerLoadRisk.steady:
        return steadyCadenceDays;
    }
  }

  String cadenceLabelFor(CompanyGovernanceOwnerLoadRisk risk) {
    return _dayLabel(cadenceDaysFor(risk));
  }

  String get compactLabel {
    return 'Critical ${criticalCadenceDays}d, high ${highCadenceDays}d, '
        'steady ${steadyCadenceDays}d';
  }

  CompanyGovernanceFollowUpPolicy copyWith({
    int? criticalCadenceDays,
    int? highCadenceDays,
    int? steadyCadenceDays,
  }) {
    return CompanyGovernanceFollowUpPolicy(
      criticalCadenceDays: criticalCadenceDays ?? this.criticalCadenceDays,
      highCadenceDays: highCadenceDays ?? this.highCadenceDays,
      steadyCadenceDays: steadyCadenceDays ?? this.steadyCadenceDays,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CompanyGovernanceFollowUpPolicy &&
            other.criticalCadenceDays == criticalCadenceDays &&
            other.highCadenceDays == highCadenceDays &&
            other.steadyCadenceDays == steadyCadenceDays;
  }

  @override
  int get hashCode =>
      Object.hash(criticalCadenceDays, highCadenceDays, steadyCadenceDays);
}

/// Editable draft for validating governance follow-up SLA settings.
class CompanyGovernanceFollowUpPolicyDraft {
  static const minCadenceDays = 1;
  static const maxCadenceDays = 30;

  final String criticalCadenceDaysText;
  final String highCadenceDaysText;
  final String steadyCadenceDaysText;

  const CompanyGovernanceFollowUpPolicyDraft({
    required this.criticalCadenceDaysText,
    required this.highCadenceDaysText,
    required this.steadyCadenceDaysText,
  });

  factory CompanyGovernanceFollowUpPolicyDraft.fromPolicy(
    CompanyGovernanceFollowUpPolicy policy,
  ) {
    return CompanyGovernanceFollowUpPolicyDraft(
      criticalCadenceDaysText: '${policy.criticalCadenceDays}',
      highCadenceDaysText: '${policy.highCadenceDays}',
      steadyCadenceDaysText: '${policy.steadyCadenceDays}',
    );
  }

  CompanyGovernanceFollowUpPolicyDraft copyWith({
    String? criticalCadenceDaysText,
    String? highCadenceDaysText,
    String? steadyCadenceDaysText,
  }) {
    return CompanyGovernanceFollowUpPolicyDraft(
      criticalCadenceDaysText:
          criticalCadenceDaysText ?? this.criticalCadenceDaysText,
      highCadenceDaysText: highCadenceDaysText ?? this.highCadenceDaysText,
      steadyCadenceDaysText:
          steadyCadenceDaysText ?? this.steadyCadenceDaysText,
    );
  }

  CompanyGovernanceFollowUpPolicy toPolicy() {
    return CompanyGovernanceFollowUpPolicy(
      criticalCadenceDays: _parseCadenceDays(
        criticalCadenceDaysText,
        'Critical',
      ),
      highCadenceDays: _parseCadenceDays(highCadenceDaysText, 'High'),
      steadyCadenceDays: _parseCadenceDays(steadyCadenceDaysText, 'Steady'),
    );
  }

  static String? validateCadenceDays(String? value, String label) {
    return _cadenceError(value, label);
  }

  static int _parseCadenceDays(String value, String label) {
    final error = _cadenceError(value, label);
    if (error != null) {
      throw StateError(error);
    }
    return int.parse(value.trim());
  }

  static String? _cadenceError(String? value, String label) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '$label cadence is required';
    }

    final parsed = int.tryParse(trimmed);
    if (parsed == null) {
      return '$label cadence must be a whole number';
    }

    if (parsed < minCadenceDays || parsed > maxCadenceDays) {
      return '$label cadence must be between $minCadenceDays and '
          '$maxCadenceDays days';
    }

    return null;
  }
}

String _dayLabel(int days) {
  return '$days day${days == 1 ? '' : 's'}';
}
