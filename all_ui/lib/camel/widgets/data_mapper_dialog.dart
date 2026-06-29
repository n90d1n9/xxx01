import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/node_card.dart';
import '../schema/mapping_rule.dart';
import 'add_mapping_dialog.dart';

class DataMapperDialog extends ConsumerStatefulWidget {
  final NodeCard? node;

  const DataMapperDialog({super.key, this.node});

  @override
  ConsumerState<DataMapperDialog> createState() => _DataMapperDialogState();
}

class _DataMapperDialogState extends ConsumerState<DataMapperDialog> {
  late List<MappingRule> _mappings;
  Map<String, dynamic>? _sourceSchema;
  Map<String, dynamic>? _targetSchema;
  String _sourceFormat = 'json';
  String _targetFormat = 'json';

  @override
  void initState() {
    super.initState();
    _loadExistingMappings();
  }

  void _loadExistingMappings() {
    // Load existing mappings from node config
    if (widget.node != null) {
      final config = widget.node!.config;
      _mappings =
          (config['mappings'] as List?)
              ?.map((m) => MappingRule.fromJson(m))
              .toList() ??
          [];
      _sourceFormat = config['sourceFormat'] ?? 'json';
      _targetFormat = config['targetFormat'] ?? 'json';
    } else {
      _mappings = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          _buildHeader(),
          _buildToolbar(),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildSourcePanel()),
                Container(
                  width: 400,
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      vertical: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: _buildMappingsPanel(),
                ),
                Expanded(child: _buildTargetPanel()),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.transform),
          const SizedBox(width: 12),
          const Text(
            'Data Mapper',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelp,
            tooltip: 'Help',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          _buildFormatSelector('Source', _sourceFormat, (value) {
            setState(() => _sourceFormat = value);
          }),
          const SizedBox(width: 16),
          const Icon(Icons.arrow_forward),
          const SizedBox(width: 16),
          _buildFormatSelector('Target', _targetFormat, (value) {
            setState(() => _targetFormat = value);
          }),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: _loadSourceSchema,
            icon: const Icon(Icons.upload_file),
            label: const Text('Load Source Schema'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _loadTargetSchema,
            icon: const Icon(Icons.upload_file),
            label: const Text('Load Target Schema'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _testMapping,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Test'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelector(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label:'),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: value,
          items: const [
            DropdownMenuItem(value: 'json', child: Text('JSON')),
            DropdownMenuItem(value: 'xml', child: Text('XML')),
            DropdownMenuItem(value: 'csv', child: Text('CSV')),
            DropdownMenuItem(value: 'avro', child: Text('Avro')),
          ],
          onChanged: (v) => onChanged(v!),
        ),
      ],
    );
  }

  Widget _buildSourcePanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Source Schema',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshSourceSchema,
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child:
                _sourceSchema == null
                    ? _buildEmptySchemaState('source')
                    : _buildSchemaTree(_sourceSchema!, true),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Target Schema',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshTargetSchema,
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child:
                _targetSchema == null
                    ? _buildEmptySchemaState('target')
                    : _buildSchemaTree(_targetSchema!, false),
          ),
        ],
      ),
    );
  }

  Widget _buildMappingsPanel() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Mappings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addMapping,
                tooltip: 'Add Mapping',
              ),
              IconButton(
                icon: const Icon(Icons.auto_fix_high),
                onPressed: _autoMap,
                tooltip: 'Auto Map',
              ),
            ],
          ),
        ),
        Expanded(
          child:
              _mappings.isEmpty
                  ? _buildEmptyMappingsState()
                  : _buildMappingsList(),
        ),
      ],
    );
  }

  Widget _buildEmptySchemaState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No $type schema loaded',
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: type == 'source' ? _loadSourceSchema : _loadTargetSchema,
            icon: const Icon(Icons.upload_file),
            label: const Text('Load Schema'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMappingsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.link_off,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No mappings defined',
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _addMapping,
            icon: const Icon(Icons.add),
            label: const Text('Add Mapping'),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemaTree(Map<String, dynamic> schema, bool isSource) {
    return ListView(children: _buildSchemaNodes(schema, '', isSource));
  }

  List<Widget> _buildSchemaNodes(
    Map<String, dynamic> schema,
    String path,
    bool isSource,
  ) {
    final widgets = <Widget>[];

    schema.forEach((key, value) {
      final currentPath = path.isEmpty ? key : '$path.$key';

      if (value is Map<String, dynamic>) {
        widgets.add(
          _buildSchemaNode(
            currentPath,
            key,
            'object',
            isSource,
            hasChildren: true,
          ),
        );
        widgets.addAll(_buildSchemaNodes(value, currentPath, isSource));
      } else if (value is List) {
        widgets.add(_buildSchemaNode(currentPath, key, 'array', isSource));
      } else {
        widgets.add(
          _buildSchemaNode(
            currentPath,
            key,
            value?.toString() ?? 'string',
            isSource,
          ),
        );
      }
    });

    return widgets;
  }

  Widget _buildSchemaNode(
    String path,
    String name,
    String type,
    bool isSource, {
    bool hasChildren = false,
  }) {
    final depth = path.split('.').length - 1;

    return Draggable<String>(
      data: path,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSource ? Colors.blue : Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(name, style: const TextStyle(color: Colors.white)),
        ),
      ),
      child: DragTarget<String>(
        onAcceptWithDetails: (details) {
          if (isSource != (details.data == path)) {
            _createMapping(
              isSource ? details.data : path,
              isSource ? path : details.data,
            );
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isHighlighted = candidateData.isNotEmpty;

          return Container(
            margin: EdgeInsets.only(left: depth * 16.0),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  isHighlighted
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
              border: Border(
                left: BorderSide(
                  color:
                      isHighlighted
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(_getTypeIcon(type), size: 16, color: _getTypeColor(type)),
                const SizedBox(width: 8),
                Expanded(child: Text(name)),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMappingsList() {
    return ReorderableListView.builder(
      itemCount: _mappings.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = _mappings.removeAt(oldIndex);
          _mappings.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final mapping = _mappings[index];
        return _buildMappingCard(mapping, index);
      },
    );
  }

  Widget _buildMappingCard(MappingRule mapping, int index) {
    return Card(
      key: ValueKey(mapping.id),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.link),
        title: Text(
          mapping.targetPath,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          mapping.sourcePath,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).disabledColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editMapping(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => _deleteMapping(index),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMappingDetail('Source', mapping.sourcePath),
                const SizedBox(height: 8),
                _buildMappingDetail('Target', mapping.targetPath),
                if (mapping.expression != null) ...[
                  const SizedBox(height: 8),
                  _buildMappingDetail('Expression', mapping.expression!),
                ],
                if (mapping.function != null) ...[
                  const SizedBox(height: 8),
                  _buildMappingDetail('Function', mapping.function!.name),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMappingDetail(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _saveMappings,
            icon: const Icon(Icons.save),
            label: const Text('Save Mappings'),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'object':
        return Icons.folder;
      case 'array':
        return Icons.list;
      case 'string':
        return Icons.text_fields;
      case 'number':
      case 'integer':
        return Icons.numbers;
      case 'boolean':
        return Icons.toggle_on;
      default:
        return Icons.label;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'object':
        return Colors.blue;
      case 'array':
        return Colors.purple;
      case 'string':
        return Colors.green;
      case 'number':
      case 'integer':
        return Colors.orange;
      case 'boolean':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _loadSourceSchema() {
    // TODO: Implement schema loading from file or endpoint
    setState(() {
      _sourceSchema = {
        'user': {
          'id': 'string',
          'name': 'string',
          'email': 'string',
          'address': {
            'street': 'string',
            'city': 'string',
            'country': 'string',
          },
          'orders': 'array',
        },
      };
    });
  }

  void _loadTargetSchema() {
    // TODO: Implement schema loading
    setState(() {
      _targetSchema = {
        'customer': {
          'customerId': 'string',
          'fullName': 'string',
          'emailAddress': 'string',
          'location': {
            'streetAddress': 'string',
            'cityName': 'string',
            'countryCode': 'string',
          },
          'purchases': 'array',
        },
      };
    });
  }

  void _refreshSourceSchema() {
    // TODO: Refresh source schema
  }

  void _refreshTargetSchema() {
    // TODO: Refresh target schema
  }

  void _addMapping() {
    showDialog(
      context: context,
      builder:
          (context) => AddMappingDialog(
            onAdd: (mapping) {
              setState(() => _mappings.add(mapping));
            },
          ),
    );
  }

  void _createMapping(String sourcePath, String targetPath) {
    final mapping = MappingRule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sourcePath: sourcePath,
      targetPath: targetPath,
    );
    setState(() => _mappings.add(mapping));
  }

  void _editMapping(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AddMappingDialog(
            mapping: _mappings[index],
            onAdd: (mapping) {
              setState(() => _mappings[index] = mapping);
            },
          ),
    );
  }

  void _deleteMapping(int index) {
    setState(() => _mappings.removeAt(index));
  }

  void _autoMap() {
    // TODO: Implement auto-mapping based on field name similarity
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Auto Map'),
            content: const Text(
              'This will automatically create mappings based on field name similarity. '
              'Existing mappings will be preserved.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Auto-mapping logic here
                  Navigator.pop(context);
                },
                child: const Text('Auto Map'),
              ),
            ],
          ),
    );
  }

  void _testMapping() {
    // TODO: Implement mapping test with sample data
  }

  void _saveMappings() {
    if (widget.node != null) {
      final config = Map<String, dynamic>.from(widget.node!.config);
      config['mappings'] = _mappings.map((m) => m.toJson()).toList();
      config['sourceFormat'] = _sourceFormat;
      config['targetFormat'] = _targetFormat;

      // Update node configuration
      // ref.read(routesProvider.notifier).updateNodeConfig(
      //   widget.node!.id,
      //   config,
      // );
    }
    Navigator.pop(context, _mappings);
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Data Mapper Help'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How to use the Data Mapper:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text('1. Load source and target schemas'),
                  Text(
                    '2. Drag fields from source to target to create mappings',
                  ),
                  Text('3. Use expressions for complex transformations'),
                  Text('4. Test mappings with sample data'),
                  Text('5. Save the configuration'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
