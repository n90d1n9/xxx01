import 'employee_directory_roster_payroll_import_models.dart';

/// Types of import validation items that require payroll attention.
enum EmployeeDirectoryRosterPayrollValidationItemType {
  attentionProfile,
  payrollImpact,
}

/// Human-readable labels for payroll import validation item types.
extension EmployeeDirectoryRosterPayrollValidationItemTypeLabel
    on EmployeeDirectoryRosterPayrollValidationItemType {
  String get label {
    return switch (this) {
      EmployeeDirectoryRosterPayrollValidationItemType.attentionProfile =>
        'Attention profile',
      EmployeeDirectoryRosterPayrollValidationItemType.payrollImpact =>
        'Payroll impact',
    };
  }
}

/// One payroll import validation item derived from a staged import packet.
class EmployeeDirectoryRosterPayrollValidationItem {
  final String id;
  final EmployeeDirectoryRosterPayrollValidationItemType type;
  final String title;
  final String detail;
  final int count;

  const EmployeeDirectoryRosterPayrollValidationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.detail,
    required this.count,
  });

  String get typeLabel => type.label;
}

/// Captures payroll validation input before approving an import packet.
class EmployeeDirectoryRosterPayrollValidationDraft {
  final String validatedBy;
  final String validationNote;
  final bool confirmFileLoaded;
  final bool confirmValidationItems;
  final bool confirmPayrollRunControls;

  const EmployeeDirectoryRosterPayrollValidationDraft({
    this.validatedBy = '',
    this.validationNote = '',
    this.confirmFileLoaded = false,
    this.confirmValidationItems = false,
    this.confirmPayrollRunControls = false,
  });

  bool get hasInput {
    return validatedBy.trim().isNotEmpty ||
        validationNote.trim().isNotEmpty ||
        confirmFileLoaded ||
        confirmValidationItems ||
        confirmPayrollRunControls;
  }

  EmployeeDirectoryRosterPayrollValidationDraft copyWith({
    String? validatedBy,
    String? validationNote,
    bool? confirmFileLoaded,
    bool? confirmValidationItems,
    bool? confirmPayrollRunControls,
  }) {
    return EmployeeDirectoryRosterPayrollValidationDraft(
      validatedBy: validatedBy ?? this.validatedBy,
      validationNote: validationNote ?? this.validationNote,
      confirmFileLoaded: confirmFileLoaded ?? this.confirmFileLoaded,
      confirmValidationItems:
          confirmValidationItems ?? this.confirmValidationItems,
      confirmPayrollRunControls:
          confirmPayrollRunControls ?? this.confirmPayrollRunControls,
    );
  }
}

/// Immutable audit record for an approved payroll import validation.
class EmployeeDirectoryRosterPayrollValidationRecord {
  final String id;
  final String batchId;
  final String batchLabel;
  final String releaseVersion;
  final String controlFileName;
  final String validatedBy;
  final String validationNote;
  final DateTime validatedAt;
  final int loadedProfileCount;
  final int validationItemCount;
  final int payrollImpactCount;

  const EmployeeDirectoryRosterPayrollValidationRecord({
    required this.id,
    required this.batchId,
    required this.batchLabel,
    required this.releaseVersion,
    required this.controlFileName,
    required this.validatedBy,
    required this.validationNote,
    required this.validatedAt,
    required this.loadedProfileCount,
    required this.validationItemCount,
    required this.payrollImpactCount,
  });

  String get summaryLabel {
    return '$loadedProfileCount loaded profile'
        '${loadedProfileCount == 1 ? '' : 's'} approved with '
        '$validationItemCount validation item'
        '${validationItemCount == 1 ? '' : 's'} reviewed.';
  }
}

/// Validates whether a staged payroll import packet can be approved.
class EmployeeDirectoryRosterPayrollValidationReview {
  final EmployeeDirectoryRosterPayrollImportBatch? latestBatch;
  final EmployeeDirectoryRosterPayrollValidationDraft draft;
  final List<EmployeeDirectoryRosterPayrollValidationRecord> records;
  final List<EmployeeDirectoryRosterPayrollValidationItem> items;
  final List<String> errors;

  const EmployeeDirectoryRosterPayrollValidationReview({
    required this.latestBatch,
    required this.draft,
    required this.records,
    required this.items,
    required this.errors,
  });

  factory EmployeeDirectoryRosterPayrollValidationReview.fromState({
    required EmployeeDirectoryRosterPayrollImportReview importReview,
    required EmployeeDirectoryRosterPayrollValidationDraft draft,
    required List<EmployeeDirectoryRosterPayrollValidationRecord> records,
  }) {
    final batch = importReview.latestReleaseBatch;
    final items = _itemsFor(batch);
    final review = EmployeeDirectoryRosterPayrollValidationReview(
      latestBatch: batch,
      draft: draft,
      records: records,
      items: items,
      errors: const [],
    );

    return EmployeeDirectoryRosterPayrollValidationReview(
      latestBatch: batch,
      draft: draft,
      records: records,
      items: items,
      errors: _validate(review),
    );
  }

