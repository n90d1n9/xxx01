import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrintSelfOrderQrCode extends ConsumerWidget {
  const PrintSelfOrderQrCode({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Self Order QR Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('QR Code Per Table'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('QR Code Self Service'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Table Start'),
                    SizedBox(height: 8.0),
                    Text('1'),
                    SizedBox(height: 16.0),
                    Text('Total Table : 23'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Table End'),
                    SizedBox(height: 8.0),
                    Text('1'),
                    SizedBox(height: 16.0),
                    Text('Total Table : 23'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Print Qr Code'),
            ),
          ],
        ),
      ),
    );
  }
}