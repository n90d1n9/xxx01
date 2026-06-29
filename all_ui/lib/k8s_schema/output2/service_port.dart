class ServicePort {
  final String? name;
  final String? protocol;
  final int? port;
  final dynamic targetPort;
  final int? nodePort;
  final String? appProtocol;
  ServicePort({
    this.name,
    this.protocol,
    this.port,
    this.targetPort,
    this.nodePort,
    this.appProtocol,
  });
  factory ServicePort.fromJson(Map<String, dynamic> json) {
    return ServicePort(
      name: json['name'],
      protocol: json['protocol'],
      port: json['port'],
      targetPort: json['targetPort'],
      nodePort: json['nodePort'],
      appProtocol: json['appProtocol'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (protocol != null) 'protocol': protocol,
      if (port != null) 'port': port,
      if (targetPort != null) 'targetPort': targetPort,
      if (nodePort != null) 'nodePort': nodePort,
      if (appProtocol != null) 'appProtocol': appProtocol,
    };
  }
}
