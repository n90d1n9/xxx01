import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopCheckoutScreen extends ConsumerWidget {
  const DesktopCheckoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scan Item',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DELIVERY',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _OrderItem(
                    name: 'Dozen Oranges',
                    quantity: 1,
                    price: 3.79,
                  ),
                  _OrderItem(
                    name: 'Chicken With Seasoning',
                    quantity: 1,
                    price: 4.79,
                  ),
                  _OrderItem(
                    name: 'Extra Powdered Seasoning',
                    quantity: 1,
                    price: 0.59,
                  ),
                  _OrderItem(
                    name: 'Extra Lemon Juice Marinada',
                    quantity: 1,
                    price: 0.59,
                  ),
                  _OrderItem(
                    name: 'Lamb Chops',
                    quantity: 5,
                    price: 8.99,
                  ),
                  _OrderItem(
                    name: 'Avacados',
                    quantity: 3,
                    price: 2.79,
                  ),
                  SizedBox(height: 16),
                  _OrderSummaryItem(
                    name: 'Sub Total',
                    price: 1.79,
                  ),
                  const _OrderSummaryItem(
                    name: 'Tax',
                    price: 0.33,
                  ),
                  _OrderSummaryItem(
                    name: 'Tip',
                    price: 0.02,
                  ),
                  _OrderSummaryItem(
                    name: 'Service Fee',
                    price: 0.80,
                  ),
                  _OrderSummaryItem(
                    name: 'Small Order Fee',
                    price: 2.50,
                  ),
                  _OrderSummaryItem(
                    name: 'Delivery Fee',
                    price: 2.50,
                  ),
                  SizedBox(height: 16),
                  _OrderSummaryItem(
                    name: 'TOTAL',
                    price: 12.50,
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('SAVE'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('PAY \$12.50'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  const _OrderItem({
    Key? key,
    required this.name,
    required this.quantity,
    required this.price,
  }) : super(key: key);

  final String name;
  final int quantity;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              Text(
                '$quantity',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryItem extends StatelessWidget {
  const _OrderSummaryItem({
    Key? key,
    required this.name,
    required this.price,
    this.isTotal = false,
  }) : super(key: key);

  final String name;
  final double price;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}