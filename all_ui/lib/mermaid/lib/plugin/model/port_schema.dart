class PortSchema {
  final String id;
  final String name;
  final String description;
  final PortType type;
  final bool required;
  final dynamic defaultValue;

  PortSchema({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.required = true,
    this.defaultValue,
  });
}

enum PortType { string, number, boolean, object, array, any, file, stream }
