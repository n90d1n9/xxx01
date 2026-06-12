import 'class_group.dart';
import 'enums.dart';
import 'salary.dart';
import 'subject.dart';

class Teacher {
  final int id; // Unique identifier for the teacher
  final String?
  employeeId; // Teacher employee ID, min=5, max=20, required, unique
  final String firstName; // Teacher first name, min=2, max=50, required
  final String? lastName; // Teacher last name, min=2, max=50
  final DateTime? dateOfBirth; // Teacher date of birth, required
  final DateTime? hireDate; // Date when teacher was hired, required
  final String? phoneNumber; // Teacher contact number, min=10, max=15, required
  final String? email; // Teacher email address, min=5, max=100
  final String? address; // Teacher address, min=5, max=200
  final String?
  qualification; // Teacher academic qualifications, min=5, max=100, required
  final String? expertise; // Teacher areas of expertise, min=5, max=200
  final bool? isActive; // Whether teacher is currently active, default=true
  final Gender? gender; // Gender of the teacher
  final EmploymentType? employmentType; // Employment type of the teacher
  final List<Subject>?
  subjects; // Subjects taught by the teacher, manyToMany relationship
  final List<ClassGroup>?
  classGroups; // Class groups taught by the teacher, manyToMany relationship
  final List<Salary>?
  salaries; // Salaries received by the teacher, oneToMany relationship

  Teacher({
    required this.id,
    this.employeeId,
    required this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.hireDate,
    this.phoneNumber,
    this.email,
    this.address,
    this.qualification,
    this.expertise,
    this.isActive = true,
    this.gender,
    this.employmentType,
    this.subjects = const [],
    this.classGroups = const [],
    this.salaries = const [],
  });

  Teacher copyWith({
    int? id,
    String? employeeId,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    DateTime? hireDate,
    String? phoneNumber,
    String? email,
    String? address,
    String? qualification,
    String? expertise,
    bool? isActive,
    Gender? gender,
    EmploymentType? employmentType,
    List<Subject>? subjects,
    List<ClassGroup>? classGroups,
    List<Salary>? salaries,
  }) {
    return Teacher(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      hireDate: hireDate ?? this.hireDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      qualification: qualification ?? this.qualification,
      expertise: expertise ?? this.expertise,
      isActive: isActive ?? this.isActive,
      gender: gender ?? this.gender,
      employmentType: employmentType ?? this.employmentType,
      subjects: subjects ?? this.subjects,
      classGroups: classGroups ?? this.classGroups,
      salaries: salaries ?? this.salaries,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth!.toIso8601String(),
      'hireDate': hireDate!.toIso8601String(),
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'qualification': qualification,
      'expertise': expertise,
      'isActive': isActive,
      'gender': gender.toString(),
      'employmentType': employmentType.toString(),
      'subjects': subjects!.map((e) => e.toJson()).toList(),
      'classGroups': classGroups!.map((e) => e.toJson()).toList(),
      'salaries': salaries!.map((e) => e.toJson()).toList(),
    };
  }

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      employeeId: json['employeeId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      hireDate: DateTime.parse(json['hireDate']),
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
      qualification: json['qualification'],
      expertise: json['expertise'],
      isActive: json['isActive'],
      gender: Gender.values.firstWhere((e) => e.toString() == json['gender']),
      employmentType: EmploymentType.values.firstWhere(
        (e) => e.toString() == json['employmentType'],
      ),
      subjects:
          (json['subjects'] as List).map((e) => Subject.fromJson(e)).toList(),
      classGroups:
          (json['classGroups'] as List)
              .map((e) => ClassGroup.fromJson(e))
              .toList(),
      salaries:
          (json['salaries'] as List).map((e) => Salary.fromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return 'Teacher(id: $id, employeeId: $employeeId, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, hireDate: $hireDate, phoneNumber: $phoneNumber, email: $email, address: $address, qualification: $qualification, expertise: $expertise, isActive: $isActive, gender: $gender, employmentType: $employmentType, subjects: $subjects, classGroups: $classGroups, salaries: $salaries)';
  }
}
