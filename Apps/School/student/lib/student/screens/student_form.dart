// screens/student_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/student.dart';
import '../states/student_form_controller.dart';
import '../states/student_provider.dart';
import '../widgets/basic_form_section.dart';
import '../widgets/student_contact_section.dart';
import '../widgets/enrollment_section.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  final Student? student;

  const StudentFormScreen({super.key, this.student});

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final StudentFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StudentFormController(widget.student);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      studentFormNotifierProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, stackTrace) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.toString())),
            );
          },
          data: (_) {
            Navigator.pop(context);
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BasicInfoSection(controller: _controller),
              const SizedBox(height: 16),
              StudentContactSection(controller: _controller),
              const SizedBox(height: 16),
              EnrollmentSection(controller: _controller),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: ref.watch(studentFormNotifierProvider).isLoading
                    ? null
                    : _submitForm,
                child: ref.watch(studentFormNotifierProvider).isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final student = _controller.toStudent();
      ref.read(studentFormNotifierProvider.notifier).saveStudent(student);
    }
  }
}
