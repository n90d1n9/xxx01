import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 16.0),
                  ),
                  child: const Text('Today'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 16.0),
                  ),
                  child: const Text('This Week'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 16.0),
                  ),
                  child: const Text('This Month'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 16.0),
                  ),
                  child: const Text('More'),
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            const Text(
              '11 Aug 2023',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32.0),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: const [
                  ReportCard(
                    icon: Icons.receipt_long,
                    title: 'Summary Report',
                  ),
                  ReportCard(
                    icon: Icons.people,
                    title: 'Waiter Performance',
                  ),
                  ReportCard(
                    icon: Icons.payment,
                    title: 'Cashier Report',
                  ),
                  ReportCard(
                    icon: Icons.shopping_cart,
                    title: 'Sales Report',
                  ),
                  ReportCard(
                    icon: Icons.tune,
                    title: 'Stock Report',
                  ),
                  ReportCard(
                    icon: Icons.cancel_presentation,
                    title: 'Cancel Transaction',
                  ),
                  ReportCard(
                    icon: Icons.fastfood,
                    title: 'Product Report',
                  ),
                  ReportCard(
                    icon: Icons.hourglass_empty,
                    title: 'Served Late Report',
                  ),
                  ReportCard(
                    icon: Icons.shopping_bag,
                    title: 'Inventory',
                  ),
                  ReportCard(
                    icon: Icons.money,
                    title: 'Income & Expense',
                  ),
                  ReportCard(
                    icon: Icons.access_time,
                    title: 'Peak Time Report',
                  ),
                  ReportCard(
                    icon: Icons.timer,
                    title: 'Duration Report',
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

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48.0,
              color: Colors.white,
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}