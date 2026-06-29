import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/providers.dart';

class CreateTopicDialog extends ConsumerStatefulWidget {
  final String clusterId;

  const CreateTopicDialog({super.key, required this.clusterId});

  @override
  _CreateTopicDialogState createState() => _CreateTopicDialogState();
}

class _CreateTopicDialogState extends ConsumerState<CreateTopicDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _partitions = 1;
  int _replicationFactor = 1;
  final Map<String, dynamic> _configs = {
    'retention.ms': 604800000, // 7 days
    'cleanup.policy': 'delete',
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Topic'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Topic Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a topic name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Partitions',
                          border: OutlineInputBorder(),
                        ),
                        value: _partitions,
                        items:
                            List.generate(12, (index) => index + 1)
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text('$e'),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _partitions = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Replication Factor',
                          border: OutlineInputBorder(),
                        ),
                        value: _replicationFactor,
                        items:
                            List.generate(3, (index) => index + 1)
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text('$e'),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _replicationFactor = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Configuration',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Retention time
                Row(
                  children: [
                    const SizedBox(width: 120, child: Text('Retention Time:')),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        value: _configs['retention.ms'],
                        items: [
                          DropdownMenuItem(
                            value: 86400000,
                            child: const Text('1 day'),
                          ),
                          DropdownMenuItem(
                            value: 604800000,
                            child: const Text('7 days'),
                          ),
                          DropdownMenuItem(
                            value: 2592000000,
                            child: const Text('30 days'),
                          ),
                          DropdownMenuItem(
                            value: -1,
                            child: const Text('Unlimited'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _configs['retention.ms'] = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Cleanup policy
                Row(
                  children: [
                    const SizedBox(width: 120, child: Text('Cleanup Policy:')),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        value: _configs['cleanup.policy'],
                        items: const [
                          DropdownMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                          DropdownMenuItem(
                            value: 'compact',
                            child: Text('Compact'),
                          ),
                          DropdownMenuItem(
                            value: 'compact,delete',
                            child: Text('Compact and Delete'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _configs['cleanup.policy'] = value;
                            });
                          }
                        },
                      ),
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
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                await ref
                    .read(kafkaApiServiceProvider)
                    .createTopic(
                      widget.clusterId,
                      _nameController.text,
                      _partitions,
                      _replicationFactor,
                      _configs,
                    );

                if (context.mounted) {
                  Navigator.of(context).pop();

                  // Refresh topics
                  ref.refresh(topicsProvider(widget.clusterId));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Topic "${_nameController.text}" created successfully',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
