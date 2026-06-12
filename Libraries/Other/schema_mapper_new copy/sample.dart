import 'models/data_schema.dart';
import 'models/schema_field.dart';

class SchemaExamples {
  // User Profile Schema
  static final DataSchema userProfileSchema = DataSchema(
    id: 'user_profile_v1',
    name: 'User Profile',
    description: 'Comprehensive user profile schema',
    fields: [
      SchemaField(
        id: 'user_id',
        name: 'User ID',
        type: DataType.string,
        isNullable: false,
      ),
      SchemaField(
        id: 'full_name',
        name: 'Full Name',
        type: DataType.string,
        isNullable: false,
      ),
      SchemaField(
        id: 'email',
        name: 'Email Address',
        type: DataType.string,
        metadata: {'validation': 'email', 'max_length': 255},
      ),
      SchemaField(
        id: 'age',
        name: 'Age',
        type: DataType.integer,
        metadata: {'min_value': 0, 'max_value': 120},
      ),
      SchemaField(
        id: 'registration_date',
        name: 'Registration Date',
        type: DataType.datetime,
      ),
      SchemaField(
        id: 'is_active',
        name: 'Active Status',
        type: DataType.boolean,
        defaultValue: true,
      ),
      SchemaField(
        id: 'roles',
        name: 'User Roles',
        type: DataType.list,
        metadata: {'item_type': DataType.string},
      ),
    ],
  );

  // Product Inventory Schema
  static final DataSchema productInventorySchema = DataSchema(
    id: 'product_inventory_v2',
    name: 'Product Inventory',
    description: 'Detailed product inventory tracking',
    fields: [
      SchemaField(
        id: 'product_id',
        name: 'Product ID',
        type: DataType.string,
        isNullable: false,
      ),
      SchemaField(
        id: 'product_name',
        name: 'Product Name',
        type: DataType.string,
        metadata: {'max_length': 200},
      ),
      SchemaField(
        id: 'price',
        name: 'Unit Price',
        type: DataType.double,
        metadata: {'min_value': 0, 'currency': 'USD'},
      ),
      SchemaField(
        id: 'quantity',
        name: 'Stock Quantity',
        type: DataType.integer,
        metadata: {'min_value': 0},
      ),
      SchemaField(
        id: 'categories',
        name: 'Product Categories',
        type: DataType.list,
        metadata: {'item_type': DataType.string},
      ),
      SchemaField(
        id: 'metadata',
        name: 'Additional Metadata',
        type: DataType.map,
        metadata: {
          'allowed_keys': ['brand', 'color', 'size'],
        },
      ),
      SchemaField(
        id: 'is_available',
        name: 'Availability Status',
        type: DataType.boolean,
        defaultValue: true,
      ),
    ],
  );

  // Financial Transaction Schema
  static final DataSchema financialTransactionSchema = DataSchema(
    id: 'financial_transaction_v1',
    name: 'Financial Transaction',
    description: 'Detailed financial transaction record',
    fields: [
      SchemaField(
        id: 'transaction_id',
        name: 'Transaction ID',
        type: DataType.string,
        isNullable: false,
      ),
      SchemaField(
        id: 'amount',
        name: 'Transaction Amount',
        type: DataType.double,
        metadata: {'currency': 'USD', 'min_value': 0},
      ),
      SchemaField(
        id: 'transaction_date',
        name: 'Transaction Date',
        type: DataType.datetime,
        isNullable: false,
      ),
      SchemaField(
        id: 'transaction_type',
        name: 'Transaction Type',
        type: DataType.string,
        metadata: {
          'allowed_values': ['deposit', 'withdrawal', 'transfer'],
        },
      ),
      SchemaField(
        id: 'is_completed',
        name: 'Transaction Status',
        type: DataType.boolean,
        defaultValue: false,
      ),
      SchemaField(
        id: 'additional_details',
        name: 'Additional Transaction Details',
        type: DataType.map,
      ),
    ],
  );

  // Complex Custom Schema Example
  static final DataSchema complexCustomSchema = DataSchema(
    id: 'complex_custom_v1',
    name: 'Complex Custom Schema',
    description: 'Demonstrates complex nested and custom type usage',
    fields: [
      SchemaField(
        id: 'primary_identifier',
        name: 'Primary Identifier',
        type: DataType.string,
        isNullable: false,
      ),
      SchemaField(
        id: 'nested_data',
        name: 'Nested Complex Data',
        type: DataType.map,
        metadata: {
          'structure': {
            'personal_info': {'name': DataType.string, 'age': DataType.integer},
            'professional_info': {
              'company': DataType.string,
              'position': DataType.string,
            },
          },
        },
      ),
      SchemaField(
        id: 'multi_dimensional_list',
        name: 'Multi-Dimensional List',
        type: DataType.list,
        metadata: {
          'item_type': DataType.list,
          'nested_item_type': DataType.double,
        },
      ),
      SchemaField(
        id: 'custom_type_example',
        name: 'Custom Type Field',
        type: DataType.custom,
        metadata: {'custom_type_definition': 'specialized_object'},
      ),
    ],
  );

  // Method to generate schemas from JSON (for import scenarios)
  static DataSchema fromJson(Map<String, dynamic> json) {
    return DataSchema.fromJson(json);
  }

  // Method to get all predefined schemas
  static List<DataSchema> getAllSchemas() {
    return [
      userProfileSchema,
      productInventorySchema,
      financialTransactionSchema,
      complexCustomSchema,
    ];
  }
}
