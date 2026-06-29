class RuleWithOperations {
  final List<String>? operations;
  final List<String>? apiGroups;
  final List<String>? apiVersions;
  final List<String>? resources;
  final String? scope;
  RuleWithOperations({
    this.operations,
    this.apiGroups,
    this.apiVersions,
    this.resources,
    this.scope,
  });
  factory RuleWithOperations.fromJson(Map<String, dynamic> json) {
    return RuleWithOperations(
      operations:
          json['operations'] != null
              ? List<String>.from(json['operations'])
              : null,
      apiGroups:
          json['apiGroups'] != null
              ? List<String>.from(json['apiGroups'])
              : null,
      apiVersions:
          json['apiVersions'] != null
              ? List<String>.from(json['apiVersions'])
              : null,
      resources:
          json['resources'] != null
              ? List<String>.from(json['resources'])
              : null,
      scope: json['scope'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (operations != null) 'operations': operations,
      if (apiGroups != null) 'apiGroups': apiGroups,
      if (apiVersions != null) 'apiVersions': apiVersions,
      if (resources != null) 'resources': resources,
      if (scope != null) 'scope': scope,
    };
  }
}
