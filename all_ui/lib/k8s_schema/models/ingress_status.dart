
class IngressStatus {final LoadBalancerStatus? loadBalancer; IngressStatus({this.loadBalancer}); factory IngressStatus.fromJson(Map<String, dynamic> json) {return IngressStatus(loadBalancer: json['loadBalancer'] != null ? LoadBalancerStatus.fromJson(json['loadBalancer']) : null);} Map<String, dynamic> toJson() {return {if (loadBalancer != null) 'loadBalancer' : loadBalancer!.toJson()};}}
