import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final selectedItemsProvider =
    StateNotifierProvider<SelectedItemsNotifier, List<String>>(
        (ref) => SelectedItemsNotifier());

class SelectedItemsNotifier extends StateNotifier<List<String>> {
  SelectedItemsNotifier() : super([]);

  void addItem(String item) {
    state = [...state, item];
  }

  void removeItem(String item) {
    state = state.where((element) => element != item).toList();
  }
}

class MenuItem extends StatelessWidget {
  final String name;
  final String category;
  final String price;
  final int maxQuantity;
  final String imagePath;

  const MenuItem({
    super.key,
    required this.name,
    required this.category,
    required this.price,
    required this.maxQuantity,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedItems = ref.watch(selectedItemsProvider);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Image.asset(imagePath, width: 80, height: 80),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        ref
                            .read(selectedItemsProvider.notifier)
                            .removeItem(name);
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      selectedItems
                          .where((element) => element == name)
                          .length
                          .toString(),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (selectedItems
                                .where((element) => element == name)
                                .length <
                            maxQuantity) {
                          ref
                              .read(selectedItemsProvider.notifier)
                              .addItem(name);
                        }
                      },
                      icon: const Icon(Icons.add),
                    ),
                    Text(
                      'Max: $maxQuantity',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SplitBillScreen extends ConsumerWidget {
  const SplitBillScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Bill'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('All'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Main Course'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Beverages'),
                  ),
                ],
              ),
            ),
            const MenuItem(
              name: 'Nasi Goreng',
              category: 'Main Course',
              price: '15.000/porsi',
              maxQuantity: 2,
              imagePath: 'assets/nasi_goreng.jpg',
            ),
            const MenuItem(
              name: 'Es Teh Manis',
              category: 'Beverages',
              price: '5.000/gelas',
              maxQuantity: 1,
              imagePath: 'assets/es_teh_manis.jpg',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('SELECTED'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }
}
