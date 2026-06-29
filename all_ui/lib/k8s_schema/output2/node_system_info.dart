class NodeSystemInfo {
  final String machineID;
  final String systemUUID;
  final String bootID;
  final String kernelVersion;
  final String osImage;
  final String containerRuntimeVersion;
  final String kubeletVersion;
  final String kubeProxyVersion;
  final String operatingSystem;
  final String architecture;
  NodeSystemInfo({
    required this.machineID,
    required this.systemUUID,
    required this.bootID,
    required this.kernelVersion,
    required this.osImage,
    required this.containerRuntimeVersion,
    required this.kubeletVersion,
    required this.kubeProxyVersion,
    required this.operatingSystem,
    required this.architecture,
  });
  factory NodeSystemInfo.fromJson(Map<String, dynamic> json) {
    return NodeSystemInfo(
      machineID: json['machineID'],
      systemUUID: json['systemUUID'],
      bootID: json['bootID'],
      kernelVersion: json['kernelVersion'],
      osImage: json['osImage'],
      containerRuntimeVersion: json['containerRuntimeVersion'],
      kubeletVersion: json['kubeletVersion'],
      kubeProxyVersion: json['kubeProxyVersion'],
      operatingSystem: json['operatingSystem'],
      architecture: json['architecture'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'machineID': machineID,
      'systemUUID': systemUUID,
      'bootID': bootID,
      'kernelVersion': kernelVersion,
      'osImage': osImage,
      'containerRuntimeVersion': containerRuntimeVersion,
      'kubeletVersion': kubeletVersion,
      'kubeProxyVersion': kubeProxyVersion,
      'operatingSystem': operatingSystem,
      'architecture': architecture,
    };
  }
}
