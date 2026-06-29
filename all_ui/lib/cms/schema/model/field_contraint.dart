/// Field constraints for database schema
class FieldConstraints {
  final bool unique;
  final bool indexed;
  final bool nullable;
  final String? checkConstraint;
  final String? foreignKey;
  final String? onDelete; // CASCADE, SET NULL, RESTRICT
  final String? onUpdate;
  final List<String>? enumValues;

  const FieldConstraints({
    this.unique = false,
    this.indexed = false,
    this.nullable = true,
    this.checkConstraint,
    this.foreignKey,
    this.onDelete,
    this.onUpdate,
    this.enumValues,
  });

  Map<String, dynamic> toJson() => {
    'unique': unique,
    'indexed': indexed,
    'nullable': nullable,
    'checkConstraint': checkConstraint,
    'foreignKey': foreignKey,
    'onDelete': onDelete,
    'onUpdate': onUpdate,
    'enumValues': enumValues,
  };

  factory FieldConstraints.fromJson(Map<String, dynamic> json) =>
      FieldConstraints(
        unique: json['unique'] ?? false,
        indexed: json['indexed'] ?? false,
        nullable: json['nullable'] ?? true,
        checkConstraint: json['checkConstraint'],
        foreignKey: json['foreignKey'],
        onDelete: json['onDelete'],
        onUpdate: json['onUpdate'],
        enumValues: json['enumValues']?.cast<String>(),
      );

  FieldConstraints copyWith({
    bool? unique,
    bool? indexed,
    bool? nullable,
    String? checkConstraint,
    String? foreignKey,
    String? onDelete,
    String? onUpdate,
    List<String>? enumValues,
  }) {
    return FieldConstraints(
      unique: unique ?? this.unique,
      indexed: indexed ?? this.indexed,
      nullable: nullable ?? this.nullable,
      checkConstraint: checkConstraint ?? this.checkConstraint,
      foreignKey: foreignKey ?? this.foreignKey,
      onDelete: onDelete ?? this.onDelete,
      onUpdate: onUpdate ?? this.onUpdate,
      enumValues: enumValues ?? this.enumValues,
    );
  }
}
