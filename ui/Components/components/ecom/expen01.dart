import 'package:flutter/material.dart';

class ExpensePage extends StatelessWidget {
  const ExpensePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: const Text('Expense'),
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
                    backgroundColor: Colors.grey[300],
                  ),
                  child: const Text('Income'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Expense'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                  ),
                  child: const Text('Transfer'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              initialValue: '10/14/20 (Wed) 5:30 PM',
              decoration: const InputDecoration(
                labelText: 'Date',
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              initialValue: 'Cash',
              decoration: const InputDecoration(
                labelText: 'Account',
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              initialValue: 'Food/Eating out',
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              initialValue: '\$ 16.55',
              decoration: const InputDecoration(
                labelText: 'Amount',
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              initialValue: 'Fried Chicken',
              decoration: const InputDecoration(
                labelText: 'Note',
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16.0),
            const Text('Description'),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.asset('assets/fried_chicken.jpg'),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.asset('assets/receipt.jpg'),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}