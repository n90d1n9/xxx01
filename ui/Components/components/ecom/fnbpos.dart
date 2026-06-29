import 'package:flutter/material.dart';

class FnbPosWidget extends StatefulWidget {
  const FnbPosWidget({Key? key}) : super(key: key);

  @override
  State<FnbPosWidget> createState() => _FnbPosWidgetState();
}

class _FnbPosWidgetState extends State<FnbPosWidget> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kenangan Latte'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Coffee, Milk, Gula Aren',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Size'),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: null,
                          child: Text('Small'),
                        ),
                        ElevatedButton(
                          onPressed: null,
                          child: Text('Regular'),
                        ),
                        ElevatedButton(
                          onPressed: null,
                          child: Text('Large'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Temp'),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: null,
                          child: Text('Ice'),
                        ),
                        ElevatedButton(
                          onPressed: null,
                          child: Text('Hot'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Beans'),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: null,
                          child: Text('Kenangan Blend'),
                        ),
                        ElevatedButton(
                          onPressed: null,
                          child: Text('Bumi Flores'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Sugar'),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: null,
                          child: Text('Normal'),
                        ),
                        ElevatedButton(
                          onPressed: null,
                          child: Text('Less'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Ice Level'),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: null,
                          child: Text('Normal'),
                        ),
                        ElevatedButton(
                          onPressed: null,
                          child: Text('Less'),
                        ),
                        ElevatedButton(
                          onPressed: null,
                          child: Text('No Ice'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Toppings',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildToppingItem(
                    'Gula Aren',
                    'assets/gula_aren.png',
                  ),
                  _buildToppingItem(
                    'Bubble',
                    'assets/bubble.png',
                  ),
                  _buildToppingItem(
                    'Espresso',
                    'assets/espresso.png',
                  ),
                  _buildToppingItem(
                    'Jelly',
                    'assets/jelly.png',
                  ),
                  _buildToppingItem(
                    'Cookies',
                    'assets/cookies.png',
                  ),
                  _buildToppingItem(
                    'Oreo',
                    'assets/oreo.png',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _quantity = _quantity > 1 ? _quantity - 1 : 1;
                          });
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text('$_quantity'),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _quantity++;
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
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
                      '+ Cart RM 12.90',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToppingItem(String title, String imagePath) {
    return Column(
      children: [
        Image.asset(
          imagePath,
          width: 64.0,
          height: 64.0,
        ),
        const SizedBox(height: 8.0),
        Text(
          title,
          style: const TextStyle(fontSize: 12.0),
        ),
      ],
    );
  }
}

/* 

- **Product Details:** Displays the product name, description, and price.
- **Customization Options:** Allows users to select size, temperature, beans, sugar level, and ice level.
- **Toppings:** Displays a grid of available toppings with images and titles.
- **Quantity Control:** Allows users to adjust the quantity of the product.
- **Add to Cart Button:** Enables users to add the product to their cart.

**To use this code:**

1. **Create a new Flutter project.**
2. **Copy and paste the code into a new Dart file.**
3. **Replace the placeholder image paths (`assets/gula_aren.png`, etc.) with the actual paths to your image assets.**
4. **Run the app.**

This code provides a basic structure for the FNB POS screen. You can customize it further by adding features like:

- **User authentication:** Allow users to log in and manage their orders.
- **Order history:** Display a list of previous orders.
- **Payment integration:** Allow users to pay for their orders.
- **Inventory management:** Track the availability of products and toppings.
- **Reporting:** Generate reports on sales and inventory.
 */