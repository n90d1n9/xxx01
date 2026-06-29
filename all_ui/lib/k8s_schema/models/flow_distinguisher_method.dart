
class FlowDistinguisherMethod {final String type; FlowDistinguisherMethod({required this.type}); factory FlowDistinguisherMethod.fromJson(Map<String, dynamic> json) {return FlowDistinguisherMethod(type: json['type']);} Map<String, dynamic> toJson() {return {'type' : type};}}
