class LocalObjectReference {
  final String name;
  LocalObjectReference({required this.name});
  factory LocalObjectReference.fromJson(Map<String, dynamic> json) {
    return LocalObjectReference(name: json['name']);
  }
  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
