class ImportedField {
  final String name;
  final String type;
  final bool nullable;
  final bool unique;
  final dynamic defaultValue;
  const ImportedField({
    required this.name,
    required this.type,
    required this.nullable,
    this.unique = false,
    this.defaultValue,
  });
}
