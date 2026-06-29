// widgets/form_sections.dart
import 'package:flutter/material.dart';

import '../states/student_form_controller.dart';
import '../utils/validator.dart';
import 'date_picker.dart';
import 'gender_selector.dart';

class BasicInfoSection extends StatelessWidget {
  final StudentFormController controller;

  const BasicInfoSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.nisnController,
              decoration: const InputDecoration(
                labelText: 'NISN',
                border: OutlineInputBorder(),
              ),
              validator: Validators.nisn,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.required,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: controller.lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DatePickerFormField(
              labelText: 'Date of Birth',
              selectedDate: controller.dateOfBirth,
              onDateSelected: (date) {
                controller.dateOfBirth = date;
              },
            ),
            const SizedBox(height: 16),
            GenderSelector(
              selectedGender: controller.gender ?? 'Male',
              onGenderChanged: (gender) {
                controller.gender = gender;
              },
            ),
          ],
        ),
      ),
    );
  }
}
