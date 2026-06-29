import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/data_schema.dart';
import '../models/field_mapping.dart';
import '../models/schema_field.dart';
import '../states/providers.dart';

class DragDropMappingWidget extends ConsumerStatefulWidget {
  final DataSchema sourceSchema;
  final DataSchema targetSchema;

  const DragDropMappingWidget({
    super.key,
    required this.sourceSchema,
    required this.targetSchema,
  });

  @override
  _DragDropMappingWidgetState createState() => _DragDropMappingWidgetState();
}

class _DragDropMappingWidgetState extends ConsumerState<DragDropMappingWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize mapping when widget is first created
    /*  ref
        .read(mappingManagerProvider.notifier)
        .createMapping(widget.sourceSchema, widget.targetSchema); */
  }

  @override
  Widget build(BuildContext context) {
    final mappingConfig = ref.watch(mappingManagerProvider);

    return Row(
      children: [
        // Source Schema Column
        Expanded(
          child: Column(
            children: [
              Text('Source Schema: ${widget.sourceSchema.name}'),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.sourceSchema.fields.length,
                  itemBuilder: (context, index) {
                    final field = widget.sourceSchema.fields[index];
                    return Draggable<SchemaField>(
                      data: field,
                      feedback: _buildDragFeedback(field),
                      childWhenDragging: _buildDraggedItem(
                        field,
                        isDragging: true,
                      ),
                      child: _buildDraggedItem(field),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Target Schema Column
        Expanded(
          child: Column(
            children: [
              Text('Target Schema: ${widget.targetSchema.name}'),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.targetSchema.fields.length,
                  itemBuilder: (context, index) {
                    final targetField = widget.targetSchema.fields[index];
                    return DragTarget<SchemaField>(
                      builder: (context, candidates, rejected) {
                        return _buildTargetItem(
                          targetField,
                          isHighlighted: candidates.isNotEmpty,
                        );
                      },
                      onWillAccept: (sourceField) {
                        // Validate if source field can be mapped to target field
                        return sourceField?.type == targetField.type;
                      },
                      onAccept: (sourceField) {
                        // Create or update field mapping
                        final mapping = FieldMapping(
                          sourceField: sourceField,
                          targetField: targetField,
                          strategy: MappingStrategy.direct,
                        );

                        ref
                            .read(mappingManagerProvider.notifier)
                            .updateFieldMapping(mapping);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDraggedItem(SchemaField field, {bool isDragging = false}) {
    return Card(
      color: isDragging ? Colors.grey.shade300 : null,
      child: ListTile(
        title: Text(field.name),
        subtitle: Text(field.type.toString().split('.').last),
        trailing: Icon(
          _getIconForDataType(field.type),
          color: _getColorForDataType(field.type),
        ),
      ),
    );
  }

  Widget _buildDragFeedback(SchemaField field) {
    return Material(
      elevation: 4.0,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Map: ${field.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTargetItem(SchemaField field, {bool isHighlighted = false}) {
    return Card(
      color: isHighlighted ? Colors.green.shade100 : null,
      child: ListTile(
        title: Text(field.name),
        subtitle: Text(field.type.toString().split('.').last),
        trailing: Icon(
          _getIconForDataType(field.type),
          color: _getColorForDataType(field.type),
        ),
      ),
    );
  }

  IconData _getIconForDataType(DataType type) {
    switch (type) {
      case DataType.string:
        return Icons.text_fields;
      case DataType.integer:
      case DataType.double:
        return Icons.numbers;
      case DataType.boolean:
        return Icons.toggle_on;
      case DataType.datetime:
        return Icons.calendar_today;
      case DataType.list:
        return Icons.list;
      case DataType.map:
        return Icons.table_chart;
      case DataType.custom:
        return Icons.abc;
    }
  }

  Color _getColorForDataType(DataType type) {
    switch (type) {
      case DataType.string:
        return Colors.blue;
      case DataType.integer:
        return Colors.green;
      case DataType.double:
        return Colors.orange;
      case DataType.boolean:
        return Colors.purple;
      case DataType.datetime:
        return Colors.red;
      case DataType.list:
        return Colors.teal;
      case DataType.map:
        return Colors.brown;
      case DataType.custom:
        return Colors.grey;
    }
  }
}
