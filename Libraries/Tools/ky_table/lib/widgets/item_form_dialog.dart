import 'package:flutter/material.dart';

import '../model/tabel_item.dart';

class ItemFormDialog extends StatefulWidget {
  final TableItem? item;
  final Function(TableItem) onSave;

  const ItemFormDialog({super.key, this.item, required this.onSave});

  @override
  State<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _id;
  late String _name;
  late String _category;
  late double _value;
  late DateTime _date;
  late bool _active;
  late String _status;
  late int _priority;

  @override
  void initState() {
    super.initState();

    // Initialize with existing item data or defaults
    final item = widget.item;
    if (item != null) {
      _id = item.id;
      _name = item.name;
      _category = item.category;
      _value = item.value;
      _date = item.date;
      _active = item.active;
      _status = item.status;
      _priority = item.priority;
    } else {
      // Defaults for new item
      _id = 'ID-${1000 + DateTime.now().millisecondsSinceEpoch % 9000}';
      _name = '';
      _category = 'Hardware';
      _value = 0.0;
      _date = DateTime.now();
      _active = true;
      _status = 'Pending';
      _priority = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Add New Item' : 'Edit Item'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _id,
                  decoration: const InputDecoration(
                    labelText: 'ID',
                    enabled: false,
                  ),
                  enabled: false,
                ),
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onChanged: (value) => _name = value,
                ),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items:
                      ['Hardware', 'Software', 'Services', 'Infrastructure']
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _category = value;
                      });
                    }
                  },
                ),
                TextFormField(
                  initialValue: _value.toString(),
                  decoration: const InputDecoration(labelText: 'Value'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (double.tryParse(value) != null) {
                      _value = double.parse(value);
                    }
                  },
                ),
                InkWell(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _date = selectedDate;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items:
                      ['Pending', 'Approved', 'Rejected', 'On Hold']
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Priority'),
                Slider(
                  value: _priority.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _priority.toString(),
                  onChanged: (value) {
                    setState(() {
                      _priority = value.toInt();
                    });
                  },
                ),
                Row(
                  children: [
                    const Text('Active'),
                    Switch(
                      value: _active,
                      onChanged: (value) {
                        setState(() {
                          _active = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final item = TableItem(
                id: _id,
                name: _name,
                category: _category,
                value: _value,
                date: _date,
                active: _active,
                status: _status,
                priority: _priority,
              );

              widget.onSave(item);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
