import 'package:flutter/material.dart';
import 'package:student/student/models/student.dart';

class StudentFormController {
  final TextEditingController nisnController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController enrollmentDateController =
      TextEditingController();
  DateTime? dateOfBirth;
  String? gender;

  StudentFormController(Student? student);

  void dispose() {
    nisnController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
  }

  toStudent() {}
}
