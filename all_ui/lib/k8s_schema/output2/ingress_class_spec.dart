import 'ingress_class_parameters_reference.dart';

class IngressClassSpec {
  final String? controller;
  final IngressClassParametersReference? parameters;
  IngressClassSpec({this.controller, this.parameters});
  factory IngressClassSpec.fromJson(Map<String, dynamic> json) {
    return IngressClassSpec(
      controller: json['controller'],
      parameters:
          json['parameters'] != null
              ? IngressClassParametersReference.fromJson(json['parameters'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (controller != null) 'controller': controller,
      if (parameters != null) 'parameters': parameters!.toJson(),
    };
  }
}
