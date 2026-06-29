import 'port_status.dart';

class LoadBalancerIngress {
  final String? ip;
  final String? hostname;
  final List<PortStatus>? ports;
  LoadBalancerIngress({this.ip, this.hostname, this.ports});
  factory LoadBalancerIngress.fromJson(Map<String, dynamic> json) {
    return LoadBalancerIngress(
      ip: json['ip'],
      hostname: json['hostname'],
      ports:
          json['ports'] != null
              ? (json['ports'] as List)
                  .map((e) => PortStatus.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (ip != null) 'ip': ip,
      if (hostname != null) 'hostname': hostname,
      if (ports != null) 'ports': ports!.map((e) => e.toJson()).toList(),
    };
  }
}
