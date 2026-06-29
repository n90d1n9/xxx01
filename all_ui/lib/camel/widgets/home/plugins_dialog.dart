import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/plugin_provider.dart';

class PluginsDialog extends StatelessWidget {
  const PluginsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 700,
        height: 600,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor,
              child: const Row(
                children: [
                  Icon(Icons.extension, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Plugin Marketplace',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final plugins = ref.watch(pluginsProvider);

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: plugins.length,
                    itemBuilder: (context, index) {
                      final plugin = plugins[index];
                      return Card(
                        child: ExpansionTile(
                          leading: Icon(plugin.icon, size: 32),
                          title: Text(
                            plugin.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${plugin.description}\nVersion: ${plugin.version}',
                          ),
                          trailing: Switch(
                            value: plugin.enabled,
                            onChanged: (value) {},
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Components (${plugin.components.length}):',
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children:
                                        plugin.components.map((comp) {
                                          return Chip(
                                            avatar: Icon(comp.icon, size: 18),
                                            label: Text(comp.name),
                                          );
                                        }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
