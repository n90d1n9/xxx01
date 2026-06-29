import 'httpingress_path.dart';

class HTTPIngressRuleValue {
  final List<HTTPIngressPath> paths;
  HTTPIngressRuleValue({required this.paths});
  factory HTTPIngressRuleValue.fromJson(Map<String, dynamic> json) {
    return HTTPIngressRuleValue(
      paths:
          (json['paths'] as List)
              .map((e) => HTTPIngressPath.fromJson(e))
              .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {'paths': paths.map((e) => e.toJson()).toList()};
  }
}
