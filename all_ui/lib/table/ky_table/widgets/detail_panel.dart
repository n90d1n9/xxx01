import 'package:flutter/material.dart';

//import '../model/tabel_item.dart';

import '../model/ky_data.dart';
import '../tabel_controller.dart';
import 'item_form_dialog.dart';

class DetailPanel extends StatelessWidget {
  final KyRow item;
  final TableController controller;

  const DetailPanel({super.key, required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    controller.setSelectedItem(null);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailHeader(),
                  /* const SizedBox(height: 24),
                  _buildDetailItem('ID', item.id),
                  _buildDetailItem('Name', item.name),
                  _buildDetailItem('Category', item.category),
                  _buildDetailItem(
                    'Value',
                    '\$${item.value.toStringAsFixed(2)}',
                  ),
                  _buildDetailItem('Date', _formatDate(item.date)),
                  _buildDetailItem(
                    'Status',
                    item.status,
                    customWidget: _buildStatusBadge(),
                  ),
                  _buildDetailItem(
                    'Priority',
                    '${item.priority}',
                    customWidget: Row(
                      children: List.generate(
                        item.priority,
                        (i) => const Icon(Icons.star, color: Colors.amber),
                      ),
                    ),
                  ),
                  _buildDetailItem(
                    'Active',
                    item.active ? 'Yes' : 'No',
                    customWidget: Icon(
                      item.active ? Icons.check_circle : Icons.cancel,
                      color: item.active ? Colors.green : Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildActionButtons(context), */
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          item.category,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, {Widget? customWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: customWidget ?? Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(item.status),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        item.status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
          onPressed: () => {}, //_editItem(context),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.delete),
          label: const Text('Delete'),
          onPressed: () => _deleteItem(context),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'On Hold':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _editItem(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ItemFormDialog(
            item: item,
            onSave: (updatedItem) {
              controller.updateItem(updatedItem);
              controller.setSelectedItem(updatedItem);
            },
          ),
    );
  }

  void _deleteItem(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete ${item.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.deleteItem(item.id);
                  controller.setSelectedItem(null);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
