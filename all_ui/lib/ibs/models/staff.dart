import 'enums.dart';
import 'salary.dart';

class Staff {
  final int id; // Unique identifier for the staff
  final String employeeId; // Staff employee ID, min=5, max=20, required, unique
  final String firstName; // Staff first name, min=2, max=50, required
  final String? lastName; // Staff last name, min=2, max=50
  final DateTime dateOfBirth; // Staff date of birth, required
  final DateTime hireDate; // Date when staff was hired, required
  final String phoneNumber; // Staff contact number, min=10, max=15, required
  final String? email; // Staff email address, min=5, max=100
  final String? address; // Staff address, min=5, max=200
  final bool isActive; // Whether staff is currently active, default=true
  final Gender gender; // Gender of the staff
  final StaffRole staffRole; // Role of the staff
  final EmploymentType employmentType; // Employment type of the staff
  final List<Salary>
  salaries; // Salaries received by the staff, oneToMany relationship

  Staff({
    required this.id,
    required this.employeeId,
    required this.firstName,
    this.lastName,
    required this.dateOfBirth,
    required this.hireDate,
    required this.phoneNumber,
    this.email,
    this.address,
    this.isActive = true,
    required this.gender,
    required this.staffRole,
    required this.employmentType,
    this.salaries = const [],
  });

  Staff copyWith({
    int? id,
    String? employeeId,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    DateTime? hireDate,
    String? phoneNumber,
    String? email,
    String? address,
    bool? isActive,
    Gender? gender,
    StaffRole? staffRole,
    EmploymentType? employmentType,
    List<Salary>? salaries,
  }) {
    return Staff(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      hireDate: hireDate ?? this.hireDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      gender: gender ?? this.gender,
      staffRole: staffRole ?? this.staffRole,
      employmentType: employmentType ?? this.employmentType,
      salaries: salaries ?? this.salaries,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'hireDate': hireDate.toIso8601String(),
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'isActive': isActive,
      'gender': gender.toString(),
      'staffRole': staffRole.toString(),
      'employmentType': employmentType.toString(),
      'salaries': salaries.map((e) => e.toJson()).toList(),
    };
  }

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      employeeId: json['employeeId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      hireDate: DateTime.parse(json['hireDate']),
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
      isActive: json['isActive'],
      gender: Gender.values.firstWhere((e) => e.toString() == json['gender']),
      staffRole: StaffRole.values.firstWhere(
        (e) => e.toString() == json['staffRole'],
      ),
      employmentType: EmploymentType.values.firstWhere(
        (e) => e.toString() == json['employmentType'],
      ),
      salaries:
          (json['salaries'] as List).map((e) => Salary.fromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return 'Staff(id: $id, employeeId: $employeeId, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, hireDate: $hireDate, phoneNumber: $phoneNumber, email: $email, address: $address, isActive: $isActive, gender: $gender, staffRole: $staffRole, employmentType: $employmentType, salaries: $salaries)';
  }
}
