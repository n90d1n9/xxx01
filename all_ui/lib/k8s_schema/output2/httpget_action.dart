import 'httpheader.dart';

class HTTPGetAction {
  final String? path;
  final dynamic port;
  final String? host;
  final String? scheme;
  final List<HTTPHeader>? httpHeaders;
  HTTPGetAction({
    this.path,
    required this.port,
    this.host,
    this.scheme,
    this.httpHeaders,
  });
  factory HTTPGetAction.fromJson(Map<String, dynamic> json) {
    return HTTPGetAction(
      path: json['path'],
      port: json['port'],
      host: json['host'],
      scheme: json['scheme'],
      httpHeaders:
          json['httpHeaders'] != null
              ? (json['httpHeaders'] as List)
                  .map((e) => HTTPHeader.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (path != null) 'path': path,
      'port': port,
      if (host != null) 'host': host,
      if (scheme != null) 'scheme': scheme,
      if (httpHeaders != null)
        'httpHeaders': httpHeaders!.map((e) => e.toJson()).toList(),
    };
  }
}
