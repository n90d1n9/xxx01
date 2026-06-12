
import 'package:intl/intl.dart';

import '../content/model/content_type_schema.dart';

class SchemaToContextConverter {
  static Map<String, dynamic> convert(ContentTypeSchema schema, String framework) {
    final className = _toPascalCase(schema.tableName);
    final camelCaseName = _toCamelCase(schema.tableName);
    final fileName = schema.tableName;
    
    return {
      'className': className,
      'camelCaseName': camelCaseName,
      'fileName': fileName,
      'tableName': schema.tableName,
      'description': schema.description ?? schema.name,
      'projectName': 'cms-${schema.tableName}',
      'timestamp': DateFormat('yyyy_MM_dd_HHmmss').format(DateTime.now()),
      'fields': schema.fields.map((field) => {
        return {
          'name': field.name,
          'label': field.label,
          'type': _getSQLTypeString(field.sqlType),
          'tsType': _getTypeScriptType(field.sqlType),
          'dartType': _getDartType(field.sqlType),
          'laravelType': _getLaravelType(field.sqlType),
          'isRequired': !field.constraints.nullable,
          'isUnique': field.constraints.unique,
          'isIndexed': field.constraints.indexed,
          'isCastable': _isCastable(field.sqlType),
          'castType': _getCastType(field.sqlType),
          'validationRules': _getValidationRules(field),
          'jsonDecoder': _getJsonDecoder(field.sqlType, field.name),
          'jsonEncoder': _getJsonEncoder(field.sqlType, field.name),
        };
      }).toList(),
      'indexedFields': schema.fields.where((f) => f.constraints.indexed).map((f) => {
        return {'name': f.name};
      }).toList(),
      'relationships': schema.relationships.map((rel) => {
        return {
          'name': rel.name,
          'target                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(rec.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text(rec.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCode(BuildContext context, WidgetRef ref, String title, String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Container(
          width: 700,
          constraints: const BoxConstraints(maxHeight: 500),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Colors.greenAccent,
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
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
}