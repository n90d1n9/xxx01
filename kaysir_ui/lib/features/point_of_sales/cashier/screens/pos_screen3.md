import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../cashier/providers/pos_provider2.dart'2.dart';

class POSScreen extends ConsumerWidget {
  const POSScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posState = ref.watch(posProvider);

    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            // Enhanced keyboard shortcuts
            if (event.isControlPressed) {
              return _handleControlShortcuts(event, ref);
            }
            if (event.isAltPressed) {
              return _handleAltShortcuts(event, ref);
            }
            
            // Mode-specific shortcuts
            if (posState.isPaymentMode) {
              return _handlePaymentModeShortcuts(event, ref);
            }
            if (posState.isDiscountMode) {
              return _handleDiscountModeShortcuts(event, ref);
            }

            // Global shortcuts
            return _handleGlobalShortcuts(event, ref);
          }
          return KeyEventResult.ignored;
        },
        child: Column(
          children: [
            _buildTopBar(posState),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildProductSection(posState),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildCartSection(posState),
                  ),
                ],
              ),
            ),
            _buildBottomBar(posState),
          ],
        ),
      ),
    );
  }

  KeyEventResult _handleControlShortcuts(KeyEvent event, WidgetRef ref) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyP:
        // Ctrl + P: Print last receipt
        return KeyEventResult.handled;
      case LogicalKeyboardKey.keyF:
        // Ctrl + F: Quick search
        return KeyEventResult.handled;
      case LogicalKeyboardKey.keyR:
        // Ctrl + R: View recent transactions
        return KeyEventResult.handled;
      // Add more control shortcuts...
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleAltShortcuts(KeyEvent event, WidgetRef ref) {
    // Quick product selection using Alt + Letter
    if (event.logicalKey.keyLabel.length == 1) {
      final letter = event.logicalKey.keyLabel.toUpperCase();
      // Implement quick product selection
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleDiscountModeShortcuts(KeyEvent event, WidgetRef ref) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.percent:
        // Apply percentage discount
        return KeyEventResult.handled;
      case LogicalKeyboardKey.dollar:
        // Apply flat discount
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        // Exit discount mode
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // ... Implement remaining UI building methods ...
}
