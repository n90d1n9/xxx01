import 'employee.dart';

class EmployeeFormDraft {
  final String name;
  final String position;
  final String department;
  final String email;
  final String phone;
  final String salary;
  final DateTime? hireDate;

  const EmployeeFormDraft({
    required this.name,
    required this.position,
    required this.department,
    required this.email,
    required this.phone,
    required this.salary,
    required this.hireDate,
  });

  factory EmployeeFormDraft.empty() {
    return const EmployeeFormDraft(
      name: '',
      position: '',
      department: '',
      email: '',
      phone: '',
      salary: '',
      hireDate: null,
    );
  }

  factory EmployeeFormDraft.fromEmployee(Employee? employee) {
    if (employee == null) return EmployeeFormDraft.empty();
    return EmployeeFormDraft(
      name: employee.name,
      position: employee.position ?? '',
      department: employee.department ?? '',
      email: employee.email ?? '',
      phone: employee.phone ?? '',
      salary: employee.salary?.toStringAsFixed(0) ?? '',
      hireDate: employee.hireDate,
    );
  }

  EmployeeFormDraft copyWith({
    String? name,
    String? position,
    String? department,
    String? email,
    String? phone,
    String? salary,
    DateTime? hireDate,
    bool clearHireDate = false,
  }) {
    return EmployeeFormDraft(
      name: name ?? this.name,
      position: position ?? this.position,
      department: department ?? this.department,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      salary: salary ?? this.salary,
      hireDate: clearHireDate ? null : hireDate ?? this.hireDate,
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
          salary.trim().isNotEmpty,
          hireDate != null,
        ].where((item) => item).length;
    return completed / 7;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    final validations = [
      validateRequired(name, 'a name'),
      validateRequired(position, 'a position'),
      validateRequired(department, 'a department'),
      validateEmail(email),
      validateRequired(phone, 'a phone number'),
      validateSalary(salary),
      validateHireDate(hireDate),
    ];

    for (final validation in validations) {
      if (validation != null) errors.add(validation);
    }
    return errors;
  }

  bool get isReadyToSave => validationErrors.isEmpty;

  Employee toEmployee({required int id, Employee? existing}) {
    return Employee(
      id: id,
      name: name.trim(),
      position: position.trim(),
      department: department.trim(),
      email: email.trim(),
      phone: phone.trim(),
      hireDate: hireDate,
      salary: salary.trim().isEmpty ? null : double.parse(salary.trim()),
      employeeId: existing?.employeeId,
      imageUrl: existing?.imageUrl,
      address: existing?.address,
      dateOfBirth: existing?.dateOfBirth,
      managerName: existing?.managerName,
      isActive: existing?.isActive ?? true,
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

  static String? validateSalary(String? value) {
    final requiredError = validateRequired(value, 'a salary');
    if (requiredError != null) return requiredError;
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0) {
      return 'Please enter a valid salary';
    }
    return null;
  }

  static String? validateHireDate(DateTime? value) {
    if (value == null) return 'Please select a hire date';
    if (value.isAfter(DateTime.now())) return 'Hire date cannot be in future';
    return null;
  }
}
