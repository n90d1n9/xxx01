import 'package:flutter/material.dart';

class TableBook extends StatefulWidget {
  const TableBook({Key? key}) : super(key: key);

  @override
  State<TableBook> createState() => _TableBookState();
}

class _TableBookState extends State<TableBook> {
  List<TableStatus> tables = [
    TableStatus(number: 1, status: TableStatus.running),
    TableStatus(number: 2, status: TableStatus.blank),
    TableStatus(number: 3, status: TableStatus.blank),
    TableStatus(number: 4, status: TableStatus.blank),
    TableStatus(number: 5, status: TableStatus.reserve),
    TableStatus(number: 6, status: TableStatus.reserve),
    TableStatus(number: 7, status: TableStatus.running),
    TableStatus(number: 8, status: TableStatus.blank),
    TableStatus(number: 9, status: TableStatus.running),
    TableStatus(number: 10, status: TableStatus.blank),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table View'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.list),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: TableStatus.blank,
                      groupValue: null,
                      onChanged: (value) {},
                    ),
                    const Text('Blank'),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: TableStatus.running,
                      groupValue: null,
                      onChanged: (value) {},
                    ),
                    const Text('Running'),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: TableStatus.reserve,
                      groupValue: null,
                      onChanged: (value) {},
                    ),
                    const Text('Reserve'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              padding: const EdgeInsets.all(16.0),
              children: tables.map((table) {
                return TableCard(table: table);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class TableCard extends StatelessWidget {
  const TableCard({Key? key, required this.table}) : super(key: key);

  final TableStatus table;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: table.status == TableStatus.blank
            ? Colors.white
            : table.status == TableStatus.running
                ? Colors.lightBlue[100]
                : Colors.pink[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Table# ${table.number}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text(table.status.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class TableStatus {
  static const String blank = 'Blank';
  static const String running = 'Running';
  static const String reserve = 'Reserve';

  final int number;
  final String status;

  const TableStatus({required this.number, required this.status});
}