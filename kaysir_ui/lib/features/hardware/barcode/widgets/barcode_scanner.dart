import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../services/barcode_services.dart';

class BarcodeScannerWidget extends StatelessWidget {
  final void Function(String) onBarcodeDetected;
  final VoidCallback onClose;

  const BarcodeScannerWidget({
    super.key,
    required this.onBarcodeDetected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller:
              BarcodeService(onBarcodeDetected: onBarcodeDetected).controller,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                onBarcodeDetected(barcode.rawValue!);
                break;
              }
            }
          },
        ),
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onClose,
          ),
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Align barcode within the frame',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
