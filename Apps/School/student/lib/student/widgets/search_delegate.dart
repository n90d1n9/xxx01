import 'package:flutter/material.dart';
import '../models/student.dart';

class StudentSearchDelegate extends SearchDelegate<Student?> {
  final List<Student> students;

  StudentSearchDelegate(this.students);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = students
        .where((student) =>
            student.firstName.toLowerCase().contains(query.toLowerCase()) ??
            false)
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final student = results[index];
        return ListTile(
          title: Text(student.firstName),
          onTap: () {
            close(context, student);
          },
        );
      },
    );
  }
}
