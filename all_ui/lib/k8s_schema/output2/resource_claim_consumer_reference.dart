class ResourceClaimConsumerReference {
  final String apiGroup;
  final String resource;
  final String name;
  final String uid;
  ResourceClaimConsumerReference({
    required this.apiGroup,
    required this.resource,
    required this.name,
    required this.uid,
  });
  factory ResourceClaimConsumerReference.fromJson(Map<String, dynamic> json) {
    return ResourceClaimConsumerReference(
      apiGroup: json['apiGroup'],
      resource: json['resource'],
      name: json['name'],
      uid: json['uid'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiGroup': apiGroup,
      'resource': resource,
      'name': name,
      'uid': uid,
    };
  }
}
