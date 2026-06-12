/* 

if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    debugPrint('🟢 Brand: ${androidInfo.brand}');
    debugPrint('🟢 Device: ${androidInfo.device}');
    debugPrint('🟢 Version: ${androidInfo.version.release}');
    debugPrint('🟢 Fingerprint: ${androidInfo.fingerprint}');
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    debugPrint('🟢 iOS Version: ${iosInfo.systemVersion}');
  }
 */
enum PlatformInfo {
  android,
  ios,
}

class DeviceInfo {
  final PlatformInfo platform;
  final String brand;
  final String device;
  final String version;
  final String fingerprint;
  final String systemVersion;

  DeviceInfo({
    required this.platform,
    required this.brand,
    this.device = '',
    this.version = '',
    this.fingerprint = '',
    required this.systemVersion,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      platform:
          PlatformInfo.values.firstWhere((e) => e.name == json['platform']),
      brand: json['brand'],
      device: json['device'],
      version: json['version'],
      fingerprint: json['fingerprint'],
      systemVersion: json['systemVersion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform.name,
      'brand': brand,
      'device': device,
      'version': version,
      'fingerprint': fingerprint,
      'systemVersion': systemVersion,
    };
  }

  @override
  String toString() {
    return 'DeviceInfo(platform: $platform, brand: $brand, device: $device, version: $version, fingerprint: $fingerprint, systemVersion: $systemVersion)';
  }
}
