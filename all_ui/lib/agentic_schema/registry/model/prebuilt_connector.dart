import 'connector_action.dart';
import 'connector_category.dart';
import 'connector_trigger.dart';
import 'field_definition.dart';

enum AuthMethod { none, apiKey, oauth2, basic, bearer, jwt, certificate }

class PrebuiltConnector {
  final String id;
  final String name;
  final ConnectorCategory category;
  final String description;
  final String version;
  final String iconUrl;
  final AuthMethod authMethod;
  final List<ConnectorAction> actions;
  final List<ConnectorTrigger> triggers;
  final Map<String, FieldDefinition> authFields;
  final String? documentationUrl;
  final bool featured;
  final int usageCount;
  final double rating;

  PrebuiltConnector({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.version,
    required this.iconUrl,
    required this.authMethod,
    required this.actions,
    required this.triggers,
    required this.authFields,
    this.documentationUrl,
    this.featured = false,
    this.usageCount = 0,
    this.rating = 0.0,
  });
}
