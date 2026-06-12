import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

class BarcodeService {
  static const supportedFormats = [
    BarcodeFormat.ean8,
    BarcodeFormat.ean13,
    BarcodeFormat.upcA,
    BarcodeFormat.upcE,
    BarcodeFormat.qrCode,
    BarcodeFormat.code128,
    BarcodeFormat.code39,
  ];

  final void Function(String) onBarcodeDetected;
  MobileScannerController? _controller;

  BarcodeService({required this.onBarcodeDetected});

  MobileScannerController get controller {
    _controller ??= MobileScannerController(
      formats: supportedFormats,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    return _controller!;
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }

  static Future<ui.Image> generateBarcode({
    required String data,
    required BarcodeFormat format,
    double width = 200,
    double height = 100,
  }) async {
    if (format == BarcodeFormat.qrCode) {
      return QrPainter(
        data: data,
        version: QrVersions.auto,
        gapless: true,
      ).toImage(width);
    } else {
      // For other barcode types, implement using barcode_widget
      // This is a placeholder - implement actual barcode generation
      throw UnimplementedError('Barcode format not supported yet');
    }
  }
}
