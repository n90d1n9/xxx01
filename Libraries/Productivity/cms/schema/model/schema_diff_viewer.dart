import 'package:flutter/material.dart';

import '../../content/model/content_type_schema.dart';

class SchemaDiffViewer extends StatelessWidget {
  final ContentTypeSchema? beforeSchema;
  final ContentTypeSchema afterSchema;
  const SchemaDiffViewer({
    super.key,
    this.beforeSchema,
    required this.afterSchema,
  });
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 900,
        height: 700,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.compare_arrows, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Text(
                    'Schema Comparison',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildSchemaPanel(
                      'Before',
                      beforeSchema,
                      Colors.red.shade100,
                    ),
                  ),
                  Container(width: 1, color: Colors.grey.shade300),
                  Expanded(
                    child: _buildSchemaPanel(
                      'After',
                      afterSchema,
                      Colors.green.shade100,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemaPanel(
    String title,
    ContentTypeSchema? schema,
    Color headerColor,
  ) {
    if (schema == null) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: headerColor,
            width: double.infinity,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('New table', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: headerColor,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('v${schema.version}', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                schema.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                schema.tableName,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Text(
                'Fields:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...schema.fields.map((field) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              field.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              field.sqlType.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        if (field.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            field.description!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
