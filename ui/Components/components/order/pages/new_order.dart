import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedItemsProvider = StateNotifierProvider<SelectedItemsNotifier, List<String>>((ref) => SelectedItemsNotifier());

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
  final String imagePath;

  const MenuItem({super.key, required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedItems = ref.watch(selectedItemsProvider);
        return GestureDetector(
          onTap: () {
            if (selectedItems.contains(name)) {
              ref.read(selectedItemsProvider.notifier).removeItem(name);
            } else {
              ref.read(selectedItemsProvider.notifier).addItem(name);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: selectedItems.contains(name) ? Border.all(color: Colors.red) : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(imagePath, height: 100, width: 100),
                const SizedBox(height: 10),
                Text(name),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DineInScreen extends StatelessWidget {
  const DineInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Order - Dine In'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('qqqq', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Table No',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MenuItem(name: 'All', imagePath: 'assets/images/all.png'),
                MenuItem(name: 'Main Course', imagePath: 'assets/images/main_course.png'),
                MenuItem(name: 'Beverages', imagePath: 'assets/images/beverages.png'),
                MenuItem(name: 'Dessert', imagePath: 'assets/images/dessert.png'),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: const [
                  MenuItem(name: 'Nasi Goreng', imagePath: 'assets/images/nasi_goreng.jpg'),
                  MenuItem(name: 'Es Teh Manis', imagePath: 'assets/images/es_teh_manis.jpg'),
                  MenuItem(name: 'Bubur Sumsum', imagePath: 'assets/images/bubur_sumsum.jpg'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('SELECTED'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('VIEW STOCK'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('NEXT'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}