import 'package:flutter/material.dart';

class TablePagination extends StatefulWidget {
  const TablePagination({super.key});

  @override
  State<TablePagination> createState() => _TablePaginationState();
}

class _TablePaginationState extends State<TablePagination> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter and search row
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search orders...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              PopupMenuButton(
                initialValue: 'all',
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'all',
                        child: Text('All Orders'),
                      ),
                      const PopupMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      const PopupMenuItem(
                        value: 'processing',
                        child: Text('Processing'),
                      ),
                      const PopupMenuItem(
                        value: 'shipped',
                        child: Text('Shipped'),
                      ),
                      const PopupMenuItem(
                        value: 'delivered',
                        child: Text('Delivered'),
                      ),
                      const PopupMenuItem(
                        value: 'cancelled',
                        child: Text('Cancelled'),
                      ),
                    ],
                onSelected: (value) {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('All Orders'),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Order ID')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                DataRow(
                  cells: [
                    DataCell(Text('#ORD-2458')),
                    DataCell(Text('John Smith')),
                    DataCell(Text('Mar 15, 2025')),
                    DataCell(Text('\$534.25')),
                    DataCell(
                      Chip(
                        label: Text('Delivered'),
                        backgroundColor: Colors.green,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility_outlined),
                            onPressed: null,
                          ),
                          IconButton(
                            icon: Icon(Icons.edit_outlined),
                            onPressed: null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('#ORD-2457')),
                    DataCell(Text('Emma Johnson')),
                    DataCell(Text('Mar 14, 2025')),
                    DataCell(Text('\$289.99')),
                    DataCell(
                      Chip(
                        label: Text('Processing'),
                        backgroundColor: Colors.blue,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility_outlined),
                            onPressed: null,
                          ),
                          IconButton(
                            icon: Icon(Icons.edit_outlined),
                            onPressed: null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('#ORD-2456')),
                    DataCell(Text('Alex Wong')),
                    DataCell(Text('Mar 14, 2025')),
                    DataCell(Text('\$892.50')),
                    DataCell(
                      Chip(
                        label: Text('Shipped'),
                        backgroundColor: Colors.orange,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility_outlined),
                            onPressed: null,
                          ),
                          IconButton(
                            icon: Icon(Icons.edit_outlined),
                            onPressed: null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('#ORD-2455')),
                    DataCell(Text('Sarah Miller')),
                    DataCell(Text('Mar 13, 2025')),
                    DataCell(Text('\$129.00')),
                    DataCell(
                      Chip(
                        label: Text('Pending'),
                        backgroundColor: Colors.amber,
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility_outlined),
                            onPressed: null,
                          ),
                          IconButton(
                            icon: Icon(Icons.edit_outlined),
                            onPressed: null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('#ORD-2454')),
                    DataCell(Text('David Lee')),
                    DataCell(Text('Mar 12, 2025')),
                    DataCell(Text('\$345.75')),
                    DataCell(
                      Chip(
                        label: Text('Cancelled'),
                        backgroundColor: Colors.red,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility_outlined),
                            onPressed: null,
                          ),
                          IconButton(
                            icon: Icon(Icons.edit_outlined),
                            onPressed: null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Showing 1-5 of 34 items',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {},
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '1',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('2'),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('3'),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('...'),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('7'),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {},
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
