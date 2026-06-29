import 'package:flutter/material.dart';

class FilterOptionsSheet extends StatelessWidget {
  const FilterOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter Proposals',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildFilterSection('Category', [
            'Technology',
            'Food & Beverage',
            'Education',
            'Healthcare',
          ]),
          const SizedBox(height: 16),
          _buildFilterSection('Funding Goal', [
            'Under \$10,000',
            '\$10,000 - \$50,000',
            'Over \$50,000',
          ]),
          const SizedBox(height: 16),
          _buildFilterSection('Syirkah Type', [
            'Musharakah',
            'Mudarabah',
            'Inan',
            'Abdan',
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              options.map((option) {
                return FilterChip(
                  label: Text(option),
                  onSelected: (bool selected) {
                    // Handle selection
                  },
                  selected: false,
                );
              }).toList(),
        ),
      ],
    );
  }
}
