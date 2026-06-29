import 'service_reference.dart';

class APIServiceSpec {
  final ServiceReference? service;
  final String group;
  final String version;
  final bool? insecureSkipTLSVerify;
  final String? caBundle;
  final int groupPriorityMinimum;
  final int versionPriority;
  APIServiceSpec({
    this.service,
    required this.group,
    required this.version,
    this.insecureSkipTLSVerify,
    this.caBundle,
    required this.groupPriorityMinimum,
    required this.versionPriority,
  });
  factory APIServiceSpec.fromJson(Map<String, dynamic> json) {
    return APIServiceSpec(
      service:
          json['service'] != null
              ? ServiceReference.fromJson(json['service'])
              : null,
      group: json['group'],
      version: json['version'],
      insecureSkipTLSVerify: json['insecureSkipTLSVerify'],
      caBundle: json['caBundle'],
      groupPriorityMinimum: json['groupPriorityMinimum'],
      versionPriority: json['versionPriority'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (service != null) 'service': service!.toJson(),
      'group': group,
      'version': version,
      if (insecureSkipTLSVerify != null)
        'insecureSkipTLSVerify': insecureSkipTLSVerify,
      if (caBundle != null) 'caBundle': caBundle,
      'groupPriorityMinimum': groupPriorityMinimum,
      'versionPriority': versionPriority,
    };
  }
}