  EmployeeDirectoryRosterPayrollValidationRecord? get latestRecord {
    return records.isEmpty ? null : records.first;
  }

  EmployeeDirectoryRosterPayrollValidationRecord? get latestBatchRecord {
    final batch = latestBatch;
    if (batch == null) return null;
    for (final record in records) {
      if (record.batchId == batch.id) return record;
    }
    return null;
  }

  bool get hasBatch => latestBatch != null;

  bool get isValidated => latestBatchRecord != null;

  bool get canValidate => errors.isEmpty;

  int get validationItemCount {
    return items.fold<int>(0, (total, item) => total + item.count);
  }

  bool get hasValidationItems => validationItemCount > 0;

  String get statusLabel {
    if (!hasBatch) return 'No packet';
    if (isValidated) return 'Validated';
    if (!draft.confirmFileLoaded) return 'File load';
    if (hasValidationItems && !draft.confirmValidationItems) {
      return 'Item review';
    }
    return canValidate ? 'Ready' : 'Draft';
  }

  double get completionRatio {
    final checks = [
      hasBatch,
      !isValidated,
      draft.confirmFileLoaded,
      !hasValidationItems || draft.confirmValidationItems,
      draft.confirmPayrollRunControls,
      draft.validatedBy.trim().length >= 3,
      draft.validationNote.trim().length >= 16,
    ];
    return checks.where((check) => check).length / checks.length;
  }

  EmployeeDirectoryRosterPayrollValidationRecord toRecord({
    required String id,
    required DateTime validatedAt,
  }) {
    if (!canValidate) {
      throw StateError(errors.first);
    }

    final batch = latestBatch!;
    return EmployeeDirectoryRosterPayrollValidationRecord(
      id: id,
      batchId: batch.id,
      batchLabel: batch.batchLabel,
      releaseVersion: batch.releaseVersion,
      controlFileName: batch.controlFileName,
      validatedBy: draft.validatedBy.trim(),
      validationNote: draft.validationNote.trim(),
      validatedAt: validatedAt,
      loadedProfileCount: batch.includedProfileCount,
      validationItemCount: validationItemCount,
      payrollImpactCount: batch.payrollImpactCount,
    );
  }
}

List<EmployeeDirectoryRosterPayrollValidationItem> _itemsFor(
  EmployeeDirectoryRosterPayrollImportBatch? batch,
) {
  if (batch == null) return const [];

  return [
    if (batch.attentionProfileCount > 0)
      EmployeeDirectoryRosterPayrollValidationItem(
        id: 'attention-profiles',
        type: EmployeeDirectoryRosterPayrollValidationItemType.attentionProfile,
        title: 'Review payroll attention profiles',
        detail:
            '${batch.attentionProfileCount} non-active roster profile'
            '${batch.attentionProfileCount == 1 ? '' : 's'} loaded in the import.',
        count: batch.attentionProfileCount,
      ),
    if (batch.payrollImpactCount > 0)
      EmployeeDirectoryRosterPayrollValidationItem(
        id: 'payroll-impact',
        type: EmployeeDirectoryRosterPayrollValidationItemType.payrollImpact,
        title: 'Confirm payroll-impacting roster changes',
        detail:
            '${batch.payrollImpactCount} payroll-impacting change'
            '${batch.payrollImpactCount == 1 ? '' : 's'} included in the staged file.',
        count: batch.payrollImpactCount,
      ),
  ];
}

List<String> _validate(EmployeeDirectoryRosterPayrollValidationReview review) {
  final errors = <String>[];
  final draft = review.draft;

  if (!review.hasBatch) {
    errors.add('Stage payroll import packet before validation.');
  }
  if (review.isValidated) {
    errors.add('Latest payroll import packet is already validated.');
  }
  if (!draft.confirmFileLoaded) {
    errors.add('Confirm payroll import file loaded successfully.');
  }
  if (review.hasValidationItems && !draft.confirmValidationItems) {
    errors.add(
      'Review ${review.validationItemCount} payroll import validation item'
      '${review.validationItemCount == 1 ? '' : 's'} before approval.',
    );
  }
  if (!draft.confirmPayrollRunControls) {
    errors.add('Confirm payroll run controls before approval.');
  }
  if (draft.validatedBy.trim().length < 3) {
    errors.add('Validation owner is required.');
  }
  if (draft.validationNote.trim().length < 16) {
    errors.add('Validation note must be at least 16 characters.');
  }

  return errors;
}
