import 'employee_directory_models.dart';

class EmployeeDirectoryIntakeDraft {
  final String name;
  final String position;
  final String department;
  final String email;
  final String phone;
  final DateTime? joiningDate;
  final String performance;
  final String location;
  final String manager;
  final EmployeeDirectoryStatus status;

  const EmployeeDirectoryIntakeDraft({
    required this.name,
    required this.position,
    required this.department,
    required this.email,
    required this.phone,
    required this.joiningDate,
    required this.performance,
    required this.location,
    required this.manager,
    required this.status,
  });

  factory EmployeeDirectoryIntakeDraft.empty({DateTime? joiningDate}) {
    return EmployeeDirectoryIntakeDraft(
      name: '',
      position: '',
      department: '',
      email: '',
      phone: '',
      joiningDate: joiningDate,
      performance: '4.2',
      location: '',
      manager: '',
      status: EmployeeDirectoryStatus.onboarding,
    );
  }

  factory EmployeeDirectoryIntakeDraft.fromMember(
    EmployeeDirectoryMember member,
  ) {
    return EmployeeDirectoryIntakeDraft(
      name: member.name,
      position: member.position,
      department: member.department,
      email: member.email,
      phone: member.phone,
      joiningDate: member.joiningDate,
      performance: member.performance.toStringAsFixed(1),
      location: member.location,
      manager: member.manager,
      status: member.status,
    );
  }

  EmployeeDirectoryIntakeDraft copyWith({
    String? name,
    String? position,
    String? department,
    String? email,
    String? phone,
    DateTime? joiningDate,
    bool clearJoiningDate = false,
    String? performance,
    String? location,
    String? manager,
    EmployeeDirectoryStatus? status,
  }) {
    return EmployeeDirectoryIntakeDraft(
      name: name ?? this.name,
      position: position ?? this.position,
      department: department ?? this.department,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      joiningDate: clearJoiningDate ? null : joiningDate ?? this.joiningDate,
      performance: performance ?? this.performance,
      location: location ?? this.location,
      manager: manager ?? this.manager,
      status: status ?? this.status,
    );
  }

  double get completionRatio {
    final completed =
        [
          name.trim().isNotEmpty,
          position.trim().isNotEmpty,
          department.trim().isNotEmpty,
          email.trim().isNotEmpty,
          phone.trim().isNotEmpty,
          joiningDate != null,
          performance.trim().isNotEmpty,
          location.trim().isNotEmpty,
          manager.trim().isNotEmpty,
        ].where((item) => item).length;

    return completed / 9;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    final validations = [
      validateRequired(name, 'a name'),
      validateRequired(position, 'a position'),
      validateRequired(department, 'a department'),
      validateEmail(email),
      validateRequired(phone, 'a phone number'),
      validateJoiningDate(joiningDate),
      validatePerformance(performance),
      validateRequired(location, 'a work location'),
      validateRequired(manager, 'a manager'),
    ];

    for (final validation in validations) {
      if (validation != null) errors.add(validation);
    }

    return errors;
  }

  bool get isReadyToCreate => validationErrors.isEmpty;

  EmployeeDirectoryMember toMember({
    required String id,
    required String avatarUrl,
  }) {
    return EmployeeDirectoryMember(
      id: id,
      name: name.trim(),
      position: position.trim(),
      department: department.trim(),
      avatarUrl: avatarUrl,
      email: email.trim(),
      phone: phone.trim(),
      joiningDate: joiningDate!,
      performance: double.parse(performance.trim()),
      location: location.trim(),
      manager: manager.trim(),
      status: status,
    );
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final requiredError = validateRequired(value, 'an email');
    if (requiredError != null) return requiredError;

    final email = value!.trim();
    if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validateJoiningDate(DateTime? value) {
    if (value == null) return 'Please select a joining date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final joiningDay = DateTime(value.year, value.month, value.day);
    if (joiningDay.isAfter(today)) {
      return 'Joining date cannot be in future';
    }

    return null;
  }

  static String? validatePerformance(String? value) {
    final requiredError = validateRequired(value, 'a performance rating');
    if (requiredError != null) return requiredError;

    final parsed = double.tryParse(value!.trim());
    if (parsed == null || parsed < 0 || parsed > 5) {
      return 'Please enter a rating from 0 to 5';
    }

    return null;
  }
}
