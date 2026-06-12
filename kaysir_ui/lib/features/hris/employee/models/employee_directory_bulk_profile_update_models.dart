import 'employee_directory_models.dart';

class EmployeeDirectoryBulkProfileUpdateDraft {
  final String manager;
  final String department;
  final String location;
  final String auditNote;
  final bool previewApproved;
  final String previewApprovalSignature;

  const EmployeeDirectoryBulkProfileUpdateDraft({
    this.manager = '',
    this.department = '',
    this.location = '',
    this.auditNote = '',
    this.previewApproved = false,
    this.previewApprovalSignature = '',
  });

  int get targetFieldCount {
    return [
      manager,
      department,
      location,
    ].where((value) => value.trim().isNotEmpty).length;
  }

  bool get hasFieldUpdates => targetFieldCount > 0;

  bool get hasInput {
    return hasFieldUpdates || auditNote.trim().isNotEmpty;
  }

  List<String> get changedFieldLabels {
    final fields = <String>[];
    if (manager.trim().isNotEmpty) fields.add('manager');
    if (department.trim().isNotEmpty) fields.add('department');
    if (location.trim().isNotEmpty) fields.add('location');
    return fields;
  }

  List<String> validationErrors(int selectedCount) {
    final errors = <String>[];

    if (selectedCount <= 0) {
      errors.add('Select at least one employee profile.');
    }
    if (!hasFieldUpdates) {
      errors.add('Add at least one manager, department, or location change.');
    }
    if (auditNote.trim().length < 6) {
      errors.add('Add an audit note with at least 6 characters.');
    }

    return errors;
  }

  bool isReady(int selectedCount) => validationErrors(selectedCount).isEmpty;

  EmployeeDirectoryMember applyTo(EmployeeDirectoryMember member) {
    return member.copyWith(
      manager: _valueOrCurrent(manager, member.manager),
      department: _valueOrCurrent(department, member.department),
      location: _valueOrCurrent(location, member.location),
    );
  }

  EmployeeDirectoryBulkProfileUpdateDraft copyWith({
    String? manager,
    String? department,
    String? location,
    String? auditNote,
    bool? previewApproved,
    String? previewApprovalSignature,
  }) {
    return EmployeeDirectoryBulkProfileUpdateDraft(
      manager: manager ?? this.manager,
      department: department ?? this.department,
      location: location ?? this.location,
      auditNote: auditNote ?? this.auditNote,
      previewApproved: previewApproved ?? this.previewApproved,
      previewApprovalSignature:
          previewApprovalSignature ?? this.previewApprovalSignature,
    );
  }
}

String _valueOrCurrent(String incoming, String current) {
  final value = incoming.trim();
  return value.isEmpty ? current : value;
}
