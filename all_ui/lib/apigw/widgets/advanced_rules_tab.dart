import 'package:flutter/material.dart';

class AdvancedRulesTab extends StatefulWidget {
  const AdvancedRulesTab({Key? key}) : super(key: key);

  @override
  State<AdvancedRulesTab> createState() => _AdvancedRulesTabState();
}

class _AdvancedRulesTabState extends State<AdvancedRulesTab> {
  final List<Map<String, dynamic>> _rules = [
    {
      'name': 'Country-based Routing',
      'description': 'Route traffic based on geo-location',
      'active': true,
      'conditions': 'country in ["US", "CA", "UK"]',
      'action': 'route to service-na-cluster',
    },
    {
      'name': 'Device-based Routing',
      'description': 'Special handling for mobile devices',
      'active': true,
      'conditions': 'header["User-Agent"] contains "Mobile"',
      'action': 'route to mobile-optimized-service',
    },
    {
      'name': 'Feature Flag Route',
      'description': 'A/B testing for new feature',
      'active': false,
      'conditions': 'cookie["beta-tester"] == "true"',
      'action': 'route to new-feature-service',
    },
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _actionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _conditionsController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Routing Rules',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Configure complex routing rules with custom conditions and actions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),

          // Rules list
          Expanded(
            child: Card(
              elevation: 0,
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: ListView.separated(
                itemCount: _rules.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final rule = _rules[index];
                  return ExpansionTile(
                    title: Text(
                      rule['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: rule['active'] ? null : Colors.grey,
                      ),
                    ),
                    subtitle: Text(rule['description']),
                    leading: Icon(
                      Icons.rule_folder,
                      color:
                          rule['active']
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                    ),
                    trailing: Switch(
                      value: rule['active'],
                      onChanged: (value) {
                        setState(() {
                          _rules[index]['active'] = value;
                        });
                      },
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Conditions', rule['conditions']),
                            const SizedBox(height: 8),
                            _buildInfoRow('Action', rule['action']),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit'),
                                  onPressed:
                                      () => _showEditDialog(context, index),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Delete'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _rules.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Add rule button
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Routing Rule'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Routing Rule'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Rule Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _conditionsController,
                      decoration: const InputDecoration(
                        labelText: 'Conditions',
                        border: OutlineInputBorder(),
                        hintText: 'E.g., header["x-custom"] == "value"',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter conditions';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _actionController,
                      decoration: const InputDecoration(
                        labelText: 'Action',
                        border: OutlineInputBorder(),
                        hintText: 'E.g., route to my-service',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an action';
                        }
                        return null;
                      },
                    ),
                  ],
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
                    setState(() {
                      _rules.add({
                        'name': _nameController.text,
                        'description': _descriptionController.text,
                        'conditions': _conditionsController.text,
                        'action': _actionController.text,
                        'active': true,
                      });
                    });
                    _nameController.clear();
                    _descriptionController.clear();
                    _conditionsController.clear();
                    _actionController.clear();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Add Rule'),
              ),
            ],
          ),
    );
  }

  void _showEditDialog(BuildContext context, int index) {
    final rule = _rules[index];
    _nameController.text = rule['name'];
    _descriptionController.text = rule['description'];
    _conditionsController.text = rule['conditions'];
    _actionController.text = rule['action'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Routing Rule'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Rule Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _conditionsController,
                      decoration: const InputDecoration(
                        labelText: 'Conditions',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter conditions';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _actionController,
                      decoration: const InputDecoration(
                        labelText: 'Action',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an action';
                        }
                        return null;
                      },
                    ),
                  ],
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
                    setState(() {
                      _rules[index] = {
                        'name': _nameController.text,
                        'description': _descriptionController.text,
                        'conditions': _conditionsController.text,
                        'action': _actionController.text,
                        'active': rule['active'],
                      };
                    });
                    _nameController.clear();
                    _descriptionController.clear();
                    _conditionsController.clear();
                    _actionController.clear();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
    );
  }
}
