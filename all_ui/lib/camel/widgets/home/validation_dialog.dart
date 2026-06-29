import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/validation_error.dart';

class ValidationDialog extends ConsumerWidget {
  final List<ValidationError> errors;
  const ValidationDialog({super.key, required this.errors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            errors.isEmpty ? Icons.check_circle : Icons.error,
            color: errors.isEmpty ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(errors.isEmpty ? 'Validation Passed' : 'Validation Issues'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child:
            errors.isEmpty
                ? const Text('No validation errors found!')
                : ListView.builder(
                  shrinkWrap: true,
                  itemCount: errors.length,
                  itemBuilder: (context, index) {
                    final error = errors[index];
                    return ListTile(
                      leading: Icon(
                        error.severity == 'error' ? Icons.error : Icons.warning,
                        color:
                            error.severity == 'error'
                                ? Colors.red
                                : Colors.orange,
                      ),
                      title: Text(error.message),
                      subtitle: Text('Node: ${error.nodeId}'),
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
