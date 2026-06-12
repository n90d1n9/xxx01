import 'package:flutter/material.dart';

import '../widgets/barcode_scanner.dart';

class BarcodeScannerScreen extends StatelessWidget {
  final void Function(String) onBarcodeDetected;

  const BarcodeScannerScreen({
    super.key,
    required this.onBarcodeDetected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode/QR Code'),
      ),
      body: BarcodeScannerWidget(
        onBarcodeDetected: (barcode) {
          onBarcodeDetected(barcode);
          Navigator.of(context).pop();
        },
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}
