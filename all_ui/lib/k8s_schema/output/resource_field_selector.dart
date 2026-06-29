class ResourceFieldSelector {
  final String resource;
  final String? containerName;
  final String? divisor;
  ResourceFieldSelector({
    required this.resource,
    this.containerName,
    this.divisor,
  });
  factory ResourceFieldSelector.fromJson(Map<String, dynamic> json) {
    return ResourceFieldSelector(
      resource: json['resource'],
      containerName: json['containerName'],
      divisor: json['divisor'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'resource': resource,
      if (containerName != null) 'containerName': containerName,
      if (divisor != null) 'divisor': divisor,
    };
  }
}
