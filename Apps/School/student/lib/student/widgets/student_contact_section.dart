import 'package:flutter/material.dart';
import '../states/student_form_controller.dart';
import '../widgets/form_section.dart'; // Add this import

class StudentContactSection extends StatelessWidget {
  final StudentFormController controller;

  const StudentContactSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: 'Contact Information',
      children: [
        TextFormField(
          controller: controller.phoneController,
          decoration: const InputDecoration(labelText: 'Phone Number'),
          keyboardType: TextInputType.phone,
        ),
        TextFormField(
          controller: controller.emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }
}
