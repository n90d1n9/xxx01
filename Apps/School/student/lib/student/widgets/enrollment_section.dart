import 'package:flutter/material.dart';
import '../states/student_form_controller.dart';

class EnrollmentSection extends StatelessWidget {
  final StudentFormController controller;

  const EnrollmentSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enrollment Details',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Enrollment Date'),
              controller: controller.enrollmentDateController,
            ),
          ],
        ),
      ),
    );
  }
}
