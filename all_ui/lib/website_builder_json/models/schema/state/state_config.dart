import 'state_computed.dart';
import 'state_variable.dart';

class StateConfig {
  final String id;
  final String scope; // global, page, component
  final Map<String, StateVariable> variables;
  final List<StateComputed>? computed;

  StateConfig({
    required this.id,
    required this.scope,
    required this.variables,
    this.computed,
  });

  factory StateConfig.fromJson(Map<String, dynamic> json) {
    return StateConfig(
      id: json['id'] as String,
      scope: json['scope'] as String,
      variables: (json['variables'] as Map<String, dynamic>).map(
        (k, v) =>
            MapEntry(k, StateVariable.fromJson(v as Map<String, dynamic>)),
      ),
      computed:
          json['computed'] != null
              ? (json['computed'] as List)
                  .map((c) => StateComputed.fromJson(c as Map<String, dynamic>))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'scope': scope,
    'variables': variables.map((k, v) => MapEntry(k, v.toJson())),
    if (computed != null) 'computed': computed!.map((c) => c.toJson()).toList(),
  };
}
