import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopUI extends ConsumerWidget {
  const DesktopUI({Key? key}) : super(key: key);

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Scan Item
            Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Scan Item',
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Scan'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Delivery
            const Text(
              'DELIVERY',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),

            // Items
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: const [
                  // Item 1
                  ItemWidget(
                    itemName: 'Dozen Oranges',
                    itemPrice: '\$3.79',
                    quantity: 1,
                  ),
                  // Item 2
                  ItemWidget(
                    itemName: 'Chicken With Seasoning',
                    itemPrice: '\$4.79',
                    quantity: 1,
                  ),
                  // Item 3
                  ItemWidget(
                    itemName: 'Extra Powdered Seasoning',
                    itemPrice: '\$0.59',
                    quantity: 1,
                  ),
                  // Item 4
                  ItemWidget(
                    itemName: 'Extra Lemon Juice Marinade',
                    itemPrice: '\$0.59',
                    quantity: 1,
                  ),
                  // Item 5
                  ItemWidget(
                    itemName: 'Lamb Chops',
                    itemPrice: '\$8.99',
                    quantity: 5,
                  ),
                  // Item 6
                  ItemWidget(
                    itemName: 'Avacados',
                    itemPrice: '\$2.79',
                    quantity: 3,
                  ),
                  // Item 7
                  ItemWidget(
                    itemName: 'Orange',
                    itemPrice: '',
                    quantity: 0,
                    image: AssetImage('assets/images/orange.png'),
                  ),
                  // Item 8
                  ItemWidget(
                    itemName: 'Mango',
                    itemPrice: '',
                    quantity: 0,
                    image: AssetImage('assets/images/mango.png'),
                  ),
                  // Item 9
                  ItemWidget(
                    itemName: 'Strawberry',
                    itemPrice: '',
                    quantity: 0,
                    image: AssetImage('assets/images/strawberry.png'),
                  ),
                  // Item 10
                  ItemWidget(
                    itemName: 'Grapes',
                    itemPrice: '',
                    quantity: 0,
                    image: AssetImage('assets/images/grapes.png'),
                  ),
                  // Item 11
                  ItemWidget(
                    itemName: 'Avocado',
                    itemPrice: '',
                    quantity: 0,
                    image: AssetImage('assets/images/avocado.png'),
                  ),
                  // Item 12
                  ItemWidget(
                    itemName: 'Pomegranate',
                    itemPrice: '',
                    quantity: 0,
                    image: AssetImage('assets/images/pomegranate.png'),
                  ),
                  // Item 13
                  ItemWidget(
                    itemName: 'Coconut',
                    itemPrice: '',
                    quantity: 0,
                    image: AssetImage('assets/images/coconut.png'),
                  ),
                  // Item 14
                  ItemWidget(
                    itemName: 'Tomato',
                    itemPrice: '',
                    quantity: 0,
                    image: AssetImage('assets/images/tomato.png'),
                  ),
                  // Item 15
                  ItemWidget(
                    itemName: 'Cucumber',
                    itemPrice: '',
                    quantity: 0,
                    image: AssetImage('assets/images/cucumber.png'),
                  ),
                  // Item 16
                  ItemWidget(
                    itemName: 'Pineapple',
                    itemPrice: '',
                    quantity: 0,
                    image: AssetImage('assets/images/pineapple.png'),
                  ),
                  // Item 17
                  ItemWidget(
                    itemName: 'Pumpkin',
                    itemPrice: '',
                    quantity: 0,
                    image: AssetImage('assets/images/pumpkin.png'),
                  ),
                  // Item 18
                  ItemWidget(
                    itemName: 'Papaya',
                    itemPrice: '',
                    quantity: 0,
                    image: AssetImage('assets/images/papaya.png'),
                  ),
                  // Item 19
                  ItemWidget(
                    itemName: 'Beef',
                    itemPrice: '',
                    quantity: 0,
                    image: AssetImage('assets/images/beef.png'),
                  ),
                  // Item 20
                  ItemWidget(
                    itemName: 'Lamb',
                    itemPrice: '',
                    quantity: 0,
                    image: AssetImage('assets/images/lamb.png'),
                  ),
                  // Item 21
                  ItemWidget(
                    itemName: 'Chicken',
                    itemPrice: '',
                    quantity: 0,
                    image: AssetImage('assets/images/chicken.png'),
                  ),
                  // Item 22
                  ItemWidget(
                    itemName: 'Duck Meat',
                    itemPrice: '',
                    quantity: 0,
                    image: AssetImage('assets/images/duck_meat.png'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // Total
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$12.50',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('SAVE'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('PAY \$12.50'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Bottom Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Speed Key
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.grid_view),
                  tooltip: 'Speed Key',
                ),
                // Depts
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.list),
                  tooltip: 'Depts',
                ),
                // Orders
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart),
                  tooltip: 'Orders',
                ),
                // Table Orders
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.restaurant_menu),
                  tooltip: 'Table Orders',
                ),
                // Hold
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.pause_circle),
                  tooltip: 'Hold',
                ),
                // Void
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.cancel),
                  tooltip: 'Void',
                ),
                // No Sales
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.no_accounts),
                  tooltip: 'No Sales',
                ),
                // Refund
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.money_off),
                  tooltip: 'Refund',
                ),
                // Price Check
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle),
                  tooltip: 'Price Check',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    Key? key,
    required this.itemName,
    required this.itemPrice,
    required this.quantity,
    this.image,
  }) : super(key: key);

  final String itemName;
  final String itemPrice;
  final int quantity;
  final AssetImage? image;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         // if (image != null) image,
          const SizedBox(height: 8.0),
          Text(
            itemName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            '$quantity x $itemPrice',
            style: const TextStyle(
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}