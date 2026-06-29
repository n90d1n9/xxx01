import 'load_balancer_ingress.dart';

class LoadBalancerStatus {
  final List<LoadBalancerIngress>? ingress;
  LoadBalancerStatus({this.ingress});
  factory LoadBalancerStatus.fromJson(Map<String, dynamic> json) {
    return LoadBalancerStatus(
      ingress:
          json['ingress'] != null
              ? (json['ingress'] as List)
                  .map((e) => LoadBalancerIngress.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (ingress != null) 'ingress': ingress!.map((e) => e.toJson()).toList(),
    };
  }
}
