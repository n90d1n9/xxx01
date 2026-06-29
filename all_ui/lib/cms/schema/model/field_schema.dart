import 'field_contraint.dart';
import '../../models/sql_type.dart';
import '../../models/ui_field_type.dart';
import '../../models/validation_rules.dart';
import '../../models/widget_options.dart';

/// Complete field schema with database and UI mappings

class FieldSchema {
  final String id;
  final String name;
  final String label;
  final String? description;
  final UIFieldType uiType;
  final SQLType sqlType;
  final FieldConstraints constraints;
  final ValidationRules? validation;
  final WidgetOptions? widgetOptions;
  final dynamic defaultValue;
  final int position;
  final bool isSystemField;
  final bool isEncrypted; // For sensitive data
  final bool isComputed; // Virtual/computed field
  final String? computeExpression; // SQL expression for computed fields
  final Map<String, dynamic>? metadata;

  const FieldSchema({
    required this.id,
    required this.name,
    required this.label,
    this.description,
    required this.uiType,
    required this.sqlType,
    required this.constraints,
    this.validation,
    this.widgetOptions,
    this.defaultValue,
    required this.position,
    this.isSystemField = false,
    this.isEncrypted = false,
    this.isComputed = false,
    this.computeExpression,
    this.metadata,
  });

  String toSQLColumn() {
    if (isComputed) {
      return '$name ${_sqlTypeToString(sqlType)} GENERATED ALWAYS AS ($computeExpression) STORED';
    }

    final buffer = StringBuffer();
    buffer.write('$name ${_sqlTypeToString(sqlType)}');

    if (!constraints.nullable) buffer.write(' NOT NULL');
    if (constraints.unique) buffer.write(' UNIQUE');
    if (defaultValue != null) buffer.write(' DEFAULT $defaultValue');
    if (constraints.checkConstraint != null) {
      buffer.write(' CHECK (${constraints.checkConstraint})');
    }

    return buffer.toString();
  }

  String _sqlTypeToString(SQLType type) {
    switch (type) {
      case SQLType.varchar:
        return 'VARCHAR(${widgetOptions?.maxLength ?? 255})';
      case SQLType.text:
        return 'TEXT';
      case SQLType.integer:
        return 'INTEGER';
      case SQLType.bigint:
        return 'BIGINT';
      case SQLType.decimal:
        return 'DECIMAL(10,2)';
      case SQLType.boolean:
        return 'BOOLEAN';
      case SQLType.date:
        return 'DATE';
      case SQLType.timestamp:
        return 'TIMESTAMP';
      case SQLType.time:
        return 'TIME';
      case SQLType.json:
        return 'JSON';
      case SQLType.jsonb:
        return 'JSONB';
      case SQLType.uuid:
        return 'UUID';
      case SQLType.bytea:
        return 'BYTEA';
    }
  }

  String toJavaType() {
    switch (sqlType) {
      case SQLType.varchar:
      case SQLType.text:
        return 'String';
      case SQLType.integer:
        return 'Integer';
      case SQLType.bigint:
        return 'Long';
      case SQLType.decimal:
        return 'BigDecimal';
      case SQLType.boolean:
        return 'Boolean';
      case SQLType.date:
        return 'LocalDate';
      case SQLType.timestamp:
        return 'LocalDateTime';
      case SQLType.time:
        return 'LocalTime';
      case SQLType.uuid:
        return 'UUID';
      default:
        return 'String';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'label': label,
    'description': description,
    'uiType': uiType.name,
    'sqlType': sqlType.name,
    'constraints': constraints.toJson(),
    'validation': validation?.toJson(),
    'widgetOptions': widgetOptions?.toJson(),
    'defaultValue': defaultValue,
    'position': position,
    'isSystemField': isSystemField,
    'isEncrypted': isEncrypted,
    'isComputed': isComputed,
    'computeExpression': computeExpression,
    'metadata': metadata,
  };

  factory FieldSchema.fromJson(Map<String, dynamic> json) => FieldSchema(
    id: json['id'],
    name: json['name'],
    label: json['label'],
    description: json['description'],
    uiType: UIFieldType.values.firstWhere((e) => e.name == json['uiType']),
    sqlType: SQLType.values.firstWhere((e) => e.name == json['sqlType']),
    constraints: FieldConstraints.fromJson(json['constraints']),
    validation:
        json['validation'] != null
            ? ValidationRules.fromJson(json['validation'])
            : null,
    widgetOptions:
        json['widgetOptions'] != null
            ? WidgetOptions.fromJson(json['widgetOptions'])
            : null,
    defaultValue: json['defaultValue'],
    position: json['position'],
    isSystemField: json['isSystemField'] ?? false,
    isEncrypted: json['isEncrypted'] ?? false,
    isComputed: json['isComputed'] ?? false,
    computeExpression: json['computeExpression'],
    metadata: json['metadata'],
  );

  FieldSchema copyWith({
    String? id,
    String? name,
    String? label,
    String? description,
    UIFieldType? uiType,
    SQLType? sqlType,
    FieldConstraints? constraints,
    ValidationRules? validation,
    WidgetOptions? widgetOptions,
    dynamic defaultValue,
    int? position,
    bool? isSystemField,
    bool? isEncrypted,
    bool? isComputed,
    String? computeExpression,
    Map<String, dynamic>? metadata,
  }) {
    return FieldSchema(
      id: id ?? this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      description: description ?? this.description,
      uiType: uiType ?? this.uiType,
      sqlType: sqlType ?? this.sqlType,
      constraints: constraints ?? this.constraints,
      validation: validation ?? this.validation,
      widgetOptions: widgetOptions ?? this.widgetOptions,
      defaultValue: defaultValue ?? this.defaultValue,
      position: position ?? this.position,
      isSystemField: isSystemField ?? this.isSystemField,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      isComputed: isComputed ?? this.isComputed,
      computeExpression: computeExpression ?? this.computeExpression,
      metadata: metadata ?? this.metadata,
    );
  }
}
