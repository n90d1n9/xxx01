import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaysir/features/ibs/models/student.dart';

class StudentList extends StatelessWidget {
  final List<Student> students;
  const StudentList({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(student.profileImage!),
            ),
            title: Text(
              student.name,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(student.email!),
            trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
          ),
        );
      },
    );
  }
}
