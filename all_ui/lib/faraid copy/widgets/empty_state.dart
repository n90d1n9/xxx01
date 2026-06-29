// components/empty_state.dart
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback onAddDeceased;

  const EmptyState({super.key, required this.onAddDeceased});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.teal.withOpacity(0.1),
            ),
            child: Icon(
              Icons.account_tree,
              size: 120,
              color: Colors.teal.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Belum ada pohon keluarga yang dibuat...',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Silahkan tambahkan pihak yang meninggal',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: onAddDeceased,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Pihak  yang Meninggal'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
          ),
        ],
      ),
    );
  }
}
