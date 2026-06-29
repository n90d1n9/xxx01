import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Mpos extends ConsumerWidget {
  const Mpos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('mPOS'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Scan Item',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Scan'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'DELIVERY',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Dozen Oranges'),
                    trailing: Text('\$3.79'),
                  ),
                  ListTile(
                    title: Text('Chicken With Seasoning'),
                    trailing: Text('\$4.79'),
                  ),
                  ListTile(
                    title: Text('Extra Powdered Seasoning'),
                    trailing: Text('\$0.59'),
                  ),
                  ListTile(
                    title: Text('Extra Lemon Juice Marinade'),
                    trailing: Text('\$0.59'),
                  ),
                  ListTile(
                    title: Text('Lamb Chops'),
                    trailing: Text('\$8.99'),
                  ),
                  ListTile(
                    title: Text('Avacados'),
                    trailing: Text('\$2.79'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Sub Total'),
                    trailing: Text('\$1.79'),
                  ),
                  ListTile(
                    title: Text('Tax'),
                    trailing: Text('\$0.33'),
                  ),
                  ListTile(
                    title: Text('Tip'),
                    trailing: Text('\$0.02'),
                  ),
                  ListTile(
                    title: Text('Service Fee'),
                    trailing: Text('\$0.80'),
                  ),
                  ListTile(
                    title: Text('Small Order Fee'),
                    trailing: Text('\$2.50'),
                  ),
                  ListTile(
                    title: Text('Delivery Fee'),
                    trailing: Text('\$2.50'),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text('\$12.50', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('SAVE'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('PAY \$12.50'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Icon(Icons.grid_view),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Icon(Icons.receipt_long),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Icon(Icons.shopping_cart),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Icon(Icons.restaurant_menu),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Icon(Icons.pause_circle),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('VOID'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('No Sales'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Icon(Icons.money),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Price Check'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Speed Key',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Depts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Orders',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Table Orders',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Hold',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Void',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'No Sales',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Refund',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Price Check',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Image.asset('assets/images/speed_key.png'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Image.asset('assets/images/depts.png'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Image.asset('assets/images/orders.png'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Image.asset('assets/images/table_orders.png'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Image.asset('assets/images/hold.png'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Image.asset('assets/images/void.png'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Image.asset('assets/images/no_sales.png'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Image.asset('assets/images/refund.png'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Image.asset('assets/images/price_check.png'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
