import 'package:flutter/material.dart';

import '../schema/validation_result.dart';

class ValidationResultDialog extends StatelessWidget {
  final ValidationResult result;

  const ValidationResultDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            result.isValid ? Icons.check_circle : Icons.error,
            color: result.isValid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Text(result.isValid ? 'Validation Passed' : 'Validation Failed'),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 400,
        child:
            result.issues.isEmpty
                ? const Center(child: Text('No issues found'))
                : ListView.builder(
                  itemCount: result.issues.length,
                  itemBuilder: (context, index) {
                    final issue = result.issues[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(issue.icon, color: issue.color),
                        title: Text(issue.message),
                        subtitle: Text(issue.category.name),
                      ),
                    );
                  },
                ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
