import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:qr_code_tools/qr_code_tools.dart';

class QRFromFileScanner extends StatefulWidget {
  @override
  _QRFromFileScannerState createState() => _QRFromFileScannerState();
}

class _QRFromFileScannerState extends State<QRFromFileScanner> {
  String _qrCodeResult = 'No QR code scanned yet';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      /* try {
        final result = await QrCodeToolsPlugin.decodeFrom(file.path);
        setState(() {
          _qrCodeResult = result!;
        });
      } catch (e) {
        setState(() {
          _qrCodeResult = 'Failed to decode QR code.';
        });
      } */
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code from File'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _qrCodeResult,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image from Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}
