import 'package:flutter/material.dart';

import 'inventory_form_fields.dart';

class InventoryProductScanCodeFields extends StatelessWidget {
  const InventoryProductScanCodeFields({
    super.key,
    required this.barcodeController,
    required this.shortcutKeyController,
    required this.barcodeFocusNode,
    required this.shortcutKeyFocusNode,
    required this.onChanged,
  });

  final TextEditingController barcodeController;
  final TextEditingController shortcutKeyController;
  final FocusNode barcodeFocusNode;
  final FocusNode shortcutKeyFocusNode;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final barcodeField = InventoryFormTextField(
      key: const ValueKey('inventory-product-dialog-barcode-field'),
      controller: barcodeController,
      focusNode: barcodeFocusNode,
      label: 'Barcode',
      icon: Icons.qr_code_scanner_rounded,
      onChanged: (_) => onChanged(),
    );
    final shortcutField = InventoryFormTextField(
      key: const ValueKey('inventory-product-dialog-shortcut-key-field'),
      controller: shortcutKeyController,
      focusNode: shortcutKeyFocusNode,
      label: 'Shortcut key',
      icon: Icons.keyboard_rounded,
      onChanged: (_) => onChanged(),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: [barcodeField, const SizedBox(height: 12), shortcutField],
          );
        }

        return Row(
          children: [
            Expanded(child: barcodeField),
            const SizedBox(width: 12),
            Expanded(child: shortcutField),
          ],
        );
      },
    );
  }
}
