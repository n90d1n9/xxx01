import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kafka_topic.dart';
import '../states/providers.dart';

class TopicConfigDialog extends ConsumerStatefulWidget {
  final String clusterId;
  final KafkaTopic topic;

  const TopicConfigDialog({
    super.key,
    required this.clusterId,
    required this.topic,
  });

  @override
  _TopicConfigDialogState createState() => _TopicConfigDialogState();
}

class _TopicConfigDialogState extends ConsumerState<TopicConfigDialog> {
  late Map<String, dynamic> configs;

  @override
  void initState() {
    super.initState();
    configs = Map.from(widget.topic.configs);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Configure Topic: ${widget.topic.name}'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: ListView(
          children:
              configs.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  subtitle: TextField(
                    controller: TextEditingController(
                      text: entry.value.toString(),
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      // Try to parse as number if possible
                      if (double.tryParse(value) != null) {
                        configs[entry.key] = double.parse(value);
                      } else {
                        configs[entry.key] = value;
                      }
                    },
                  ),
                );
              }).toList(),
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
            try {
              await ref
                  .read(kafkaApiServiceProvider)
                  .updateTopicConfig(
                    widget.clusterId,
                    widget.topic.name,
                    configs,
                  );

              if (context.mounted) {
                Navigator.of(context).pop();

                // Refresh topics
                ref.refresh(topicsProvider(widget.clusterId));

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuration updated successfully'),
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
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
