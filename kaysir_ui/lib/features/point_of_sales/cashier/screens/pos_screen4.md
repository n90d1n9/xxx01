import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';


import '../../../cashier/providers/pos_provider2.dart'2.dart';
import '../../../cashier/providers/pos_states.dart's.dart';

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
            // Payment mode shortcuts
            if (posState.isPaymentMode) {
              return _handlePaymentModeShortcuts(event, ref);
            }

            // Normal mode shortcuts
            return _handleNormalModeShortcuts(event, ref);
          }
          return KeyEventResult.ignored;
        },
        child: Row(
          children: [
            // Products list (left side)
            Expanded(
              flex: 2,
              child: _buildProductsList(posState),
            ),
            // Cart (right side)
            Expanded(
              flex: 1,
              child: _buildCart(posState),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.grey[200],
        child: Text(
          'Last action: ${posState.lastAction}\n'
          'Shortcuts: F1-Help, F2-Payment, F3-Search, F4-Discount, '
          'F5-Clear Cart, ↑↓-Navigate, Enter-Select, Esc-Cancel',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  KeyEventResult _handlePaymentModeShortcuts(KeyEvent event, WidgetRef ref) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      ref.read(posProvider.notifier).togglePaymentMode();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      ref.read(posProvider.notifier).processPayment();
      return KeyEventResult.handled;
    }

    // Number keys for quick amount selection
    if (event.logicalKey.keyLabel.length == 1 &&
        RegExp(r'[0-9]').hasMatch(event.logicalKey.keyLabel)) {
      // Implement quick amount selection
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  KeyEventResult _handleNormalModeShortcuts(KeyEvent event, WidgetRef ref) {
    // Function key shortcuts
    if (event.logicalKey == LogicalKeyboardKey.f1) {
      _showHelpDialog(ref.context);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.f2) {
      ref.read(posProvider.notifier).togglePaymentMode();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.f3) {
      _focusSearch(ref.context);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.f4) {
      ref.read(posProvider.notifier).toggleDiscountMode();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.f5) {
      ref.read(posProvider.notifier).clearCart();
      return KeyEventResult.handled;
    }

    // Quantity shortcuts with modifier keys
    /* if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.equal) {
      // Increment quantity of selected item
      return KeyEventResult.handled;
    }
    if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.minus) {
      // Decrement quantity of selected item
      return KeyEventResult.handled;
    } */

    if (event.logicalKey == LogicalKeyboardKey.f12) {
      _openCashDrawer();
      return KeyEventResult.handled;
    }

    /* if (event.isAltPressed && event.logicalKey.keyLabel.length == 1) {
      _quickSelectProduct(event.logicalKey.keyLabel);
      return KeyEventResult.handled;
    }
 */
    return KeyEventResult.ignored;
  }

  void _handleBarcodeInput(String barcode) {
    // Look up product by barcode and add to cart
  }

  Widget _buildProductsList(POSState state) {
    // Implement your products grid/list here
    return Container(
      color: Colors.white,
      child: const Center(
        child: Text('Products List - F3 to search'),
      ),
    );
  }

  Widget _buildCart(POSState state) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: state.cart.length,
              itemBuilder: (context, index) {
                final item = state.cart[index];
                return ListTile(
                  title: Text(item.name!),
                  subtitle: Text('${item.quantity} x \$${item.price}'),
                  trailing: Text('\$${item.total}'),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Total: \$${state.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.isPaymentMode)
                  const Text('Payment Mode - Press Enter to confirm'),
                if (state.isDiscountMode)
                  const Text('Discount Mode - Enter amount'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keyboard Shortcuts'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('F1 - Show this help'),
            Text('F2 - Toggle payment mode'),
            Text('F3 - Search products'),
            Text('F4 - Toggle discount mode'),
            Text('F5 - Clear cart'),
            Text('Ctrl + + - Increase quantity'),
            Text('Ctrl + - - Decrease quantity'),
            Text('Enter - Confirm selection/payment'),
            Text('Esc - Cancel/Back'),
            Text('↑↓ - Navigate items'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _focusSearch(BuildContext context) {
    // Implement search focus logic
  }

  void _openCashDrawer() {}

  void _quickSelectProduct(String keyLabel) {}
}
