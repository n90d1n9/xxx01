import 'audit_close_signoff_models.dart';

/// Captures a final payroll audit close attestation.
class AuditCloseAttestationRecord {
  final String signedBy;
  final String role;
  final DateTime signedAt;
  final String note;

  const AuditCloseAttestationRecord({
    required this.signedBy,
    required this.role,
    required this.signedAt,
    required this.note,
  });

  bool get isComplete {
    return signedBy.trim().isNotEmpty &&
        role.trim().isNotEmpty &&
        note.trim().length >= 16;
  }
}

/// Stores editable input before an audit close attestation is signed.
class AuditCloseAttestationDraft {
  final String signedBy;
  final String role;
  final DateTime signedAt;
  final String note;

  const AuditCloseAttestationDraft({
    required this.signedBy,
    required this.role,
    required this.signedAt,
    required this.note,
  });

  factory AuditCloseAttestationDraft.empty(DateTime signedAt) {
    return AuditCloseAttestationDraft(
      signedBy: 'Payroll Controller',
      role: 'Payroll Controller',
      signedAt: signedAt,
      note: 'Audit close package reviewed and approved for final retention.',
    );
  }

  AuditCloseAttestationDraft copyWith({
    String? signedBy,
    String? role,
    DateTime? signedAt,
    String? note,
  }) {
    return AuditCloseAttestationDraft(
      signedBy: signedBy ?? this.signedBy,
      role: role ?? this.role,
      signedAt: signedAt ?? this.signedAt,
      note: note ?? this.note,
    );
  }

  List<String> get validationErrors {
    return [
      if (signedBy.trim().isEmpty) 'Enter a signer',
      if (role.trim().isEmpty) 'Enter a signer role',
      if (note.trim().length < 16) 'Enter an attestation note',
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  AuditCloseAttestationRecord toRecord() {
    return AuditCloseAttestationRecord(
      signedBy: signedBy.trim(),
      role: role.trim(),
      signedAt: signedAt,
      note: note.trim(),
    );
  }
}

/// Summarizes whether final payroll audit attestation can be captured.
class AuditCloseAttestationSummary {
  final String periodLabel;
  final AuditCloseSignoffSummary signoff;
  final AuditCloseAttestationDraft draft;
  final AuditCloseAttestationRecord? record;

  const AuditCloseAttestationSummary({
    required this.periodLabel,
    required this.signoff,
    required this.draft,
    required this.record,
  });

  bool get isSigned => record?.isComplete == true;

  bool get canSign => signoff.canSignOff && !isSigned;

  bool get canReopen => isSigned;

  String get statusLabel {
    if (isSigned) return 'Signed';
    if (signoff.canSignOff) return 'Ready';
    return 'Blocked';
  }

  String get nextAction {
    if (isSigned) {
      return 'Audit close signed by ${record!.signedBy} as ${record!.role}.';
    }
    if (!signoff.canSignOff) return signoff.nextAction;
    return 'Capture final audit close attestation.';
  }
}
