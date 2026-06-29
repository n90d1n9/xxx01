import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final tableStateProvider = StateNotifierProvider<TableState, List<int>>(
  (ref) => TableState(),
);

class TableState extends StateNotifier<List<int>> {
  TableState() : super(List.generate(23, (index) => index + 1));

  void toggleTable(int tableNumber) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == tableNumber - 1) state[i] * -1 else state[i]
    ];
  }
}

class TableLayout extends ConsumerWidget {
  const TableLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(tableStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Layout'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Color Info',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Row(
                  children: [
                    Radio<int>(
                      value: 0,
                      groupValue: null,
                      onChanged: (value) {},
                    ),
                    const Text('Empty Table'),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Radio<int>(
                      value: 1,
                      groupValue: null,
                      onChanged: (value) {},
                    ),
                    const Text('Selected Table'),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Radio<int>(
                      value: 2,
                      groupValue: null,
                      onChanged: (value) {},
                    ),
                    const Text('≤ 10 minutes'),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Radio<int>(
                      value: 3,
                      groupValue: null,
                      onChanged: (value) {},
                    ),
                    const Text('> 60 minutes'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: List.generate(23, (index) {
                return InkWell(
                  onTap: () {
                    ref
                        .read(tableStateProvider.notifier)
                        .toggleTable(index + 1);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: tableState[index] > 0
                          ? Colors.white
                          : tableState[index] < 0
                              ? Colors.red
                              : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: tableState[index] > 0
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('New Order'),
            ),
          ],
        ),
      ),
    );
  }
}
