import 'layout_config.dart';
import 'localdb_config.dart';
import 'network_config.dart';
import 'security_config.dart';

class AppConfig {
  final String appName;
  final NetworkConfig networkConfig;
  final SecurityConfig securityConfig;
  final LocalDBConfig localDBConfig;
  final LayoutConfig layoutConfig;
  final String gApiKey;
  final List<String> contentTypes;
  final String contentType;

  const AppConfig({
    this.appName = 'My apps',
    this.networkConfig = const NetworkConfig(),
    this.securityConfig = const SecurityConfig(),
    this.localDBConfig = const LocalDBConfig(),
    this.layoutConfig = const LayoutConfig(),
    this.contentTypes = const [
      "application/json",
      "application/xml",
      "application/x-www-form-urlencoded",
    ],
    this.contentType = "application/json",
    this.gApiKey = '',
  });

  // Getter for the current host based on the build mode.
  String get host {
    return networkConfig.isDev ? networkConfig.hostDev : networkConfig.hostProd;
  }

  // Getter for the base URL.
  String get baseUrl {
    return '$hostSchema://$host';
  }

  String get hostSchema {
    return networkConfig.isDev
        ? networkConfig.hostDevSchema
        : networkConfig.hostProdSchema;
  }

  AppConfig copyWith({
    String? appName,
    NetworkConfig? networkConfig,
    SecurityConfig? securityConfig,
    LayoutConfig? layoutConfig,
    List<String>? contentTypes,
    String? gApiKey,
  }) {
    return AppConfig(
      appName: appName ?? this.appName,
      networkConfig: networkConfig ?? this.networkConfig,
      securityConfig: securityConfig ?? this.securityConfig,
      layoutConfig: layoutConfig ?? this.layoutConfig,
      contentTypes: contentTypes ?? this.contentTypes,
      gApiKey: gApiKey ?? this.gApiKey,
    );
  }

  @override
  String toString() {
    return '''
appName: $appName \n
networkConfig: $networkConfig \n
securityConfig: $securityConfig \n
layoutConfig: $layoutConfig \n
contentTypes: $contentTypes \n
gApiKey: $gApiKey \n
  }''';
  }
}
