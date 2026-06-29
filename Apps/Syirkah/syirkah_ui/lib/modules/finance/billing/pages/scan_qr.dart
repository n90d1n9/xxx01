import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ScanQR extends ConsumerWidget {
  const ScanQR({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Payment Name',
                prefixIcon: Icon(Icons.keyboard),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('QR Code'),
                        SizedBox(height: 8.0),
                        Text('-1'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(width: 16.0),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Scan QR',
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.search),
              ),
              controller: TextEditingController(text: 'Active'),
            ),
            const SizedBox(height: 32.0),
            const Center(
              child: Text(
                'Scan Here To Test',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: QrImageView(
                data: 'https://www.example.com',
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 16.0,
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
