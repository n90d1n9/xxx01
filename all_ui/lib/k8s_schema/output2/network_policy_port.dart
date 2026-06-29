class NetworkPolicyPort {
  final String? protocol;
  final dynamic port;
  final int? endPort;
  NetworkPolicyPort({this.protocol, this.port, this.endPort});
  factory NetworkPolicyPort.fromJson(Map<String, dynamic> json) {
    return NetworkPolicyPort(
      protocol: json['protocol'],
      port: json['port'],
      endPort: json['endPort'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (protocol != null) 'protocol': protocol,
      if (port != null) 'port': port,
      if (endPort != null) 'endPort': endPort,
    };
  }
}
