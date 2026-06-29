import 'client_ipconfig.dart';

class SessionAffinityConfig {
  final ClientIPConfig? clientIP;
  SessionAffinityConfig({this.clientIP});
  factory SessionAffinityConfig.fromJson(Map<String, dynamic> json) {
    return SessionAffinityConfig(
      clientIP:
          json['clientIP'] != null
              ? ClientIPConfig.fromJson(json['clientIP'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {if (clientIP != null) 'clientIP': clientIP!.toJson()};
  }
}
