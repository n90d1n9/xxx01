import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/terminal.dart';
import '../../order/states/current_order_provider.dart';
import '../states/terminal_provider.dart';
import '../utils/pos_error_copy.dart';

class TerminalSelector extends ConsumerWidget {
  const TerminalSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final terminalsAsync = ref.watch(terminalsProvider);
    final currentTerminal = ref.watch(currentTerminalProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: terminalsAsync.when(
        data: (terminals) {
          return DropdownButton<Terminal>(
            value: currentTerminal,
            hint: const Text('Select Terminal'),
            underline: const SizedBox(),
            items:
                terminals
                    .where((t) => t.isActive)
                    .map(
                      (terminal) => DropdownMenuItem<Terminal>(
                        value: terminal,
                        child: Text(
                          terminal.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (Terminal? value) {
              if (value != null) {
                ref.read(currentTerminalProvider.notifier).state = value;

                // Create a new order when changing terminals
                final currentOrder = ref.read(currentOrderProvider);
                if (currentOrder == null) {
                  ref.read(currentOrderProvider.notifier).createNewOrder(value);
                }
              }
            },
          );
        },
        loading:
            () => const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        error:
            (error, stackTrace) => Tooltip(
              message: friendlyPOSErrorMessage(
                error,
                fallbackMessage: 'Terminals could not be loaded.',
              ),
              child: const Icon(Icons.error_outline, color: Colors.red),
            ),
      ),
    );
  }
}
