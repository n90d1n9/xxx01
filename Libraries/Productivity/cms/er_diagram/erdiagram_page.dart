import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../content/contents_type_provider.dart';
import '../content/model/content_type_schema.dart';
import '../models/diagram_node.dart';
import '../models/relation_type.dart';
import '../models/ui_field_type.dart';
import '../schema/state/er_diagram_provider.dart';
import '../widgets/connection_painter.dart';
import 'erdiagram_state.dart';

class ERDiagramPage extends ConsumerStatefulWidget {
  const ERDiagramPage({super.key});
  @override
  ConsumerState<ERDiagramPage> createState() => _ERDiagramPageState();
}

class _ERDiagramPageState extends ConsumerState<ERDiagramPage> {
  final TransformationController _transformController =
      TransformationController();
  String? _draggingNodeId;
  Offset? _dragStartPosition;
  @override
  Widget build(BuildContext context) {
    final diagramState = ref.watch(erDiagramProvider);
    final schemasAsync = ref.watch(contentTypesProvider);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('ER Diagram Designer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            onPressed: () => ref.read(erDiagramProvider.notifier).autoLayout(),
            tooltip: 'Auto Layout',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () => ref
                .read(erDiagramProvider.notifier)
                .setZoom(diagramState.zoom + 0.1),
            tooltip: 'Zoom In',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () => ref
                .read(erDiagramProvider.notifier)
                .setZoom(diagramState.zoom - 0.1),
            tooltip: 'Zoom Out',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportDiagram,
            tooltip: 'Export',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: schemasAsync.when(
        data: (schemas) => _buildDiagram(diagramState, schemas),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'zoom_fit',
            onPressed: () {
              _transformController.value = Matrix4.identity();
              ref.read(erDiagramProvider.notifier).setZoom(1.0);
            },
            child: const Icon(Icons.fit_screen),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: () => ref.read(erDiagramProvider.notifier).autoLayout(),
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagram(
    ERDiagramState diagramState,
    List<ContentTypeSchema> schemas,
  ) {
    return GestureDetector(
      onTapDown: (_) => ref.read(erDiagramProvider.notifier).deselectAll(),
      child: InteractiveViewer(
        transformationController: _transformController,
        boundaryMargin: const EdgeInsets.all(1000),
        minScale: 0.5,
        maxScale: 2.0,
        child: Container(
          width: 2000,
          height: 2000,
          color: Colors.white,
          child: CustomPaint(
            painter: ConnectionPainter(
              connections: diagramState.connections,
              nodes: diagramState.nodes,
              schemas: schemas,
            ),
            child: Stack(
              children: [
                ...diagramState.nodes.entries.map((entry) {
                  final schema = schemas.firstWhere((s) => s.id == entry.key);
                  return _buildSchemaNode(schema, entry.value, diagramState);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSchemaNode(
    ContentTypeSchema schema,
    DiagramNode node,
    ERDiagramState diagramState,
  ) {
    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _draggingNodeId = schema.id;
            _dragStartPosition = node.position;
          });
          ref.read(erDiagramProvider.notifier).selectNode(schema.id);
        },
        onPanUpdate: (details) {
          if (_draggingNodeId == schema.id && _dragStartPosition != null) {
            final newPosition = Offset(
              _dragStartPosition!.dx + details.localPosition.dx - 100,
              _dragStartPosition!.dy + details.localPosition.dy - 75,
            );
            ref
                .read(erDiagramProvider.notifier)
                .updateNodePosition(schema.id, newPosition);
          }
        },
        onPanEnd: (_) {
          setState(() {
            _draggingNodeId = null;
            _dragStartPosition = null;
          });
        },
        onTap: () => ref.read(erDiagramProvider.notifier).selectNode(schema.id),
        child: Container(
          width: node.size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: node.isSelected ? Colors.blue : Colors.grey.shade300,
              width: node.isSelected ? 3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getSchemaColor(schema.icon),
                      _getSchemaColor(schema.icon).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconData(schema.icon),
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        schema.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...schema.fields.take(5).map((field) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                _getFieldTypeIcon(field.uiType),
                                size: 12,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  field.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!field.constraints.nullable)
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                      if (schema.fields.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '+ ${schema.fields.length - 5} more',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSchemaColor(String icon) {
    switch (icon) {
      case 'article':
        return const Color(0xFF6366F1);
      case 'image':
        return const Color(0xFFEC4899);
      case 'video':
        return const Color(0xFFF59E0B);
      case 'person':
        return const Color(0xFF10B981);
      case 'category':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'article':
        return Icons.article;
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_library;
      case 'person':
        return Icons.person;
      case 'category':
        return Icons.category;
      default:
        return Icons.folder;
    }
  }

  IconData _getFieldTypeIcon(UIFieldType type) {
    switch (type) {
      case UIFieldType.textInput:
        return Icons.text_fields;
      case UIFieldType.numberInput:
        return Icons.numbers;
      case UIFieldType.datePicker:
        return Icons.calendar_today;
      case UIFieldType.toggle:
        return Icons.toggle_on;
      case UIFieldType.imageUpload:
        return Icons.image;
      default:
        return Icons.create;
    }
  }

  void _exportDiagram() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Diagram'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Mermaid Diagram'),
              subtitle: const Text('Export as Mermaid ER diagram code'),
              onTap: () => _exportAsMermaid(),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('PNG Image'),
              subtitle: const Text('Coming soon'),
              enabled: false,
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('SVG Vector'),
              subtitle: const Text('Coming soon'),
              enabled: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportAsMermaid() {
    final schemas = ref.read(contentTypesProvider).value ?? [];
    final buffer = StringBuffer();
    buffer.writeln('erDiagram');
    for (var schema in schemas) {
      buffer.writeln('    ${schema.tableName} {');
      for (var field in schema.fields) {
        final type = field.sqlType.name;
        final nullable = field.constraints.nullable ? '' : ' NOT NULL';
        buffer.writeln('        $type ${field.name}$nullable');
      }
      buffer.writeln('    }');
      for (var rel in schema.relationships) {
        final relSymbol = _getRelationshipSymbol(rel.type);
        buffer.writeln(
          '    ${schema.tableName} $relSymbol ${rel.targetSchemaId} : "${rel.name}"',
        );
      }
    }
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mermaid Diagram Code'),
        content: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: SelectableText(
              buffer.toString(),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: buffer.toString()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getRelationshipSymbol(RelationType type) {
    switch (type) {
      case RelationType.oneToOne:
        return '||--||';
      case RelationType.oneToMany:
        return '||--o{';
      case RelationType.manyToOne:
        return '}o--||';
      case RelationType.manyToMany:
        return '}o--o{';
    }
  }
}
