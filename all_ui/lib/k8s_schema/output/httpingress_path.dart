import 'ingress_backend.dart';

class HTTPIngressPath {
  final String? path;
  final String pathType;
  final IngressBackend backend;
  HTTPIngressPath({this.path, required this.pathType, required this.backend});
  factory HTTPIngressPath.fromJson(Map<String, dynamic> json) {
    return HTTPIngressPath(
      path: json['path'],
      pathType: json['pathType'],
      backend: IngressBackend.fromJson(json['backend']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (path != null) 'path': path,
      'pathType': pathType,
      'backend': backend.toJson(),
    };
  }
}
