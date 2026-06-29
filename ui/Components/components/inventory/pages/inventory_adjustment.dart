
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryAdjustmentScreen extends ConsumerWidget {
  const InventoryAdjustmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Adjustment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Beginning Of Day (BOD)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search by Name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: 1, // Replace with actual data
                itemBuilder: (context, index) {
                  return const InventoryItem(
                    name: 'ppp (Bungkus)',
                    beginningOfDay: 0,
                    purchase: 0,
                    reduction: 0,
                    endOfDay: 0,
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.red,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class InventoryItem extends ConsumerWidget {
  const InventoryItem({
    super.key,
    required this.name,
    required this.beginningOfDay,
    required this.purchase,
    required this.reduction,
    required this.endOfDay,
  });

  final String name;
  final int beginningOfDay;
  final int purchase;
  final int reduction;
  final int endOfDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Text('Beginning Of Day'),
                const Spacer(),
                Text('$beginningOfDay'),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Text('Purchase'),
                const Spacer(),
                Text('$purchase'),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Text('Reduction'),
                const Spacer(),
                Text('$reduction'),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Text('End Of Day'),
                const Spacer(),
                Text('$endOfDay'),
              ],
            ),
            const SizedBox(height: 16.0),
            const Row(
              children: [
                Text('Stock Beginning Of Day'),
                Spacer(),
                SizedBox(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryAdjustmentScreen extends ConsumerWidget {
  const InventoryAdjustmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Adjustment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: 'Beginning Of Day (BOD)'),
                      Tab(text: 'End Of Day (EOD)'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // BOD Tab content
                        Container(
                          child: Column(
                            children: [
                              TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Search by Name',
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                              // Add your BOD content here
                            ],
                          ),
                        ),
                        // EOD Tab content
                        Container(
                          child: Column(
                            children: [
                              TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Search by Name',
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                              // Add your EOD content here
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Beginning Of Day (BOD)'),
                Text('End Of Day (EOD)'),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search by Name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Container(
                // Add your inventory list here
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }
} */