class TCPSocketAction {
  final dynamic port;
  final String? host;
  TCPSocketAction({required this.port, this.host});
  factory TCPSocketAction.fromJson(Map<String, dynamic> json) {
    return TCPSocketAction(port: json['port'], host: json['host']);
  }
  Map<String, dynamic> toJson() {
    return {'port': port, if (host != null) 'host': host};
  }
}
