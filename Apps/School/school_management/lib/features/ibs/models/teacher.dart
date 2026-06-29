import 'class_group.dart';
import 'enums.dart';
import 'salary.dart';

class Teacher {
  final int id; // Unique identifier for the teacher
  final String?
  employeeId; // Teacher employee ID, min=5, max=20, required, unique
  final String? name;
  final String? photoUrl;
  final String? firstName; // Teacher first name, min=2, max=50, required
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
  final List<int>?
  subjectsIds; // Subjects taught by the teacher, manyToMany relationship
  final List<ClassGroup>?
  classGroups; // Class groups taught by the teacher, manyToMany relationship
  final List<Salary>?
  salaries; // Salaries received by the teacher, oneToMany relationship

  String get fullName => '$firstName ${lastName ?? ""}';
  int get age {
    final today = DateTime.now();
    int years = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      years--;
    }
    return years;
  }

  String get experienceYears {
    final today = DateTime.now();
    int years = today.year - hireDate!.year;
    if (today.month < hireDate!.month ||
        (today.month == hireDate!.month && today.day < hireDate!.day)) {
      years--;
    }
    return '$years ${years == 1 ? 'year' : 'years'}';
  }

  Teacher({
    required this.id,
    this.employeeId,
    this.name,
    this.photoUrl,
    this.firstName,
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
    this.subjectsIds = const [],
    this.classGroups = const [],
    this.salaries = const [],
  });

  Teacher copyWith({
    int? id,
    String? name,
    String? photoUrl,
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
    List<int>? subjectsIds,
    List<ClassGroup>? classGroups,
    List<Salary>? salaries,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
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
      subjectsIds: subjectsIds ?? this.subjectsIds,
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
      'subjectsIds': subjectsIds!.map((e) => e).toList(),
      'classGroups': classGroups!.map((e) => e.toJson()).toList(),
      'salaries': salaries!.map((e) => e.toJson()).toList(),
    };
  }

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      name: json['name'],
      photoUrl: json['photoUrl'],
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
      subjectsIds:
          (json['subjectsIds'] as List).map((e) => e).toList().cast<int>(),
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
    return 'Teacher(id: $id, employeeId: $employeeId, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, hireDate: $hireDate, phoneNumber: $phoneNumber, email: $email, address: $address, qualification: $qualification, expertise: $expertise, isActive: $isActive, gender: $gender, employmentType: $employmentType, subjectsIds: $subjectsIds, classGroups: $classGroups, salaries: $salaries)';
  }
}
