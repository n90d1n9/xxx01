import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/component_type.dart';
import '../model/integration_component.dart';
import '../states/current_route_notifier.dart';
import '../states/selected_component_provider.dart';

class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectedComponentProvider);
    final route = ref.watch(currentRouteProvider);

    if (selectedIds.isEmpty || route == null) {
      return Container(
        width: 320,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No component selected',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a component to edit',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final component = route.components.firstWhere(
      (c) => c.id == selectedIds.first,
    );

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getColorForType(component.type),
                  _getColorForType(component.type).withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getIconForType(component.type),
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Properties',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        component.type.name.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    prefixIcon: Icon(Icons.label),
                  ),
                  controller: TextEditingController(text: component.label),
                  onChanged: (value) {
                    ref
                        .read(currentRouteProvider.notifier)
                        .updateComponent(component.copyWith(label: value));
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  controller: TextEditingController(
                    text: component.description ?? '',
                  ),
                  onChanged: (value) {
                    ref
                        .read(currentRouteProvider.notifier)
                        .updateComponent(
                          component.copyWith(description: value),
                        );
                  },
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Configuration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._buildPropertiesForType(context, ref, component),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPropertiesForType(
    BuildContext context,
    WidgetRef ref,
    IntegrationComponent component,
  ) {
    switch (component.type) {
      case ComponentType.from:
      case ComponentType.to:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'URI',
              prefixIcon: Icon(Icons.link),
              helperText: 'e.g., direct:start, file:input, http://example.com',
            ),
            controller: TextEditingController(
              text: component.properties['uri'] ?? '',
            ),
            onChanged: (value) => _updateProperty(ref, component, 'uri', value),
          ),
        ];

      case ComponentType.log:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Log Message',
              prefixIcon: Icon(Icons.message),
              helperText: 'Use \${body}, \${header.name}, etc.',
            ),
            controller: TextEditingController(
              text: component.properties['message'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'message', value),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Log Level',
              prefixIcon: Icon(Icons.info),
            ),
            value: component.properties['level'] ?? 'INFO',
            items: ['TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR']
                .map(
                  (level) => DropdownMenuItem(value: level, child: Text(level)),
                )
                .toList(),
            onChanged: (value) =>
                _updateProperty(ref, component, 'level', value ?? 'INFO'),
          ),
        ];

      case ComponentType.setHeader:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Header Name',
              prefixIcon: Icon(Icons.label),
            ),
            controller: TextEditingController(
              text: component.properties['name'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'name', value),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Header Value',
              prefixIcon: Icon(Icons.text_fields),
              helperText: 'Use expressions like \${body.field}',
            ),
            controller: TextEditingController(
              text: component.properties['value'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'value', value),
          ),
        ];

      case ComponentType.setBody:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Body Value',
              prefixIcon: Icon(Icons.data_object),
              helperText: 'Constant value or expression',
            ),
            controller: TextEditingController(
              text: component.properties['value'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'value', value),
            maxLines: 5,
          ),
        ];

      case ComponentType.transform:
        return [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Expression Language',
              prefixIcon: Icon(Icons.code),
            ),
            value: component.properties['language'] ?? 'simple',
            items: ['simple', 'jsonpath', 'xpath', 'groovy', 'spel']
                .map(
                  (lang) => DropdownMenuItem(
                    value: lang,
                    child: Text(lang.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                _updateProperty(ref, component, 'language', value ?? 'simple'),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Expression',
              prefixIcon: Icon(Icons.transform),
              helperText: 'Transformation expression',
            ),
            controller: TextEditingController(
              text: component.properties['expression'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'expression', value),
            maxLines: 3,
          ),
        ];

      case ComponentType.filter:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Filter Expression',
              prefixIcon: Icon(Icons.filter_alt),
              helperText: 'e.g., \${body.amount} > 100',
            ),
            controller: TextEditingController(
              text: component.properties['expression'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'expression', value),
            maxLines: 2,
          ),
        ];

      case ComponentType.choice:
        return [
          const Text('Define conditions in connections'),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              // Add condition dialog
            },
            icon: const Icon(Icons.add),
            label: const Text('Add When Condition'),
          ),
        ];

      case ComponentType.split:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Split Expression',
              prefixIcon: Icon(Icons.call_split),
              helperText: 'e.g., \${body} or xpath expression',
            ),
            controller: TextEditingController(
              text: component.properties['expression'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'expression', value),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Parallel Processing'),
            value: component.properties['parallel'] ?? false,
            onChanged: (value) =>
                _updateProperty(ref, component, 'parallel', value),
          ),
        ];

      case ComponentType.aggregate:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Correlation Expression',
              prefixIcon: Icon(Icons.merge),
              helperText: 'Group messages by this expression',
            ),
            controller: TextEditingController(
              text: component.properties['correlationExpression'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'correlationExpression', value),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Completion Size',
              prefixIcon: Icon(Icons.numbers),
              helperText: 'Number of messages to aggregate',
            ),
            controller: TextEditingController(
              text: component.properties['completionSize']?.toString() ?? '',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateProperty(
              ref,
              component,
              'completionSize',
              int.tryParse(value) ?? 0,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Completion Timeout (ms)',
              prefixIcon: Icon(Icons.timer),
            ),
            controller: TextEditingController(
              text: component.properties['completionTimeout']?.toString() ?? '',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateProperty(
              ref,
              component,
              'completionTimeout',
              int.tryParse(value) ?? 0,
            ),
          ),
        ];

      case ComponentType.enrich:
      case ComponentType.pollEnrich:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Resource URI',
              prefixIcon: Icon(Icons.cloud_download),
              helperText: 'URI to enrich from',
            ),
            controller: TextEditingController(
              text: component.properties['uri'] ?? '',
            ),
            onChanged: (value) => _updateProperty(ref, component, 'uri', value),
          ),
        ];

      case ComponentType.delay:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Delay (milliseconds)',
              prefixIcon: Icon(Icons.schedule),
            ),
            controller: TextEditingController(
              text: component.properties['delay']?.toString() ?? '1000',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateProperty(
              ref,
              component,
              'delay',
              int.tryParse(value) ?? 1000,
            ),
          ),
        ];

      case ComponentType.throttle:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Maximum Requests',
              prefixIcon: Icon(Icons.speed),
            ),
            controller: TextEditingController(
              text: component.properties['maximumRequests']?.toString() ?? '10',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateProperty(
              ref,
              component,
              'maximumRequests',
              int.tryParse(value) ?? 10,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Time Period (milliseconds)',
              prefixIcon: Icon(Icons.timer),
            ),
            controller: TextEditingController(
              text:
                  component.properties['timePeriodMillis']?.toString() ??
                  '1000',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateProperty(
              ref,
              component,
              'timePeriodMillis',
              int.tryParse(value) ?? 1000,
            ),
          ),
        ];

      case ComponentType.loop:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Loop Count',
              prefixIcon: Icon(Icons.loop),
              helperText: 'Number of iterations',
            ),
            controller: TextEditingController(
              text: component.properties['count']?.toString() ?? '1',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateProperty(
              ref,
              component,
              'count',
              int.tryParse(value) ?? 1,
            ),
          ),
        ];

      case ComponentType.marshal:
      case ComponentType.unmarshal:
        return [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: component.type == ComponentType.marshal
                  ? 'Marshal To'
                  : 'Unmarshal From',
              prefixIcon: const Icon(Icons.data_object),
            ),
            value: component.properties['format'] ?? 'json',
            items: ['json', 'xml', 'csv', 'yaml', 'protobuf', 'avro']
                .map(
                  (format) => DropdownMenuItem(
                    value: format,
                    child: Text(format.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                _updateProperty(ref, component, 'format', value ?? 'json'),
          ),
        ];

      case ComponentType.script:
        return [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Script Language',
              prefixIcon: Icon(Icons.code),
            ),
            value: component.properties['language'] ?? 'groovy',
            items: ['groovy', 'javascript', 'python', 'ruby']
                .map(
                  (lang) => DropdownMenuItem(
                    value: lang,
                    child: Text(lang.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                _updateProperty(ref, component, 'language', value ?? 'groovy'),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Script',
              prefixIcon: Icon(Icons.article),
              helperText: 'Enter script code',
            ),
            controller: TextEditingController(
              text: component.properties['script'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'script', value),
            maxLines: 10,
          ),
        ];

      case ComponentType.validate:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Validation Expression',
              prefixIcon: Icon(Icons.verified),
              helperText: 'Expression that should return true',
            ),
            controller: TextEditingController(
              text: component.properties['expression'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'expression', value),
            maxLines: 2,
          ),
        ];

      case ComponentType.process:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Processor Bean Reference',
              prefixIcon: Icon(Icons.settings),
              helperText: 'Spring bean name',
            ),
            controller: TextEditingController(
              text: component.properties['ref'] ?? '',
            ),
            onChanged: (value) => _updateProperty(ref, component, 'ref', value),
          ),
        ];

      case ComponentType.removeHeader:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Header Name',
              prefixIcon: Icon(Icons.remove),
            ),
            controller: TextEditingController(
              text: component.properties['name'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'name', value),
          ),
        ];

      case ComponentType.removeHeaders:
        return [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Pattern',
              prefixIcon: Icon(Icons.clear_all),
              helperText: 'Regex pattern for headers to remove',
            ),
            controller: TextEditingController(
              text: component.properties['pattern'] ?? '',
            ),
            onChanged: (value) =>
                _updateProperty(ref, component, 'pattern', value),
          ),
        ];

      default:
        return [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600]),
                const SizedBox(height: 8),
                Text(
                  'No additional properties for ${component.type.name}',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ];
    }
  }

  void _updateProperty(
    WidgetRef ref,
    IntegrationComponent component,
    String key,
    dynamic value,
  ) {
    final newProperties = Map<String, dynamic>.from(component.properties);
    newProperties[key] = value;
    ref
        .read(currentRouteProvider.notifier)
        .updateComponent(component.copyWith(properties: newProperties));
  }

  IconData _getIconForType(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return Icons.input;
      case ComponentType.to:
        return Icons.output;
      case ComponentType.transform:
        return Icons.transform;
      case ComponentType.filter:
        return Icons.filter_alt;
      case ComponentType.choice:
        return Icons.call_split;
      case ComponentType.log:
        return Icons.article;
      case ComponentType.setHeader:
        return Icons.view_headline;
      case ComponentType.setBody:
        return Icons.data_object;
      case ComponentType.process:
        return Icons.settings;
      case ComponentType.split:
        return Icons.call_split;
      case ComponentType.aggregate:
        return Icons.merge;
      default:
        return Icons.widgets;
    }
  }

  Color _getColorForType(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return Colors.green[700]!;
      case ComponentType.to:
        return Colors.red[700]!;
      case ComponentType.transform:
      case ComponentType.setBody:
      case ComponentType.setHeader:
        return Colors.purple[700]!;
      case ComponentType.choice:
      case ComponentType.filter:
      case ComponentType.multicast:
      case ComponentType.split:
        return Colors.orange[700]!;
      default:
        return Colors.blue[700]!;
    }
  }
}
