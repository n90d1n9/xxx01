import 'package:flutter/material.dart';

class AttributesEditor extends StatelessWidget {
  final Map<String, dynamic> attributes;
  final ValueChanged<Map<String, dynamic>> onAttributesChanged;

  const AttributesEditor({
    super.key,
    required this.attributes,
    required this.onAttributesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attributes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...attributes.entries.map(
          (entry) => _buildAttributeField(entry.key, entry.value),
        ),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Attribute'),
          onPressed: () => _showAddAttributeDialog(context),
        ),
      ],
    );
  }

  Widget _buildAttributeField(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(key)),
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: value.toString(),
              decoration: InputDecoration(
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () {
                    final newAttributes = Map<String, dynamic>.from(attributes);
                    newAttributes.remove(key);
                    onAttributesChanged(newAttributes);
                  },
                ),
              ),
              onChanged: (newValue) {
                final newAttributes = Map<String, dynamic>.from(attributes);
                newAttributes[key] = newValue;
                onAttributesChanged(newAttributes);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddAttributeDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final valueController = TextEditingController();

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Attribute'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Attribute Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: 'Attribute Value',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    final newAttributes = Map<String, dynamic>.from(attributes);
                    newAttributes[nameController.text] = valueController.text;
                    onAttributesChanged(newAttributes);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }
}
