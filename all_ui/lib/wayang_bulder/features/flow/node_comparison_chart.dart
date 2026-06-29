import 'package:flutter/material.dart';

class NodeComparisonChart extends StatelessWidget {
  const NodeComparisonChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(const Color(0xFF2D2D2D)),
        dataRowColor: MaterialStateProperty.all(const Color(0xFF1E1E1E)),
        columns: const [
          DataColumn(
            label: Text(
              'Node Type',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Category',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Best For',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Performance',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Complexity',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        rows: [
          _buildRow(
            'If/Else',
            'Control Flow',
            'Conditional routing',
            '⭐⭐⭐⭐⭐',
            '⭐⭐',
          ),
          _buildRow(
            'While Loop',
            'Control Flow',
            'Iterative processing',
            '⭐⭐⭐⭐',
            '⭐⭐⭐',
          ),
          _buildRow(
            'Human in Loop',
            'Control Flow',
            'Manual approval',
            '⭐⭐⭐',
            '⭐⭐',
          ),
          _buildRow(
            'Try-Catch',
            'Error Handling',
            'Fault tolerance',
            '⭐⭐⭐⭐',
            '⭐⭐',
          ),
          _buildRow(
            'Parallel',
            'Concurrency',
            'Speed optimization',
            '⭐⭐⭐⭐⭐',
            '⭐⭐⭐⭐',
          ),
          _buildRow('Router', 'Routing', 'Load balancing', '⭐⭐⭐⭐⭐', '⭐⭐⭐'),
          _buildRow('Batch', 'Performance', 'Bulk operations', '⭐⭐⭐⭐⭐', '⭐⭐⭐'),
          _buildRow('Merge', 'Data', 'Data consolidation', '⭐⭐⭐⭐', '⭐⭐⭐'),
          _buildRow('Delay', 'Timing', 'Scheduled execution', '⭐⭐⭐⭐', '⭐⭐'),
          _buildRow('Filter', 'Data', 'Data transformation', '⭐⭐⭐⭐⭐', '⭐⭐'),
          _buildRow(
            'Cache',
            'Performance',
            'Response optimization',
            '⭐⭐⭐⭐⭐',
            '⭐⭐⭐',
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(
    String name,
    String category,
    String bestFor,
    String performance,
    String complexity,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(name, style: const TextStyle())),
        DataCell(Text(category, style: const TextStyle())),
        DataCell(Text(bestFor, style: const TextStyle())),
        DataCell(
          Text(performance, style: const TextStyle(color: Colors.amber)),
        ),
        DataCell(Text(complexity, style: const TextStyle(color: Colors.blue))),
      ],
    );
  }
}
