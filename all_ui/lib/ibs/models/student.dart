import 'dart:convert';

import 'attendance.dart';
import 'class_group.dart';
import 'disiplinary_record.dart';
import 'dormitory.dart';
import 'enums.dart';
import 'grade.dart';
import 'hafidz_progress.dart';
import 'payment.dart';
import 'room.dart';

class Student {
  final int id; // Unique identifier for the student
  final String
  registrationNumber; // Student registration number, min=5, max=20, required, unique
  final String firstName; // Student first name, min=2, max=50, required
  final String? lastName; // Student last name, min=2, max=50
  final DateTime dateOfBirth; // Student date of birth, required
  final DateTime enrollmentDate; // Date when student enrolled, required
  final String? phoneNumber; // Student contact number, min=10, max=15
  final String? email; // Student email address, min=5, max=100
  final String? address; // Student home address, min=5, max=200
  final String
  parentName; // Name of parent or guardian, min=3, max=100, required
  final String parentContact; // Parent contact number, min=10, max=15, required
  final String? healthInformation; // Any health issues or medical conditions
  final bool isActive; // Whether student is currently active, default=true
  final Gender gender; // Gender of the student
  final BloodType bloodType; // Blood type of the student
  final EducationLevel educationLevel; // Education level of the student
  final Dormitory?
  dormitory; // Dormitory where the student resides, manyToOne relationship
  final Room? room; // Room where the student resides, manyToOne relationship
  final List<ClassGroup>
  classGroups; // Class groups the student belongs to, manyToMany relationship
  final List<Payment>
  payments; // Payments made by the student, oneToMany relationship
  final List<Attendance>
  attendances; // Attendance records of the student, oneToMany relationship
  final List<Grade>
  grades; // Academic grades of the student, oneToMany relationship
  final List<DisciplinaryRecord>
  disciplinaryRecords; // Disciplinary records of the student, oneToMany relationship
  final List<HafizProgress>
  hafizProgresses; // Quran memorization progress of the student, oneToMany relationship

  Student({
    required this.id,
    required this.registrationNumber,
    required this.firstName,
    this.lastName,
    required this.dateOfBirth,
    required this.enrollmentDate,
    this.phoneNumber,
    this.email,
    this.address,
    required this.parentName,
    required this.parentContact,
    this.healthInformation,
    this.isActive = true,
    required this.gender,
    required this.bloodType,
    required this.educationLevel,
    this.dormitory,
    this.room,
    this.classGroups = const [],
    this.payments = const [],
    this.attendances = const [],
    this.grades = const [],
    this.disciplinaryRecords = const [],
    this.hafizProgresses = const [],
  });

  Student copyWith({
    int? id,
    String? registrationNumber,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    DateTime? enrollmentDate,
    String? phoneNumber,
    String? email,
    String? address,
    String? parentName,
    String? parentContact,
    String? healthInformation,
    bool? isActive,
    Gender? gender,
    BloodType? bloodType,
    EducationLevel? educationLevel,
    Dormitory? dormitory,
    Room? room,
    List<ClassGroup>? classGroups,
    List<Payment>? payments,
    List<Attendance>? attendances,
    List<Grade>? grades,
    List<DisciplinaryRecord>? disciplinaryRecords,
    List<HafizProgress>? hafizProgresses,
  }) {
    return Student(
      id: id ?? this.id,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      parentName: parentName ?? this.parentName,
      parentContact: parentContact ?? this.parentContact,
      healthInformation: healthInformation ?? this.healthInformation,
      isActive: isActive ?? this.isActive,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      educationLevel: educationLevel ?? this.educationLevel,
      dormitory: dormitory ?? this.dormitory,
      room: room ?? this.room,
      classGroups: classGroups ?? this.classGroups,
      payments: payments ?? this.payments,
      attendances: attendances ?? this.attendances,
      grades: grades ?? this.grades,
      disciplinaryRecords: disciplinaryRecords ?? this.disciplinaryRecords,
      hafizProgresses: hafizProgresses ?? this.hafizProgresses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registrationNumber': registrationNumber,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'parentName': parentName,
      'parentContact': parentContact,
      'healthInformation': healthInformation,
      'isActive': isActive,
      'gender': gender.toString(),
      'bloodType': bloodType.toString(),
      'educationLevel': educationLevel.toString(),
      'dormitory': dormitory?.toJson(),
      'room': room?.toJson(),
      'classGroups': classGroups.map((e) => e.toJson()).toList(),
      'payments': payments.map((e) => e.toJson()).toList(),
      'attendances': attendances.map((e) => e.toJson()).toList(),
      'grades': grades.map((e) => e.toJson()).toList(),
      'disciplinaryRecords':
          disciplinaryRecords.map((e) => e.toJson()).toList(),
      'hafizProgresses': hafizProgresses.map((e) => e.toJson()).toList(),
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      registrationNumber: json['registrationNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      enrollmentDate: DateTime.parse(json['enrollmentDate']),
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
      parentName: json['parentName'],
      parentContact: json['parentContact'],
      healthInformation: json['healthInformation'],
      isActive: json['isActive'],
      gender: Gender.values.firstWhere((e) => e.toString() == json['gender']),
      bloodType: BloodType.values.firstWhere(
        (e) => e.toString() == json['bloodType'],
      ),
      educationLevel: EducationLevel.values.firstWhere(
        (e) => e.toString() == json['educationLevel'],
      ),
      dormitory:
          json['dormitory'] != null
              ? Dormitory.fromJson(json['dormitory'])
              : null,
      room: json['room'] != null ? Room.fromJson(json['room']) : null,
      classGroups:
          (json['classGroups'] as List)
              .map((e) => ClassGroup.fromJson(e))
              .toList(),
      payments:
          (json['payments'] as List).map((e) => Payment.fromJson(e)).toList(),
      attendances:
          (json['attendances'] as List)
              .map((e) => Attendance.fromJson(e))
              .toList(),
      grades: (json['grades'] as List).map((e) => Grade.fromJson(e)).toList(),
      disciplinaryRecords:
          (json['disciplinaryRecords'] as List)
              .map((e) => DisciplinaryRecord.fromJson(e))
              .toList(),
      hafizProgresses:
          (json['hafizProgresses'] as List)
              .map((e) => HafizProgress.fromJson(e))
              .toList(),
    );
  }

  @override
  String toString() {
    return 'Student(id: $id, registrationNumber: $registrationNumber, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, enrollmentDate: $enrollmentDate, phoneNumber: $phoneNumber, email: $email, address: $address, parentName: $parentName, parentContact: $parentContact, healthInformation: $healthInformation, isActive: $isActive, gender: $gender, bloodType: $bloodType, educationLevel: $educationLevel, dormitory: $dormitory, room: $room, classGroups: $classGroups, payments: $payments, attendances: $attendances, grades: $grades, disciplinaryRecords: $disciplinaryRecords, hafizProgresses: $hafizProgresses)';
  }
}
