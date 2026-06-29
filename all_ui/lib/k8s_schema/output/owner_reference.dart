class OwnerReference {
  final String apiVersion;
  final String kind;
  final String name;
  final String uid;
  final bool? controller;
  final bool? blockOwnerDeletion;
  OwnerReference({
    required this.apiVersion,
    required this.kind,
    required this.name,
    required this.uid,
    this.controller,
    this.blockOwnerDeletion,
  });
  factory OwnerReference.fromJson(Map<String, dynamic> json) {
    return OwnerReference(
      apiVersion: json['apiVersion'],
      kind: json['kind'],
      name: json['name'],
      uid: json['uid'],
      controller: json['controller'],
      blockOwnerDeletion: json['blockOwnerDeletion'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'name': name,
      'uid': uid,
      if (controller != null) 'controller': controller,
      if (blockOwnerDeletion != null) 'blockOwnerDeletion': blockOwnerDeletion,
    };
  }
}
