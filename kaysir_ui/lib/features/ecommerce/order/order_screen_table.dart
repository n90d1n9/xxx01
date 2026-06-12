import 'package:flutter/material.dart';

import '../../table/table_pagination/table_pagination.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Orders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            FilledButton(onPressed: () {}, child: const Text('Create Order')),
          ],
        ),
        const SizedBox(height: 16),

        // Orders table
        TablePagination(),
      ],
    );
  }
}
