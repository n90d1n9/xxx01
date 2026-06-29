import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/content_type_schema.dart';
import '../../schema/model/field_contraint.dart';
import '../../schema/model/field_schema.dart';
import '../../models/select_option.dart';
import '../../models/sql_type.dart';
import '../../models/ui_field_type.dart';
import '../../models/validation_rules.dart';
import '../../models/widget_options.dart';
import '../state/content_entries_provider.dart';

class ContentEntriesPage extends ConsumerWidget {
  final ContentTypeSchema contentType;

  const ContentEntriesPage({super.key, required this.contentType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(contentEntriesProvider(contentType.id));

    return Scaffold(
      appBar: AppBar(title: Text(contentType.name)),
      body: entriesAsync.when(
        data:
            (entries) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    entries.isEmpty
                        ? 'No entries yet'
                        : '${entries.length} entries',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  static List<FieldSchema> _getProductFields() {
    return [
      FieldSchema(
        id: 'f1',
        name: 'name',
        label: 'Product Name',
        uiType: UIFieldType.textInput,
        sqlType: SQLType.varchar,
        constraints: const FieldConstraints(nullable: false),
        position: 0,
      ),
      FieldSchema(
        id: 'f2',
        name: 'slug',
        label: 'URL Slug',
        uiType: UIFieldType.slug,
        sqlType: SQLType.varchar,
        constraints: const FieldConstraints(
          unique: true,
          nullable: false,
          indexed: true,
        ),
        widgetOptions: const WidgetOptions(slugFrom: 'name'),
        position: 1,
      ),
      FieldSchema(
        id: 'f3',
        name: 'description',
        label: 'Description',
        uiType: UIFieldType.richTextEditor,
        sqlType: SQLType.text,
        constraints: const FieldConstraints(),
        position: 2,
      ),
      FieldSchema(
        id: 'f4',
        name: 'price',
        label: 'Price',
        uiType: UIFieldType.numberInput,
        sqlType: SQLType.decimal,
        constraints: const FieldConstraints(nullable: false),
        validation: const ValidationRules(min: 0),
        position: 3,
      ),
      FieldSchema(
        id: 'f5',
        name: 'stock',
        label: 'Stock Quantity',
        uiType: UIFieldType.numberInput,
        sqlType: SQLType.integer,
        constraints: const FieldConstraints(nullable: false),
        validation: const ValidationRules(min: 0),
        defaultValue: 0,
        position: 4,
      ),
    ];
  }

  static List<FieldSchema> _getPostFields() {
    return [
      FieldSchema(
        id: 'f1',
        name: 'title',
        label: 'Title',
        uiType: UIFieldType.textInput,
        sqlType: SQLType.varchar,
        constraints: const FieldConstraints(nullable: false),
        validation: const ValidationRules(minLength: 5, maxLength: 200),
        position: 0,
      ),
      FieldSchema(
        id: 'f2',
        name: 'slug',
        label: 'URL Slug',
        uiType: UIFieldType.slug,
        sqlType: SQLType.varchar,
        constraints: const FieldConstraints(
          unique: true,
          nullable: false,
          indexed: true,
        ),
        widgetOptions: const WidgetOptions(slugFrom: 'title'),
        position: 1,
      ),
      FieldSchema(
        id: 'f3',
        name: 'excerpt',
        label: 'Excerpt',
        uiType: UIFieldType.textArea,
        sqlType: SQLType.text,
        constraints: const FieldConstraints(),
        validation: const ValidationRules(maxLength: 500),
        position: 2,
      ),
      FieldSchema(
        id: 'f4',
        name: 'content',
        label: 'Content',
        uiType: UIFieldType.richTextEditor,
        sqlType: SQLType.text,
        constraints: const FieldConstraints(nullable: false),
        position: 3,
      ),
      FieldSchema(
        id: 'f5',
        name: 'featured_image',
        label: 'Featured Image',
        uiType: UIFieldType.imageUpload,
        sqlType: SQLType.varchar,
        constraints: const FieldConstraints(),
        position: 4,
      ),
    ];
  }

  static List<FieldSchema> _getOrderFields() {
    return [
      FieldSchema(
        id: 'f1',
        name: 'order_number',
        label: 'Order Number',
        uiType: UIFieldType.textInput,
        sqlType: SQLType.varchar,
        constraints: const FieldConstraints(
          unique: true,
          nullable: false,
          indexed: true,
        ),
        position: 0,
      ),
      FieldSchema(
        id: 'f2',
        name: 'total_amount',
        label: 'Total Amount',
        uiType: UIFieldType.numberInput,
        sqlType: SQLType.decimal,
        constraints: const FieldConstraints(nullable: false),
        validation: const ValidationRules(min: 0),
        position: 1,
      ),
      FieldSchema(
        id: 'f3',
        name: 'status',
        label: 'Status',
        uiType: UIFieldType.dropdown,
        sqlType: SQLType.varchar,
        constraints: const FieldConstraints(nullable: false),
        widgetOptions: WidgetOptions(
          options: [
            const SelectOption(value: 'pending', label: 'Pending'),
            const SelectOption(value: 'processing', label: 'Processing'),
            const SelectOption(value: 'shipped', label: 'Shipped'),
            const SelectOption(value: 'delivered', label: 'Delivered'),
            const SelectOption(value: 'cancelled', label: 'Cancelled'),
          ],
        ),
        position: 2,
      ),
    ];
  }

  static List<FieldSchema> _getCategoryFields() {
    return [
      FieldSchema(
        id: 'f1',
        name: 'name',
        label: 'Name',
        uiType: UIFieldType.textInput,
        sqlType: SQLType.varchar,
        constraints: const FieldConstraints(nullable: false),
        position: 0,
      ),
      FieldSchema(
        id: 'f2',
        name: 'slug',
        label: 'Slug',
        uiType: UIFieldType.slug,
        sqlType: SQLType.varchar,
        constraints: const FieldConstraints(
          unique: true,
          nullable: false,
          indexed: true,
        ),
        widgetOptions: const WidgetOptions(slugFrom: 'name'),
        position: 1,
      ),
      FieldSchema(
        id: 'f3',
        name: 'description',
        label: 'Description',
        uiType: UIFieldType.textArea,
        sqlType: SQLType.text,
        constraints: const FieldConstraints(),
        position: 2,
      ),
    ];
  }

  static List<FieldSchema> _getBasicFields() {
    return [
      FieldSchema(
        id: 'f1',
        name: 'title',
        label: 'Title',
        uiType: UIFieldType.textInput,
        sqlType: SQLType.varchar,
        constraints: const FieldConstraints(nullable: false),
        position: 0,
      ),
      FieldSchema(
        id: 'f2',
        name: 'description',
        label: 'Description',
        uiType: UIFieldType.textArea,
        sqlType: SQLType.text,
        constraints: const FieldConstraints(),
        position: 1,
      ),
    ];
  }
}
