import 'package:flutter/material.dart';

class SplitBillWidget extends StatefulWidget {
  const SplitBillWidget({Key? key}) : super(key: key);

  @override
  State<SplitBillWidget> createState() => _SplitBillWidgetState();
}

class _SplitBillWidgetState extends State<SplitBillWidget> {
  int _saltedCaramelLatteCount = 0;
  int _tuttyFruityCheesetartCount = 0;
  int _vanillaLatteCount = 1;
  int _treeCityMochaCount = 0;

  void _incrementCount(String item) {
    setState(() {
      switch (item) {
        case 'Salted Caramel Latte':
          _saltedCaramelLatteCount++;
          break;
        case 'Tutty Fruity Cheesetart':
          _tuttyFruityCheesetartCount++;
          break;
        case 'Vanilla Latte':
          _vanillaLatteCount++;
          break;
        case 'Tree City Mocha':
          _treeCityMochaCount++;
          break;
      }
    });
  }

  void _decrementCount(String item) {
    setState(() {
      switch (item) {
        case 'Salted Caramel Latte':
          if (_saltedCaramelLatteCount > 0) {
            _saltedCaramelLatteCount--;
          }
          break;
        case 'Tutty Fruity Cheesetart':
          if (_tuttyFruityCheesetartCount > 0) {
            _tuttyFruityCheesetartCount--;
          }
          break;
        case 'Vanilla Latte':
          if (_vanillaLatteCount > 0) {
            _vanillaLatteCount--;
          }
          break;
        case 'Tree City Mocha':
          if (_treeCityMochaCount > 0) {
            _treeCityMochaCount--;
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Bill'),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            onPressed: () {
              // Handle close button press
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildItemRow(
              '1x Salted Caramel Latte - Large',
              _saltedCaramelLatteCount,
              'Salted Caramel Latte',
            ),
            _buildItemRow(
              '1x Tutty Fruity Cheesetart',
              _tuttyFruityCheesetartCount,
              'Tutty Fruity Cheesetart',
            ),
            _buildItemRow(
              '1x Vanilla Latte',
              _vanillaLatteCount,
              'Vanilla Latte',
            ),
            _buildItemRow(
              '1x Tree City Mocha',
              _treeCityMochaCount,
              'Tree City Mocha',
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Handle confirm button press
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(String itemName, int count, String item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(itemName),
        Row(
          children: [
            IconButton(
              onPressed: () => _decrementCount(item),
              icon: const Icon(Icons.remove),
            ),
            Text('$count'),
            IconButton(
              onPressed: () => _incrementCount(item),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}