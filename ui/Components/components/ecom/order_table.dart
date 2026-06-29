import 'package:flutter/material.dart';

class OngoingOrders extends StatefulWidget {
  const OngoingOrders({Key? key}) : super(key: key);

  @override
  State<OngoingOrders> createState() => _OngoingOrdersState();
}

class _OngoingOrdersState extends State<OngoingOrders> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Orders'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                OrderCard(
                  tableName: 'Table No. 1',
                  dateTime: 'Tue, 20 Sep 22 - 19:19',
                  items: [
                    OrderItem(quantity: 12, name: 'Coca Cola'),
                    OrderItem(quantity: 1, name: 'Chicken Nuggets'),
                  ],
                ),
                OrderCard(
                  tableName: 'Table No. 3',
                  dateTime: 'Tue, 20 Sep 22 - 19:42',
                  items: [
                    OrderItem(quantity: 3, name: 'Coca Cola'),
                    OrderItem(quantity: 1, name: 'French Fries'),
                    OrderItem(quantity: 1, name: 'American Steak'),
                    OrderItem(quantity: 2, name: 'Lemon Tea with ice'),
                    OrderItem(quantity: 1, name: 'Chicken Nuggets extra sauce'),
                  ],
                ),
                OrderCard(
                  tableName: 'Caroline Ann',
                  dateTime: 'Tue, 20 Sep 22 - 19:43',
                  items: [
                    OrderItem(quantity: 1, name: 'Italian Pizza'),
                    OrderItem(quantity: 5, name: 'Burger'),
                    OrderItem(quantity: 3, name: 'Coca Cola'),
                    OrderItem(quantity: 1, name: 'American Steak'),
                    OrderItem(quantity: 1, name: 'Coffe'),
                    OrderItem(quantity: 2, name: 'French Fries'),
                    OrderItem(quantity: 1, name: 'Lemon Tea'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String tableName;
  final String dateTime;
  final List<OrderItem> items;

  const OrderCard({
    Key? key,
    required this.tableName,
    required this.dateTime,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tableName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dateTime,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Text('${item.quantity}  '),
                      Text(item.name),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Payment'),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderItem {
  final int quantity;
  final String name;

  OrderItem({
    required this.quantity,
    required this.name,
  });
}