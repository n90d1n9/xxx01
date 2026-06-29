class IngressClassParametersReference {
  final String apiGroup;
  final String kind;
  final String name;
  final String? namespace;
  final String? scope;
  IngressClassParametersReference({
    required this.apiGroup,
    required this.kind,
    required this.name,
    this.namespace,
    this.scope,
  });
  factory IngressClassParametersReference.fromJson(Map<String, dynamic> json) {
    return IngressClassParametersReference(
      apiGroup: json['apiGroup'],
      kind: json['kind'],
      name: json['name'],
      namespace: json['namespace'],
      scope: json['scope'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiGroup': apiGroup,
      'kind': kind,
      'name': name,
      if (namespace != null) 'namespace': namespace,
      if (scope != null) 'scope': scope,
    };
  }
}
