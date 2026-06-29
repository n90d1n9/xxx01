import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelfOrderScreen extends ConsumerWidget {
  const SelfOrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Self Order'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Waiting'),
              Tab(text: 'Dismissed'),
              Tab(text: 'Processed'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WaitingTab(),
            DismissedTab(),
            ProcessedTab(),
          ],
        ),
      ),
    );
  }
}

class WaitingTab extends ConsumerWidget {
  const WaitingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Guest Name | Table No',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ref.watch(waitingOrdersProvider).when(
            data: (orders) {
              if (orders.isEmpty) {
                return const Center(child: Text('No Data'));
              } else {
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(orders[index].guestName),
                      subtitle: Text(orders[index].tableNo),
                    );
                  },
                );
              }
            },
            error: (error, stackTrace) {
              return Center(child: Text('Error: $error'));
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }
}

class DismissedTab extends ConsumerWidget {
  const DismissedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Guest Name | Table No',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ref.watch(dismissedOrdersProvider).when(
            data: (orders) {
              if (orders.isEmpty) {
                return const Center(child: Text('No Data'));
              } else {
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(orders[index].guestName),
                      subtitle: Text(orders[index].tableNo),
                    );
                  },
                );
              }
            },
            error: (error, stackTrace) {
              return Center(child: Text('Error: $error'));
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }
}

class ProcessedTab extends ConsumerWidget {
  const ProcessedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Guest Name | Table No',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ref.watch(processedOrdersProvider).when(
            data: (orders) {
              if (orders.isEmpty) {
                return const Center(child: Text('No Data'));
              } else {
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(orders[index].guestName),
                      subtitle: Text(orders[index].tableNo),
                    );
                  },
                );
              }
            },
            error: (error, stackTrace) {
              return Center(child: Text('Error: $error'));
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }
}

final waitingOrdersProvider = FutureProvider<List<Order>>((ref) async {
  // Fetch waiting orders from your data source
  // Replace this with your actual data fetching logic
  await Future.delayed(const Duration(seconds: 1));
  return [
    Order(guestName: 'John Doe', tableNo: '1'),
    Order(guestName: 'Jane Doe', tableNo: '2'),
  ];
});

final dismissedOrdersProvider = FutureProvider<List<Order>>((ref) async {
  // Fetch dismissed orders from your data source
  // Replace this with your actual data fetching logic
  await Future.delayed(const Duration(seconds: 1));
  return [
    Order(guestName: 'John Doe', tableNo: '1'),
    Order(guestName: 'Jane Doe', tableNo: '2'),
  ];
});

final processedOrdersProvider = FutureProvider<List<Order>>((ref) async {
  // Fetch processed orders from your data source
  // Replace this with your actual data fetching logic
  await Future.delayed(const Duration(seconds: 1));
  return [
    Order(guestName: 'John Doe', tableNo: '1'),
    Order(guestName: 'Jane Doe', tableNo: '2'),
  ];
});

class Order {
  final String guestName;
  final String tableNo;

  Order({required this.guestName, required this.tableNo});
}
