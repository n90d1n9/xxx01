import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OutletOrderWidget extends ConsumerWidget {
  const OutletOrderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outlet Order'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Seq No | Table No | Guest...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dine In', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                      const Text('#1 - qqqq', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.info_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Table No: 3', style: TextStyle(fontSize: 16.0)),
                  const Text('Order Date:', style: TextStyle(fontSize: 16.0)),
                  const Text('11 Aug 2023 05:48', style: TextStyle(fontSize: 16.0)),
                  const SizedBox(height: 16.0),
                  const Text('1 x Es Teh Manis', style: TextStyle(fontSize: 16.0)),
                  const SizedBox(height: 8.0),
                  const Text('2 x Nasi Goreng', style: TextStyle(fontSize: 16.0)),
                  const SizedBox(height: 16.0),
                  const Text('Elapsed Time', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  const Text('2 Hour(s)', style: TextStyle(fontSize: 16.0)),
                  const Text('6 Min(s)', style: TextStyle(fontSize: 16.0)),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Print Kitchen: 0', style: TextStyle(fontSize: 16.0)),
                    Text('Unpaid', style: TextStyle(fontSize: 16.0, color: Colors.red)),
                    Text('0/3 item(s) paid', style: TextStyle(fontSize: 16.0)),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1 x Es Teh Manis', style: TextStyle(fontSize: 16.0)),
                        Text('5.000', style: TextStyle(fontSize: 16.0)),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('2 x Nasi Goreng', style: TextStyle(fontSize: 16.0)),
                        Text('30.000', style: TextStyle(fontSize: 16.0)),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Text('Grand Total', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.0),
                    Text('35.000', style: TextStyle(fontSize: 16.0)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  ),
                  child: const Text('Add Order', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  ),
                  child: const Text('Pay', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  ),
                  child: const Text('More', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}