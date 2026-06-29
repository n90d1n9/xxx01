class ClientIPConfig {
  final int? timeoutSeconds;
  ClientIPConfig({this.timeoutSeconds});
  factory ClientIPConfig.fromJson(Map<String, dynamic> json) {
    return ClientIPConfig(timeoutSeconds: json['timeoutSeconds']);
  }
  Map<String, dynamic> toJson() {
    return {if (timeoutSeconds != null) 'timeoutSeconds': timeoutSeconds};
  }
}
