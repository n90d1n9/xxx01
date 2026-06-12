import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

// ================ MODELS ================

class SchemaField {
  final String id;
  final String name;
  final String type;
  final String? description;
  final bool isNested;
  final List<SchemaField> children;

  SchemaField({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.isNested = false,
    this.children = const [],
  });
}

class Schema {
  final String id;
  final String name;
  final List<SchemaField> fields;

  Schema({required this.id, required this.name, required this.fields});
}

class Mapping {
  final String id;
  final String sourceFieldId;
  final String targetFieldId;
  final TransformationType? transformationType;
  final String? transformationConfig;

  Mapping({
    required this.id,
    required this.sourceFieldId,
    required this.targetFieldId,
    this.transformationType,
    this.transformationConfig,
  });
}

enum TransformationType {
  dataTypeConversion,
  concatenation,
  splitting,
  formatting,
  enrichment,
  calculation,
  customScript,
}

// ================ PROVIDERS ================

final sourceSchemaProvider = StateProvider<Schema>((ref) {
  // Sample schema, replace with your actual data loading logic
  return Schema(
    id: '1',
    name: 'Source Schema',
    fields: [
      SchemaField(
        id: 's1',
        name: 'customer_id',
        type: 'string',
        description: 'Unique customer identifier',
      ),
      SchemaField(
        id: 's2',
        name: 'contact_info',
        type: 'object',
        isNested: true,
        children: [
          SchemaField(id: 's2_1', name: 'email', type: 'string'),
          SchemaField(id: 's2_2', name: 'phone', type: 'string'),
        ],
      ),
      SchemaField(id: 's3', name: 'age', type: 'integer'),
      SchemaField(id: 's4', name: 'purchase_amount', type: 'number'),
      SchemaField(id: 's5', name: 'timestamp', type: 'datetime'),
    ],
  );
});

final targetSchemaProvider = StateProvider<Schema>((ref) {
  // Sample schema, replace with your actual data loading logic
  return Schema(
    id: '2',
    name: 'Target Schema',
    fields: [
      SchemaField(
        id: 't1',
        name: 'id',
        type: 'string',
        description: 'Primary identifier',
      ),
      SchemaField(
        id: 't2',
        name: 'user',
        type: 'object',
        isNested: true,
        children: [
          SchemaField(id: 't2_1', name: 'email_address', type: 'string'),
          SchemaField(id: 't2_2', name: 'contact_number', type: 'string'),
        ],
      ),
      SchemaField(id: 't3', name: 'user_age', type: 'integer'),
      SchemaField(id: 't4', name: 'revenue', type: 'number'),
      SchemaField(id: 't5', name: 'created_at', type: 'datetime'),
    ],
  );
});

final mappingsProvider = StateNotifierProvider<MappingsNotifier, List<Mapping>>(
  (ref) {
    return MappingsNotifier();
  },
);

class MappingsNotifier extends StateNotifier<List<Mapping>> {
  MappingsNotifier() : super([]);

  void addMapping(String sourceFieldId, String targetFieldId) {
    // Check if mapping already exists to prevent duplicates
    if (state.any((m) => m.targetFieldId == targetFieldId)) {
      return;
    }

    final mapping = Mapping(
      id: const Uuid().v4(),
      sourceFieldId: sourceFieldId,
      targetFieldId: targetFieldId,
    );
    state = [...state, mapping];
  }

  void updateTransformation(
    String mappingId,
    TransformationType type,
    String? config,
  ) {
    state = state.map((mapping) {
      if (mapping.id == mappingId) {
        return Mapping(
          id: mapping.id,
          sourceFieldId: mapping.sourceFieldId,
          targetFieldId: mapping.targetFieldId,
          transformationType: type,
          transformationConfig: config,
        );
      }
      return mapping;
    }).toList();
  }

  void removeMapping(String mappingId) {
    state = state.where((m) => m.id != mappingId).toList();
  }
}

// ================ UI COMPONENTS ================

