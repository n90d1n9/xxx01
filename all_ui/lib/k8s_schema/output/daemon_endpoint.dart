class DaemonEndpoint {
  final int port;
  DaemonEndpoint({required this.port});
  factory DaemonEndpoint.fromJson(Map<String, dynamic> json) {
    return DaemonEndpoint(port: json['Port']);
  }
  Map<String, dynamic> toJson() {
    return {'Port': port};
  }
}
