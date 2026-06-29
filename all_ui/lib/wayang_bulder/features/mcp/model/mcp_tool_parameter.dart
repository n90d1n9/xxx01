class MCPToolParameter {
  final String name;
  final String type; // string, number, boolean, array, object
  final String description;
  final bool required;
  final dynamic defaultValue;
  final List<String>? enumValues;

  MCPToolParameter({
    required this.name,
    required this.type,
    required this.description,
    required this.required,
    this.defaultValue,
    this.enumValues,
  });
}
