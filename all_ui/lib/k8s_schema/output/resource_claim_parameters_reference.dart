class ResourceClaimParametersReference {
  final String apiGroup;
  final String kind;
  final String name;
  ResourceClaimParametersReference({
    required this.apiGroup,
    required this.kind,
    required this.name,
  });
  factory ResourceClaimParametersReference.fromJson(Map<String, dynamic> json) {
    return ResourceClaimParametersReference(
      apiGroup: json['apiGroup'],
      kind: json['kind'],
      name: json['name'],
    );
  }
  Map<String, dynamic> toJson() {
    return {'apiGroup': apiGroup, 'kind': kind, 'name': name};
  }
}
