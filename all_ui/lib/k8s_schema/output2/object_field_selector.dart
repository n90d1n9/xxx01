class ObjectFieldSelector {
  final String fieldPath;
  final String? apiVersion;
  ObjectFieldSelector({required this.fieldPath, this.apiVersion});
  factory ObjectFieldSelector.fromJson(Map<String, dynamic> json) {
    return ObjectFieldSelector(
      fieldPath: json['fieldPath'],
      apiVersion: json['apiVersion'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'fieldPath': fieldPath,
      if (apiVersion != null) 'apiVersion': apiVersion,
    };
  }
}
