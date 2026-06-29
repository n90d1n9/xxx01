
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryPeriodePage extends ConsumerWidget {
  const InventoryPeriodePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Periode',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nama'),
                Text('Awal'),
                Text('Beli'),
                Text('Kurang'),
                Text('Akhir'),
                Text('Pakai'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '11 Aug 2023',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ppp (Burung)',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('20'),
                Text('0'),
                Text('0'),
                Text('0'),
                Text('-'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Send Report By Email'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Email Destination',
                              prefixIcon: Icon(Icons.email),
                            ),
                            onChanged: (value) {
                              // Validate email here
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '*Use comma + space (,) to add email destination',
                            style: TextStyle(fontSize: 12),
                          ),
                          const Text(
                            '*example: test1@email.com, test2@email.com',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Send email here
                            Navigator.of(context).pop();
                          },
                          child: const Text('Send'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Send Report By Email'),
            ),
          ],
        ),
      ),
    );
  }
}


class SendReportByEmail extends ConsumerWidget {
  const SendReportByEmail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Send Report By Email'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Email Destination',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '*Use comma + space (,) to add email destination',
            style: TextStyle(fontSize: 12),
          ),
          Text(
            '*example: test1@email.com, test2@email.com',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Send email report
            // ...
            Navigator.of(context).pop();
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}
