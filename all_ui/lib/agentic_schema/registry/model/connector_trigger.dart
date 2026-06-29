import 'field_definition.dart';

class ConnectorTrigger {
  final String id;
  final String name;
  final String description;
  final TriggerType type;
  final List<FieldDefinition> configFields;
  final List<FieldDefinition> outputFields;

  ConnectorTrigger({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.configFields,
    required this.outputFields,
  });
}

enum TriggerType { webhook, polling, stream }
