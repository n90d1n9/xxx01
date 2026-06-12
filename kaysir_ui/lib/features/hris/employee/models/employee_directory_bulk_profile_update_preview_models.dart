import 'employee_directory_bulk_profile_update_models.dart';
import 'employee_directory_models.dart';

class EmployeeDirectoryBulkProfileUpdateChange {
  final String fieldLabel;
  final String currentValue;
  final String nextValue;

  const EmployeeDirectoryBulkProfileUpdateChange({
    required this.fieldLabel,
    required this.currentValue,
    required this.nextValue,
  });
}

class EmployeeDirectoryBulkProfileUpdatePreviewRow {
  final EmployeeDirectoryMember member;
  final List<EmployeeDirectoryBulkProfileUpdateChange> changes;

  const EmployeeDirectoryBulkProfileUpdatePreviewRow({
    required this.member,
    required this.changes,
  });

  int get changeCount => changes.length;

  bool get hasChanges => changes.isNotEmpty;
}

class EmployeeDirectoryBulkProfileUpdatePreview {
  final List<EmployeeDirectoryMember> members;
  final EmployeeDirectoryBulkProfileUpdateDraft draft;
  final List<EmployeeDirectoryBulkProfileUpdatePreviewRow> rows;
  final List<String> errors;
  final String signature;

  const EmployeeDirectoryBulkProfileUpdatePreview({
    required this.members,
    required this.draft,
    required this.rows,
    required this.errors,
    required this.signature,
  });

  factory EmployeeDirectoryBulkProfileUpdatePreview.fromDraft({
    required List<EmployeeDirectoryMember> members,
    required EmployeeDirectoryBulkProfileUpdateDraft draft,
  }) {
    final rows = members
        .map(
          (member) => EmployeeDirectoryBulkProfileUpdatePreviewRow(
            member: member,
            changes: _changesFor(member, draft),
          ),
        )
        .where((row) => row.hasChanges)
        .toList(growable: false);

    final errors = [...draft.validationErrors(members.length)];
    if (errors.isEmpty && rows.isEmpty) {
      errors.add('Change at least one selected profile value.');
    }

    return EmployeeDirectoryBulkProfileUpdatePreview(
      members: members,
      draft: draft,
      rows: rows,
      errors: errors,
      signature: _approvalSignature(members, draft),
    );
  }

  int get selectedCount => members.length;

  int get changedProfileCount => rows.length;

  int get effectiveChangeCount {
    return rows.fold<int>(0, (total, row) => total + row.changeCount);
  }

  int get targetFieldCount => draft.targetFieldCount;

  bool get isReady => errors.isEmpty;

  bool get isApproved {
    return draft.previewApproved && draft.previewApprovalSignature == signature;
  }

  bool get canApply => isReady && isApproved;

  String get approvalLabel {
    if (!isReady) return 'Blocked';
    return isApproved ? 'Approved' : 'Needs approval';
  }

  String get readinessLabel {
    if (selectedCount == 0) return 'No selection';
    if (!draft.hasFieldUpdates) return 'Draft changes';
    if (errors.isNotEmpty) return 'Needs review';
    if (!isApproved) return 'Review changes';
    return 'Ready to apply';
  }

  String get applyBlockerMessage {
    if (errors.isNotEmpty) return errors.first;
    if (!isApproved) return 'Approve the preview before applying updates.';
    return '';
  }

  List<EmployeeDirectoryBulkProfileUpdatePreviewRow> get visibleRows {
    return rows.take(4).toList(growable: false);
  }
}

List<EmployeeDirectoryBulkProfileUpdateChange> _changesFor(
  EmployeeDirectoryMember member,
  EmployeeDirectoryBulkProfileUpdateDraft draft,
) {
  final changes = <EmployeeDirectoryBulkProfileUpdateChange>[];
  _addChange(
    changes,
    fieldLabel: 'Manager',
    currentValue: member.manager,
    nextValue: draft.manager,
  );
  _addChange(
    changes,
    fieldLabel: 'Department',
    currentValue: member.department,
    nextValue: draft.department,
  );
  _addChange(
    changes,
    fieldLabel: 'Location',
    currentValue: member.location,
    nextValue: draft.location,
  );
  return changes;
}

void _addChange(
  List<EmployeeDirectoryBulkProfileUpdateChange> changes, {
  required String fieldLabel,
  required String currentValue,
  required String nextValue,
}) {
  final normalizedNext = nextValue.trim();
  if (normalizedNext.isEmpty) return;
  if (currentValue.trim() == normalizedNext) return;

  changes.add(
    EmployeeDirectoryBulkProfileUpdateChange(
      fieldLabel: fieldLabel,
      currentValue: currentValue,
      nextValue: normalizedNext,
    ),
  );
}

String _approvalSignature(
  List<EmployeeDirectoryMember> members,
  EmployeeDirectoryBulkProfileUpdateDraft draft,
) {
  final ids = members.map((member) => member.id).toList()..sort();
  return [
    ids.join(','),
    draft.manager.trim(),
    draft.department.trim(),
    draft.location.trim(),
    draft.auditNote.trim(),
  ].join('|');
}
