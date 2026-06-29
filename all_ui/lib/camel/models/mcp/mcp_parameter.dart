enum MCPToolType { http, database, fileSystem, ai, integration, custom }

class MCPParameter {
  final String name;
  final String description;
  final MCPParameterType type;
  final bool required;
  final dynamic defaultValue;
  final List<String>? enumValues;

  const MCPParameter({
    required this.name,
    required this.description,
    required this.type,
    this.required = false,
    this.defaultValue,
    this.enumValues,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'type': type.name,
    'required': required,
    'defaultValue': defaultValue,
    'enumValues': enumValues,
  };
}

enum MCPParameterType { string, number, boolean, object, array }

class MCPAuthentication {
  final AuthType type;
  final Map<String, dynamic> credentials;

  const MCPAuthentication({required this.type, required this.credentials});
}

enum AuthType { none, apiKey, oauth, basic, bearer }