class SchemaMapperScreen extends ConsumerWidget {
  const SchemaMapperScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schema Mapper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Save mappings logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mappings saved successfully')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // Clear all mappings
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Mappings?'),
                  content: const Text(
                    'This will delete all your current mappings. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(mappingsProvider.notifier).state = [];
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: const SchemaMapperLayout(),
    );
  }
}

class SchemaMapperLayout extends ConsumerWidget {
  const SchemaMapperLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Source Schema Panel
        Expanded(
          flex: 2,
          child: Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    'Source Schema',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: SchemaPanel(
                    schema: ref.watch(sourceSchemaProvider),
                    isSource: true,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Mapping Visualization Panel
        Expanded(flex: 1, child: MappingVisualizationPanel()),

        // Target Schema Panel
        Expanded(
          flex: 2,
          child: Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    'Target Schema',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: SchemaPanel(
                    schema: ref.watch(targetSchemaProvider),
                    isSource: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SchemaPanel extends ConsumerWidget {
  final Schema schema;
  final bool isSource;

  const SchemaPanel({super.key, required this.schema, required this.isSource});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              children: _buildSchemaFields(schema.fields, ref, context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSchemaFields(
    List<SchemaField> fields,
    WidgetRef ref,
    BuildContext context, {
    String indent = '',
  }) {
    List<Widget> widgets = [];

    for (final field in fields) {
      widgets.add(
        DraggableSchemaField(field: field, isSource: isSource, indent: indent),
      );

      if (field.isNested && field.children.isNotEmpty) {
        widgets.addAll(
          _buildSchemaFields(
            field.children,
            ref,
            context,
            indent: '$indent    ',
          ),
        );
      }
    }

    return widgets;
  }
}

class DraggableSchemaField extends ConsumerWidget {
  final SchemaField field;
  final bool isSource;
  final String indent;

  const DraggableSchemaField({
    super.key,
    required this.field,
    required this.isSource,
    this.indent = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mappings = ref.watch(mappingsProvider);
    final isMapped = isSource
        ? mappings.any((m) => m.sourceFieldId == field.id)
        : mappings.any((m) => m.targetFieldId == field.id);

    final connectedMapping = isSource
        ? mappings.firstWhere(
            (m) => m.sourceFieldId == field.id,
            orElse: () => Mapping(id: '', sourceFieldId: '', targetFieldId: ''),
          )
        : mappings.firstWhere(
            (m) => m.targetFieldId == field.id,
            orElse: () => Mapping(id: '', sourceFieldId: '', targetFieldId: ''),
          );

    Widget fieldWidget = Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: EdgeInsets.only(bottom: 8, left: indent.length * 4.0),
      decoration: BoxDecoration(
        color: isMapped ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isMapped ? Colors.blue.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  field.type,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                if (field.description != null)
                  Text(
                    field.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          if (isMapped && !isSource)
            IconButton(
              icon: const Icon(Icons.settings, size: 18),
              color: Colors.blue,
              onPressed: () {
                _showTransformationDialog(context, ref, connectedMapping);
              },
            ),
          ConnectorPoint(field: field, isSource: isSource),
        ],
      ),
    );

    if (isSource) {
      return Draggable<SchemaField>(
        data: field,
        feedback: Material(
          elevation: 4,
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(field.name),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.5, child: fieldWidget),
        child: fieldWidget,
      );
    } else {
      return DragTarget<SchemaField>(
        onAccept: (sourceField) {
          ref
              .read(mappingsProvider.notifier)
              .addMapping(sourceField.id, field.id);
        },
        builder: (context, candidateItems, rejectedItems) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: candidateItems.isNotEmpty
                  ? Border.all(color: Colors.green, width: 2)
                  : null,
            ),
            child: fieldWidget,
          );
        },
      );
    }
  }

  void _showTransformationDialog(
    BuildContext context,
    WidgetRef ref,
    Mapping mapping,
  ) {
    if (mapping.id.isEmpty) return;

    TransformationType selectedType =
        mapping.transformationType ?? TransformationType.dataTypeConversion;
    TextEditingController configController = TextEditingController(
      text: mapping.transformationConfig,
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Configure Transformation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Transformation Type:'),
                DropdownButton<TransformationType>(
                  value: selectedType,
                  isExpanded: true,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedType = newValue;
                      });
                    }
                  },
                  items: TransformationType.values.map((type) {
                    return DropdownMenuItem<TransformationType>(
                      value: type,
                      child: Text(_transformationTypeToString(type)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Configuration:'),
                const SizedBox(height: 8),
                TextField(
                  controller: configController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: _getConfigHint(selectedType),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(mappingsProvider.notifier).removeMapping(mapping.id);
                  Navigator.pop(context);
                },
                child: const Text('Remove Mapping'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(mappingsProvider.notifier)
                      .updateTransformation(
                        mapping.id,
                        selectedType,
                        configController.text,
                      );
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _transformationTypeToString(TransformationType type) {
    switch (type) {
      case TransformationType.dataTypeConversion:
        return 'Data Type Conversion';
      case TransformationType.concatenation:
        return 'Concatenation';
      case TransformationType.splitting:
        return 'Splitting';
      case TransformationType.formatting:
        return 'Formatting';
      case TransformationType.enrichment:
        return 'Data Enrichment';
      case TransformationType.calculation:
        return 'Calculation';
      case TransformationType.customScript:
        return 'Custom Script';
    }
  }

  String _getConfigHint(TransformationType type) {
    switch (type) {
      case TransformationType.dataTypeConversion:
        return 'Example: string->int, float->decimal(2)';
      case TransformationType.concatenation:
        return 'Example: {firstName} {lastName}';
      case TransformationType.splitting:
        return 'Example: split(fullName, " ", 0)';
      case TransformationType.formatting:
        return 'Example: date(YYYY-MM-DD), currency(\$#,###.##)';
      case TransformationType.enrichment:
        return 'Example: lookup(countryCode, "countries")';
      case TransformationType.calculation:
        return 'Example: {price} * {quantity} * 0.9';
      case TransformationType.customScript:
        return 'Enter custom transformation script or function';
    }
  }
}

class ConnectorPoint extends StatelessWidget {
  final SchemaField field;
  final bool isSource;

  const ConnectorPoint({
    super.key,
    required this.field,
    required this.isSource,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.blue, width: 2),
      ),
    );
  }
}

class MappingVisualizationPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mappings = ref.watch(mappingsProvider);
    final sourceSchema = ref.watch(sourceSchemaProvider);
    final targetSchema = ref.watch(targetSchemaProvider);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: CustomPaint(
          size: const Size(double.infinity, double.infinity),
          painter: MappingPainter(
            mappings: mappings,
            sourceSchema: sourceSchema,
            targetSchema: targetSchema,
          ),
        ),
      ),
    );
  }
}

class MappingPainter extends CustomPainter {
  final List<Mapping> mappings;
  final Schema sourceSchema;
  final Schema targetSchema;

  MappingPainter({
    required this.mappings,
    required this.sourceSchema,
    required this.targetSchema,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // This is a placeholder. In a real implementation, you'd need to calculate
    // the actual positions of connector points based on layout measurements.
    // This would typically be done using GlobalKeys and RenderBox positions.

    final paint = Paint()
      ..color = Colors.blue.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw some sample connector lines for demonstration
    for (int i = 0; i < 5; i++) {
      final startY = 50.0 + i * 60;
      final endY = 50.0 + (4 - i) * 60;

      final path = Path()
        ..moveTo(0, startY)
        ..cubicTo(
          size.width * 0.3,
          startY,
          size.width * 0.7,
          endY,
          size.width,
          endY,
        );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// ================ MAIN APP ================

void main() {
  runApp(const ProviderScope(child: SchemaMapperApp()));
}

class SchemaMapperApp extends StatelessWidget {
  const SchemaMapperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schema Mapper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SchemaMapperScreen(),
    );
  }
}
