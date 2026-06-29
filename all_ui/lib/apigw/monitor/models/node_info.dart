class NodeInfo {
  final String hostname;

  NodeInfo({required this.hostname});

  factory NodeInfo.fromJson(Map<String, dynamic> json) {
    return NodeInfo(hostname: json['hostname']);
  }
}
