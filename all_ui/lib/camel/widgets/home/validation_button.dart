import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../states/validation_error_provider.dart';

class ValidationButton extends ConsumerWidget {
  final VoidCallback onPressed;

  const ValidationButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errors = ref.watch(validationErrorsProvider);

    return IconButton(
      icon: Icon(
        Icons.check_circle,
        color: errors.isEmpty ? Colors.green : Colors.red,
      ),
      onPressed: onPressed,
      tooltip: 'Validate Route',
    );
  }
}
