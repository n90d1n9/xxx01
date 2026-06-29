import 'employee_directory_models.dart';
import 'employee_directory_quality_models.dart';

/// Editable remediation values for the selected employee directory quality issue.
class EmployeeDirectoryQualityFixDraft {
  final String issueKey;
  final String email;
  final String phone;
  final String manager;
  final String department;
  final String location;
  final String joiningDate;
  final String auditNote;

  const EmployeeDirectoryQualityFixDraft({
    this.issueKey = '',
    this.email = '',
    this.phone = '',
    this.manager = '',
    this.department = '',
    this.location = '',
    this.joiningDate = '',
    this.auditNote = '',
  });

  bool get hasInput {
    return [
      issueKey,
      email,
      phone,
      manager,
      department,
      location,
      joiningDate,
      auditNote,
    ].any((value) => value.trim().isNotEmpty);
  }

  EmployeeDirectoryQualityFixDraft copyWith({
    String? issueKey,
    String? email,
    String? phone,
    String? manager,
    String? department,
    String? location,
    String? joiningDate,
    String? auditNote,
  }) {
    return EmployeeDirectoryQualityFixDraft(
      issueKey: issueKey ?? this.issueKey,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      manager: manager ?? this.manager,
      department: department ?? this.department,
      location: location ?? this.location,
      joiningDate: joiningDate ?? this.joiningDate,
      auditNote: auditNote ?? this.auditNote,
    );
  }
}

/// Validates and applies a quality issue fix against the current directory state.
class EmployeeDirectoryQualityFixReview {
  final EmployeeDirectoryQualityIssue? issue;
  final EmployeeDirectoryMember? member;
  final List<EmployeeDirectoryQualityIssue> issues;
  final EmployeeDirectoryQualityFixDraft draft;
  final List<String> errors;
  final DateTime asOfDate;

  const EmployeeDirectoryQualityFixReview({
    required this.issue,
    required this.member,
    required this.issues,
    required this.draft,
    required this.errors,
    required this.asOfDate,
  });

  factory EmployeeDirectoryQualityFixReview.fromState({
    required EmployeeDirectoryQualityReport report,
    required List<EmployeeDirectoryMember> members,
    required EmployeeDirectoryQualityFixDraft draft,
    required DateTime asOfDate,
  }) {
    final issue = _resolveIssue(report.issues, draft.issueKey);
    final member =
        issue == null
            ? null
            : members
                .where((member) => member.id == issue.employeeId)
                .firstOrNull;

    final review = EmployeeDirectoryQualityFixReview(
      issue: issue,
      member: member,
      issues: report.issues,
      draft: draft,
      errors: const [],
      asOfDate: asOfDate,
    );

    return EmployeeDirectoryQualityFixReview(
      issue: issue,
      member: member,
      issues: report.issues,
      draft: draft,
      errors: _validate(review, members),
      asOfDate: asOfDate,
    );
  }

  bool get hasIssue => issue != null && member != null;

  bool get canSubmit => errors.isEmpty && hasIssue;

  int get issueCount => issues.length;

  String get selectedIssueKey => issue?.fixKey ?? '';

  String get statusLabel {
    if (!hasIssue) return 'No issue';
    return canSubmit ? 'Ready' : 'Needs input';
  }

  bool get requiresEmail {
    return issue?.type == EmployeeDirectoryQualityIssueType.duplicateEmail ||
        (issue?.type == EmployeeDirectoryQualityIssueType.missingContact &&
            (member?.email.trim().isEmpty ?? false));
  }

  bool get requiresPhone {
    return issue?.type == EmployeeDirectoryQualityIssueType.missingContact &&
        (member?.phone.trim().isEmpty ?? false);
  }

  bool get requiresManager {
    return issue?.type == EmployeeDirectoryQualityIssueType.missingManager;
  }

  bool get requiresDepartment {
    return issue?.type == EmployeeDirectoryQualityIssueType.missingDepartment;
  }

  bool get requiresLocation {
    return issue?.type == EmployeeDirectoryQualityIssueType.missingLocation;
  }

  bool get requiresJoiningDate {
    return issue?.type == EmployeeDirectoryQualityIssueType.futureStart;
  }

  int get requiredFieldCount {
    return [
      requiresEmail,
      requiresPhone,
      requiresManager,
      requiresDepartment,
      requiresLocation,
      requiresJoiningDate,
    ].where((required) => required).length;
  }

