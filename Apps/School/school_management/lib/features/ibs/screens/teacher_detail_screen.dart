import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/teacher.dart';
import '../states/teacher/teacher_provider.dart';

class TeacherDetailScreen extends ConsumerWidget {
  final int teacherId;
  const TeacherDetailScreen({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacher = ref.read(teachersProvider).getTeacherById(teacherId);

    if (teacher == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Teacher Details')),
        body: const Center(child: Text('Teacher not found')),
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Details'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                // Navigate to edit screen
              } else if (value == 'toggleStatus') {
                ref
                    .read(teachersProvider.notifier)
                    .toggleTeacherStatus(teacher.id);
              } else if (value == 'delete') {
                _showDeleteConfirmation(context, ref, teacher);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'toggleStatus',
                    child: Text(
                      teacher.isActive ? 'Mark as Inactive' : 'Mark as Active',
                    ),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: _getAvatarColor(teacher.id),
                    child: Text(
                      teacher.firstName[0] +
                          (teacher.lastName.isNotEmpty
                              ? teacher.lastName[0]
                              : ''),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    teacher.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    teacher.qualification,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      teacher.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color:
                            teacher.isActive
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                      ),
                    ),
                    backgroundColor:
                        teacher.isActive
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Personal Information'),
                  _buildInfoTile('Employee ID', teacher.employeeId),
                  _buildInfoTile(
                    'Date of Birth',
                    dateFormat.format(teacher.dateOfBirth),
                  ),
                  _buildInfoTile('Age', '${teacher.age} years'),
                  _buildInfoTile(
                    'Gender',
                    _formatEnum(teacher.gender.toString()),
                  ),
                  _buildInfoTile('Phone', teacher.phoneNumber),
                  if (teacher.email != null)
                    _buildInfoTile('Email', teacher.email!),
                  if (teacher.address != null)
                    _buildInfoTile('Address', teacher.address!),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Employment Details'),
                  _buildInfoTile(
                    'Employment Type',
                    _formatEnum(teacher.employmentType.toString()),
                  ),
                  _buildInfoTile(
                    'Hire Date',
                    dateFormat.format(teacher.hireDate),
                  ),
                  _buildInfoTile('Experience', teacher.experienceYears),

                  if (teacher.expertise != null) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('Expertise'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(teacher.expertise!),
                    ),
                  ],

                  const SizedBox(height: 24),
                  _buildSectionTitle('Actions'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // View subjects
                          },
                          icon: const Icon(Icons.book),
                          label: const Text('View Subjects'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // View classes
                          },
                          icon: const Icon(Icons.group),
                          label: const Text('View Classes'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // View salary history
                      },
                      icon: const Icon(Icons.account_balance_wallet),
                      label: const Text('Salary History'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatEnum(String enumValue) {
    // Convert "Gender.male" to "Male"
    final parts = enumValue.split('.');
    if (parts.length > 1) {
      String value = parts[1];
      // Convert camelCase to Title Case with Spaces (e.g. fullTime to Full Time)
      final result = value.replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => ' ${match.group(0)}',
      );
      return result.substring(0, 1).toUpperCase() + result.substring(1);
    }
    return enumValue;
  }

  Color _getAvatarColor(int id) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];
    return colors[id % colors.length];
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Teacher teacher,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Teacher'),
            content: Text(
              'Are you sure you want to delete ${teacher.fullName}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(teachersProvider.notifier).deleteTeacher(teacher.id);
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to teachers list
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('DELETE'),
              ),
            ],
          ),
    );
  }
}

extension on List<Teacher> {
  getTeacherById(int teacherId) {}
}
