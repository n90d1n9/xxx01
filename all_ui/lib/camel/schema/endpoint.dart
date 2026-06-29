import 'schema_example.dart';

/// Represents an integration endpoint with specification support
class EndpointDefinition {
  final String id;
  final String name;
  final EndpointType type;
  final EndpointSpecification specification;
  final Map<String, dynamic> configuration;
  final List<EndpointParameter> parameters;
  final EndpointSchema? requestSchema;
  final EndpointSchema? responseSchema;

  const EndpointDefinition({
    required this.id,
    required this.name,
    required this.type,
    required this.specification,
    required this.configuration,
    this.parameters = const [],
    this.requestSchema,
    this.responseSchema,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'specification': specification.toJson(),
    'configuration': configuration,
    'parameters': parameters.map((p) => p.toJson()).toList(),
    'requestSchema': requestSchema?.toJson(),
    'responseSchema': responseSchema?.toJson(),
  };
}

/// Endpoint types supported by the platform
enum EndpointType { rest, soap, kafka, jms, database, file, ftp, email, custom }

/// Specification formats for endpoints
class EndpointSpecification {
  final SpecificationType type;
  final String? url;
  final Map<String, dynamic> definition;

  const EndpointSpecification({
    required this.type,
    this.url,
    required this.definition,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'url': url,
    'definition': definition,
  };
}

enum SpecificationType { openapi, swagger, wsdl, asyncapi, custom }

/// Parameter definition for endpoints
class EndpointParameter {
  final String name;
  final String type;
  final bool required;
  final dynamic defaultValue;
  final String? description;
  final List<String>? enumValues;
  final ParameterLocation location;

  const EndpointParameter({
    required this.name,
    required this.type,
    this.required = false,
    this.defaultValue,
    this.description,
    this.enumValues,
    this.location = ParameterLocation.body,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'required': required,
    'defaultValue': defaultValue,
    'description': description,
    'enumValues': enumValues,
    'location': location.name,
  };
}

enum ParameterLocation { path, query, header, body, cookie }

/// Schema definition for request/response
class EndpointSchema {
  final String contentType;
  final Map<String, dynamic> schema;
  final List<SchemaExample>? examples;

  const EndpointSchema({
    required this.contentType,
    required this.schema,
    this.examples,
  });

  Map<String, dynamic> toJson() => {
    'contentType': contentType,
    'schema': schema,
    'examples': examples?.map((e) => e.toJson()).toList(),
  };
}
