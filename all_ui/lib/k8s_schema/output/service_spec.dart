import 'service_port.dart';
import 'session_affinity_config.dart';

class ServiceSpec {
  final List<ServicePort>? ports;
  final Map<String, String>? selector;
  final String? clusterIP;
  final List<String>? clusterIPs;
  final String? type;
  final List<String>? externalIPs;
  final String? sessionAffinity;
  final String? loadBalancerIP;
  final List<String>? loadBalancerSourceRanges;
  final String? externalName;
  final String? externalTrafficPolicy;
  final int? healthCheckNodePort;
  final bool? publishNotReadyAddresses;
  final SessionAffinityConfig? sessionAffinityConfig;
  final String? ipFamilyPolicy;
  final List<String>? ipFamilies;
  final String? internalTrafficPolicy;
  ServiceSpec({
    this.ports,
    this.selector,
    this.clusterIP,
    this.clusterIPs,
    this.type,
    this.externalIPs,
    this.sessionAffinity,
    this.loadBalancerIP,
    this.loadBalancerSourceRanges,
    this.externalName,
    this.externalTrafficPolicy,
    this.healthCheckNodePort,
    this.publishNotReadyAddresses,
    this.sessionAffinityConfig,
    this.ipFamilyPolicy,
    this.ipFamilies,
    this.internalTrafficPolicy,
  });
  factory ServiceSpec.fromJson(Map<String, dynamic> json) {
    return ServiceSpec(
      ports:
          json['ports'] != null
              ? (json['ports'] as List)
                  .map((e) => ServicePort.fromJson(e))
                  .toList()
              : null,
      selector:
          json['selector'] != null
              ? Map<String, String>.from(json['selector'])
              : null,
      clusterIP: json['clusterIP'],
      clusterIPs:
          json['clusterIPs'] != null
              ? List<String>.from(json['clusterIPs'])
              : null,
      type: json['type'],
      externalIPs:
          json['externalIPs'] != null
              ? List<String>.from(json['externalIPs'])
              : null,
      sessionAffinity: json['sessionAffinity'],
      loadBalancerIP: json['loadBalancerIP'],
      loadBalancerSourceRanges:
          json['loadBalancerSourceRanges'] != null
              ? List<String>.from(json['loadBalancerSourceRanges'])
              : null,
      externalName: json['externalName'],
      externalTrafficPolicy: json['externalTrafficPolicy'],
      healthCheckNodePort: json['healthCheckNodePort'],
      publishNotReadyAddresses: json['publishNotReadyAddresses'],
      sessionAffinityConfig:
          json['sessionAffinityConfig'] != null
              ? SessionAffinityConfig.fromJson(json['sessionAffinityConfig'])
              : null,
      ipFamilyPolicy: json['ipFamilyPolicy'],
      ipFamilies:
          json['ipFamilies'] != null
              ? List<String>.from(json['ipFamilies'])
              : null,
      internalTrafficPolicy: json['internalTrafficPolicy'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (ports != null) 'ports': ports!.map((e) => e.toJson()).toList(),
      if (selector != null) 'selector': selector,
      if (clusterIP != null) 'clusterIP': clusterIP,
      if (clusterIPs != null) 'clusterIPs': clusterIPs,
      if (type != null) 'type': type,
      if (externalIPs != null) 'externalIPs': externalIPs,
      if (sessionAffinity != null) 'sessionAffinity': sessionAffinity,
      if (loadBalancerIP != null) 'loadBalancerIP': loadBalancerIP,
      if (loadBalancerSourceRanges != null)
        'loadBalancerSourceRanges': loadBalancerSourceRanges,
      if (externalName != null) 'externalName': externalName,
      if (externalTrafficPolicy != null)
        'externalTrafficPolicy': externalTrafficPolicy,
      if (healthCheckNodePort != null)
        'healthCheckNodePort': healthCheckNodePort,
      if (publishNotReadyAddresses != null)
        'publishNotReadyAddresses': publishNotReadyAddresses,
      if (sessionAffinityConfig != null)
        'sessionAffinityConfig': sessionAffinityConfig!.toJson(),
      if (ipFamilyPolicy != null) 'ipFamilyPolicy': ipFamilyPolicy,
      if (ipFamilies != null) 'ipFamilies': ipFamilies,
      if (internalTrafficPolicy != null)
        'internalTrafficPolicy': internalTrafficPolicy,
    };
  }
}
