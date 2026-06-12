import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../cart/states/cart_providers.dart';
import '../../../cart/widgets/cart_panel.dart';
import '../../../product/screens/product_panel.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  POSScreenState createState() => POSScreenState();
}

class POSScreenState extends ConsumerState<POSScreen> {
  late FocusNode _barcodeNode;
  String _barcodeBuffer = '';
  Timer? _barcodeTimer;

  @override
  void initState() {
    super.initState();
    _barcodeNode = FocusNode();
    _barcodeNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
  /*   final inventory = ref.watch(inventoryProvider);
    final settings = ref.watch(settingsProvider);
 */
    return KeyboardListener(
      focusNode: _barcodeNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          _handleKeyPress(event);
        }
      },
      child: Scaffold(
        body: Row(
          children: [
            // Left Panel - Product Grid/Categories
            Expanded(
              flex: 2,
              child: ProductPanel(),
            ),
            // Right Panel - Cart & Payment
            Expanded(
              child: CartPanel(),
            ),
          ],
        ),
      ),
    );
  }

  void _handleKeyPress(KeyDownEvent event) {
    // Handle barcode scanner input
    if (event.logicalKey.keyLabel.length == 1) {
      _barcodeBuffer += event.logicalKey.keyLabel;
      _barcodeTimer?.cancel();
      _barcodeTimer = Timer(Duration(milliseconds: 100), () {
        if (_barcodeBuffer.length > 5) {
          //ref.read(cartProvider.notifier).addItemByBarcode(_barcodeBuffer);
        }
        _barcodeBuffer = '';
      });
    }

    // Handle keyboard shortcuts
    /* final shortcuts = ref.read(settingsProvider).shortcuts;
    for (var shortcut in shortcuts.entries) {
      if (_matchesShortcut(event, shortcut.value)) {
        _executeShortcut(shortcut.key);
        return;
      }
    } */
  }
}
