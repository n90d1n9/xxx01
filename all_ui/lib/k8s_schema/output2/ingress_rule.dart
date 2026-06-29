import 'httpingress_rule_value.dart';

class IngressRule {
  final String? host;
  final HTTPIngressRuleValue? http;
  IngressRule({this.host, this.http});
  factory IngressRule.fromJson(Map<String, dynamic> json) {
    return IngressRule(
      host: json['host'],
      http:
          json['http'] != null
              ? HTTPIngressRuleValue.fromJson(json['http'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (host != null) 'host': host,
      if (http != null) 'http': http!.toJson(),
    };
  }
}
