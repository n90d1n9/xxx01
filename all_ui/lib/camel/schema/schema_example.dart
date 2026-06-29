class SchemaExample {
  final String name;
  final Map<String, dynamic> value;

  const SchemaExample({required this.name, required this.value});

  Map<String, dynamic> toJson() => {'name': name, 'value': value};
}