  EmployeeDirectoryMember applyToMember() {
    final target = member;
    if (target == null) {
      throw StateError('Cannot apply a quality fix without a target member.');
    }

    return target.copyWith(
      email: _valueOrCurrent(draft.email, target.email),
      phone: _valueOrCurrent(draft.phone, target.phone),
      manager: _valueOrCurrent(draft.manager, target.manager),
      department: _valueOrCurrent(draft.department, target.department),
      location: _valueOrCurrent(draft.location, target.location),
      joiningDate: _parsedDateOrCurrent(draft.joiningDate, target.joiningDate),
    );
  }
}

extension EmployeeDirectoryQualityFixIssueKey on EmployeeDirectoryQualityIssue {
  String get fixKey => '$employeeId:${type.name}';
}

EmployeeDirectoryQualityIssue? _resolveIssue(
  List<EmployeeDirectoryQualityIssue> issues,
  String issueKey,
) {
  if (issues.isEmpty) return null;

  if (issueKey.trim().isNotEmpty) {
    final matches = issues.where((issue) => issue.fixKey == issueKey);
    if (matches.isNotEmpty) return matches.first;
  }

  return issues.first;
}

List<String> _validate(
  EmployeeDirectoryQualityFixReview review,
  List<EmployeeDirectoryMember> members,
) {
  final issue = review.issue;
  final member = review.member;
  if (issue == null || member == null) return const [];

  final errors = <String>[];

  switch (issue.type) {
    case EmployeeDirectoryQualityIssueType.duplicateEmail:
      _validateEmail(
        errors,
        value: review.draft.email,
        currentValue: member.email,
        members: members,
        memberId: member.id,
      );
      break;
    case EmployeeDirectoryQualityIssueType.missingContact:
      if (member.email.trim().isEmpty) {
        _validateEmail(
          errors,
          value: review.draft.email,
          currentValue: member.email,
          members: members,
          memberId: member.id,
        );
      }
      if (member.phone.trim().isEmpty) {
        _validateRequiredText(
          errors,
          value: review.draft.phone,
          label: 'phone',
        );
      }
      break;
    case EmployeeDirectoryQualityIssueType.missingManager:
      _validateRequiredText(
        errors,
        value: review.draft.manager,
        label: 'manager',
        currentValue: member.manager,
      );
      break;
    case EmployeeDirectoryQualityIssueType.missingDepartment:
      _validateRequiredText(
        errors,
        value: review.draft.department,
        label: 'department',
        currentValue: member.department,
      );
      break;
    case EmployeeDirectoryQualityIssueType.missingLocation:
      _validateRequiredText(
        errors,
        value: review.draft.location,
        label: 'location',
        currentValue: member.location,
      );
      break;
    case EmployeeDirectoryQualityIssueType.futureStart:
      final parsed = DateTime.tryParse(review.draft.joiningDate.trim());
      if (parsed == null) {
        errors.add('Enter joining date as YYYY-MM-DD.');
      } else if (_dateOnly(parsed).isAfter(_dateOnly(review.asOfDate))) {
        errors.add('Joining date cannot be later than the directory date.');
      } else if (_dateOnly(parsed) == _dateOnly(member.joiningDate)) {
        errors.add('Joining date must change the current value.');
      }
      break;
  }

  if (review.draft.auditNote.trim().length < 6) {
    errors.add('Add an audit note with at least 6 characters.');
  }

  return errors;
}

void _validateEmail(
  List<String> errors, {
  required String value,
  required String currentValue,
  required List<EmployeeDirectoryMember> members,
  required String memberId,
}) {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty || !normalized.contains('@')) {
    errors.add('Enter a valid email address.');
    return;
  }
  if (normalized == currentValue.trim().toLowerCase()) {
    errors.add('Email must change the current value.');
    return;
  }
  final alreadyUsed = members.any((member) {
    return member.id != memberId &&
        member.email.trim().toLowerCase() == normalized;
  });
  if (alreadyUsed) {
    errors.add('Email must be unique across the directory.');
  }
}

void _validateRequiredText(
  List<String> errors, {
  required String value,
  required String label,
  String currentValue = '',
}) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    errors.add('Enter a $label value.');
    return;
  }
  if (normalized == currentValue.trim()) {
    errors.add('${_capitalize(label)} must change the current value.');
  }
}

String _valueOrCurrent(String value, String currentValue) {
  final normalized = value.trim();
  return normalized.isEmpty ? currentValue : normalized;
}

DateTime _parsedDateOrCurrent(String value, DateTime currentValue) {
  final parsed = DateTime.tryParse(value.trim());
  if (parsed == null) return currentValue;
  return _dateOnly(parsed);
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
}
