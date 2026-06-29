import 'host_port_range.dart';
import 'selinux_strategy_options.dart';
import 'run_as_user_strategy_options.dart';
import 'run_as_group_strategy_options.dart';
import 'supplemental_groups_strategy_options.dart';
import 'fsgroup_strategy_options.dart';
import 'allowed_host_path.dart';

class PodSecurityPolicySpec {
  final bool? privileged;
  final List<String>? defaultAddCapabilities;
  final List<String>? requiredDropCapabilities;
  final List<String>? allowedCapabilities;
  final List<HostPortRange>? hostPorts;
  final bool? hostNetwork;
  final bool? hostPID;
  final bool? hostIPC;
  final SELinuxStrategyOptions? seLinux;
  final RunAsUserStrategyOptions? runAsUser;
  final RunAsGroupStrategyOptions? runAsGroup;
  final SupplementalGroupsStrategyOptions? supplementalGroups;
  final FSGroupStrategyOptions? fsGroup;
  final bool? readOnlyRootFilesystem;
  final List<String>? volumes;
  final List<AllowedHostPath>? allowedHostPaths;
  final bool? allowPrivilegeEscalation;
  final bool? defaultAllowPrivilegeEscalation;
  PodSecurityPolicySpec({
    this.privileged,
    this.defaultAddCapabilities,
    this.requiredDropCapabilities,
    this.allowedCapabilities,
    this.hostPorts,
    this.hostNetwork,
    this.hostPID,
    this.hostIPC,
    this.seLinux,
    this.runAsUser,
    this.runAsGroup,
    this.supplementalGroups,
    this.fsGroup,
    this.readOnlyRootFilesystem,
    this.volumes,
    this.allowedHostPaths,
    this.allowPrivilegeEscalation,
    this.defaultAllowPrivilegeEscalation,
  });
  factory PodSecurityPolicySpec.fromJson(Map<String, dynamic> json) {
    return PodSecurityPolicySpec(
      privileged: json['privileged'],
      defaultAddCapabilities:
          json['defaultAddCapabilities'] != null
              ? List<String>.from(json['defaultAddCapabilities'])
              : null,
      requiredDropCapabilities:
          json['requiredDropCapabilities'] != null
              ? List<String>.from(json['requiredDropCapabilities'])
              : null,
      allowedCapabilities:
          json['allowedCapabilities'] != null
              ? List<String>.from(json['allowedCapabilities'])
              : null,
      hostPorts:
          json['hostPorts'] != null
              ? (json['hostPorts'] as List)
                  .map((e) => HostPortRange.fromJson(e))
                  .toList()
              : null,
      hostNetwork: json['hostNetwork'],
      hostPID: json['hostPID'],
      hostIPC: json['hostIPC'],
      seLinux:
          json['seLinux'] != null
              ? SELinuxStrategyOptions.fromJson(json['seLinux'])
              : null,
      runAsUser:
          json['runAsUser'] != null
              ? RunAsUserStrategyOptions.fromJson(json['runAsUser'])
              : null,
      runAsGroup:
          json['runAsGroup'] != null
              ? RunAsGroupStrategyOptions.fromJson(json['runAsGroup'])
              : null,
      supplementalGroups:
          json['supplementalGroups'] != null
              ? SupplementalGroupsStrategyOptions.fromJson(
                json['supplementalGroups'],
              )
              : null,
      fsGroup:
          json['fsGroup'] != null
              ? FSGroupStrategyOptions.fromJson(json['fsGroup'])
              : null,
      readOnlyRootFilesystem: json['readOnlyRootFilesystem'],
      volumes:
          json['volumes'] != null ? List<String>.from(json['volumes']) : null,
      allowedHostPaths:
          json['allowedHostPaths'] != null
              ? (json['allowedHostPaths'] as List)
                  .map((e) => AllowedHostPath.fromJson(e))
                  .toList()
              : null,
      allowPrivilegeEscalation: json['allowPrivilegeEscalation'],
      defaultAllowPrivilegeEscalation: json['defaultAllowPrivilegeEscalation'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (privileged != null) 'privileged': privileged,
      if (defaultAddCapabilities != null)
        'defaultAddCapabilities': defaultAddCapabilities,
      if (requiredDropCapabilities != null)
        'requiredDropCapabilities': requiredDropCapabilities,
      if (allowedCapabilities != null)
        'allowedCapabilities': allowedCapabilities,
      if (hostPorts != null)
        'hostPorts': hostPorts!.map((e) => e.toJson()).toList(),
      if (hostNetwork != null) 'hostNetwork': hostNetwork,
      if (hostPID != null) 'hostPID': hostPID,
      if (hostIPC != null) 'hostIPC': hostIPC,
      if (seLinux != null) 'seLinux': seLinux!.toJson(),
      if (runAsUser != null) 'runAsUser': runAsUser!.toJson(),
      if (runAsGroup != null) 'runAsGroup': runAsGroup!.toJson(),
      if (supplementalGroups != null)
        'supplementalGroups': supplementalGroups!.toJson(),
      if (fsGroup != null) 'fsGroup': fsGroup!.toJson(),
      if (readOnlyRootFilesystem != null)
        'readOnlyRootFilesystem': readOnlyRootFilesystem,
      if (volumes != null) 'volumes': volumes,
      if (allowedHostPaths != null)
        'allowedHostPaths': allowedHostPaths!.map((e) => e.toJson()).toList(),
      if (allowPrivilegeEscalation != null)
        'allowPrivilegeEscalation': allowPrivilegeEscalation,
      if (defaultAllowPrivilegeEscalation != null)
        'defaultAllowPrivilegeEscalation': defaultAllowPrivilegeEscalation,
    };
  }
}
