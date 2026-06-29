// student_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/student.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final List<Student> students = [
    Student(
      nisn: "1234567890",
      firstName: "Budi",
      lastName: "Santoso",
      dateOfBirth: DateTime(2015, 5, 15),
      gender: "L",
      enrollmentDate: DateTime(2022, 7, 15),
    ),
    Student(
      nisn: "9876543210",
      firstName: "Siti",
      lastName: "Rahayu",
      dateOfBirth: DateTime(2016, 3, 20),
      gender: "P",
      enrollmentDate: DateTime(2022, 7, 15),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                '${student.firstName} ${student.lastName}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NISN: ${student.nisn}'),
                  Text(
                    'Birth Date: ${DateFormat('dd/MM/yyyy').format(student.dateOfBirth)}',
                  ),
                  Text(
                      'Gender: ${student.gender == "L" ? "Laki-laki" : "Perempuan"}'),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Delete'),
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StudentFormScreen(student: student),
                      ),
                    );
                  } else if (value == 'delete') {
                    // Implement delete functionality
                    showDeleteConfirmationDialog(context, student);
                  }
                },
              ),
              onTap: () {
                // Navigate to student detail screen
                showStudentDetailDialog(context, student);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StudentFormScreen()),
          );
        },
      ),
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Student'),
        content: Text(
          'Are you sure you want to delete ${student.firstName} ${student.lastName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement delete functionality
              Navigator.pop(context);
            },
            child: Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void showStudentDetailDialog(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Student Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NISN: ${student.nisn}'),
            SizedBox(height: 8),
            Text('Name: ${student.firstName} ${student.lastName}'),
            SizedBox(height: 8),
            Text(
              'Birth Date: ${DateFormat('dd/MM/yyyy').format(student.dateOfBirth)}',
            ),
            SizedBox(height: 8),
            Text(
              'Gender: ${student.gender == "L" ? "Laki-laki" : "Perempuan"}',
            ),
            SizedBox(height: 8),
            Text(
              'Enrollment Date: ${DateFormat('dd/MM/yyyy').format(student.enrollmentDate)}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

// student_form_screen.dart
class StudentFormScreen extends StatefulWidget {
  final Student? student;

  const StudentFormScreen({Key? key, this.student}) : super(key: key);

  @override
  _StudentFormScreenState createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nisnController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  DateTime? _dateOfBirth;
  String _gender = 'L';
  DateTime? _enrollmentDate;

  @override
  void initState() {
    super.initState();
    _nisnController = TextEditingController(text: widget.student?.nisn ?? '');
    _firstNameController =
        TextEditingController(text: widget.student?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: widget.student?.lastName ?? '');
    _dateOfBirth = widget.student?.dateOfBirth;
    _gender = widget.student?.gender ?? 'L';
    _enrollmentDate = widget.student?.enrollmentDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nisnController,
                decoration: InputDecoration(
                  labelText: 'NISN',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter NISN';
                  }
                  if (value.length != 10) {
                    return 'NISN must be 10 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter last name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Date of Birth'),
                subtitle: Text(
                  _dateOfBirth == null
                      ? 'Not selected'
                      : DateFormat('dd/MM/yyyy').format(_dateOfBirth!),
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dateOfBirth ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _dateOfBirth = date);
                  }
                },
              ),
              SizedBox(height: 16),
              Text('Gender'),
              Row(
                children: [
                  Radio<String>(
                    value: 'L',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() => _gender = value!);
                    },
                  ),
                  Text('Laki-laki'),
                  Radio<String>(
                    value: 'P',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() => _gender = value!);
                    },
                  ),
                  Text('Perempuan'),
                ],
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Enrollment Date'),
                subtitle: Text(
                  _enrollmentDate == null
                      ? 'Not selected'
                      : DateFormat('dd/MM/yyyy').format(_enrollmentDate!),
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _enrollmentDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _enrollmentDate = date);
                  }
                },
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Implement save functionality
                      Navigator.pop(context);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Save Student'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nisnController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
