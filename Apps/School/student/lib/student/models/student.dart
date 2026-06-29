// student_model.dart
class Student {
  final String nisn;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final DateTime enrollmentDate;

  Student({
    required this.nisn,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.enrollmentDate,
  });
}
