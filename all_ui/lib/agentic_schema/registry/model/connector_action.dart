import 'field_definition.dart';

class ConnectorAction {
  final String id;
  final String name;
  final String description;
  final List<FieldDefinition> inputFields;
  final List<FieldDefinition> outputFields;
  final String? sampleRequest;
  final String? sampleResponse;

  ConnectorAction({
    required this.id,
    required this.name,
    required this.description,
    required this.inputFields,
    required this.outputFields,
    this.sampleRequest,
    this.sampleResponse,
  });
}
