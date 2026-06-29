import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/student.dart';
import '../screens/student_form.dart';
import '../screens/student_list.dart';
import '../states/student_provider.dart';

class StudentListTile extends ConsumerWidget {
  final Student student;

  const StudentListTile({super.key, required this.student});

  void _showStudentDetails(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${student.firstName} ${student.lastName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NISN: ${student.nisn}'),
            Text('First Name: ${student.firstName}'),
            Text('Last Name: ${student.lastName}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Dismissible(
        key: Key(student.nisn),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) {
          ref
              .read(studentNotifierProvider.notifier)
              .deleteStudent(student.nisn);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${student.firstName} deleted')),
          );
        },
        child: ListTile(
          leading: CircleAvatar(
            child: Text(student.firstName[0] + student.lastName[0]),
          ),
          title: Text(
            '${student.firstName} ${student.lastName}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('NISN: ${student.nisn}'),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentFormScreen(student: student),
                ),
              );
            },
          ),
          onTap: () => _showStudentDetails(context, student),
        ),
      ),
    );
  }
}
