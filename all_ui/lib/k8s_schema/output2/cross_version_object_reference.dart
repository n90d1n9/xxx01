class CrossVersionObjectReference {
  final String kind;
  final String name;
  final String? apiVersion;
  CrossVersionObjectReference({
    required this.kind,
    required this.name,
    this.apiVersion,
  });
  factory CrossVersionObjectReference.fromJson(Map<String, dynamic> json) {
    return CrossVersionObjectReference(
      kind: json['kind'],
      name: json['name'],
      apiVersion: json['apiVersion'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'name': name,
      if (apiVersion != null) 'apiVersion': apiVersion,
    };
  }
}
