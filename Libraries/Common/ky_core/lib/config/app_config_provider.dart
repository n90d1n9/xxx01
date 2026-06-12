// lib/providers/config_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../local_database/local_storage_service.dart';
import 'app_config.dart';
import 'layout_config.dart';
import 'localdb_config.dart';
import 'network_config.dart';
import 'security_config.dart';

// The provider that exposes the AppConfigNotifier.
final appConfigProvider = NotifierProvider<AppConfigNotifier, AppConfig>(
  AppConfigNotifier.new,
);

class AppConfigNotifier extends Notifier<AppConfig> {
  static const String _firstRunKey = 'is_first_run';
  static const String _configKey = 'app_config';
  static const String _finishedGuideKey = 'finishedGuideKey';

  @override
  AppConfig build() {
    return const AppConfig();
  }

  Future<void> initialize() async {
    try {
      // Check if it's first run using your LocalDBService
      final isFirstRun =
          await LocalDBService.getPreference(key: _firstRunKey) ?? true;
      // Preserve a read to warm the cache even if not used directly yet.
      await LocalDBService.getPreference(key: _finishedGuideKey);

      if (isFirstRun) {
        // Set default values for first run
        state = state.copyWith();
      } else {
        // Load saved configuration from your LocalDBService
        final savedConfig = await LocalDBService.getPreference(key: _configKey);
        if (savedConfig != null && savedConfig is Map) {
          final config = _configFromMap(Map<String, dynamic>.from(savedConfig));
          state = config;
        }
      }
    } catch (e) {
      debugPrint('Error initializing app config: $e');
      // Fallback to default config
      state = const AppConfig();
    }
  }

  Future<void> completeFirstRun() async {
    await LocalDBService.savePreference(key: _firstRunKey, value: false);
    await _saveConfig();
  }

  Future<void> markGuideAsFinished() async {
    await LocalDBService.savePreference(key: _finishedGuideKey, value: true);
  }

  void setupHosts({
    String? hostDev,
    String? hostProd,
    String? hostDevSchema,
    String? hostProdSchema,
    String? appName,
    bool? isDev,
  }) {
    state = state.copyWith(
      appName: appName ?? state.appName,
      networkConfig: state.networkConfig.copyWith(
        hostDev: hostDev ?? state.networkConfig.hostDev,
        hostProd: hostProd ?? state.networkConfig.hostProd,
        hostDevSchema: hostDevSchema ?? state.networkConfig.hostDevSchema,
        hostProdSchema: hostProdSchema ?? state.networkConfig.hostProdSchema,
        isDev: isDev ?? state.networkConfig.isDev,
      ),
    );
    debugPrint(
      '🔧 Config Updated: isDev=${state.networkConfig.isDev}, baseUrl=${state.baseUrl}',
    );
    _saveConfig();
  }

  void updateHost(String newHost) {
    if (kDebugMode) {
      state = state.copyWith(
        networkConfig: state.networkConfig.copyWith(hostDev: newHost),
      );
    } else {
      state = state.copyWith(
        networkConfig: state.networkConfig.copyWith(hostProd: newHost),
      );
    }
    _saveConfig();
  }

  void updateHostSchema(String newSchema) {
    if (kDebugMode) {
      state = state.copyWith(
        networkConfig: state.networkConfig.copyWith(hostDevSchema: newSchema),
      );
    } else {
      state = state.copyWith(
        networkConfig: state.networkConfig.copyWith(hostProdSchema: newSchema),
      );
    }
    _saveConfig();
  }

  void updateConfig(AppConfig newConfig) {
    state = newConfig;
    _saveConfig();
  }

  Future<void> _saveConfig() async {
    try {
      await LocalDBService.savePreference(
        key: _configKey,
        value: _configToMap(state),
      );
    } catch (e) {
      debugPrint('Error saving app config: $e');
    }
  }

  Map<String, dynamic> _configToMap(AppConfig config) {
    return {
      'appName': config.appName,
      'hostDev': config.networkConfig.hostDev,
      'hostProd': config.networkConfig.hostProd,
      'hostDevSchema': config.networkConfig.hostDevSchema,
      'hostProdSchema': config.networkConfig.hostProdSchema,
      'webSocketUrlDev': config.networkConfig.webSocketUrlDev,
      'webSocketUrlProd': config.networkConfig.webSocketUrlProd,
      'timeoutReceive': config.networkConfig.timeoutReceive,
      'timeoutConnection': config.networkConfig.timeoutConnection,
      'isDev': config.networkConfig.isDev,
      'maxRetries': config.networkConfig.maxRetries,
      'retryBaseDelayMs': config.networkConfig.retryBaseDelayMs,
      'retryMaxDelayMs': config.networkConfig.retryMaxDelayMs,
      'retryJitterPct': config.networkConfig.retryJitterPct,
      'failFastOffline': config.networkConfig.failFastOffline,
      'circuitBreakerEnabled': config.networkConfig.circuitBreakerEnabled,
      'circuitBreakerFailureThreshold':
          config.networkConfig.circuitBreakerFailureThreshold,
      'circuitBreakerSuccessThreshold':
          config.networkConfig.circuitBreakerSuccessThreshold,
      'circuitBreakerCooldownMs': config.networkConfig.circuitBreakerCooldownMs,
      'requestDeduplicationEnabled':
          config.networkConfig.requestDeduplicationEnabled,
      'tokenKey': config.securityConfig.tokenKey,
      'tokenKeyContent': config.securityConfig.tokenKeyContent,
      'refreshTokenKey': config.securityConfig.refreshTokenKey,
      'isFirstTimeKey': config.securityConfig.isFirstTimeKey,
      'finishedGuideKey': config.securityConfig.finishedGuideKey,
      'storeName': config.localDBConfig.storeName,
      'dbName': config.localDBConfig.dbName,
      'fieldId': config.layoutConfig.fieldId,
      'defaultPadding': config.layoutConfig.defaultPadding,
      'sideMenuWidth': config.layoutConfig.sideMenuWidth,
      'iconApp': config.layoutConfig.iconApp,
      'imageLogin': config.layoutConfig.imageLogin,
      'imageIcon': config.layoutConfig.imageIcon,
      'fontSize': config.layoutConfig.fontSize,
      'contentTypes': config.contentTypes,
      'contentType': config.contentType,
      'gApiKey': config.gApiKey,
    };
  }

  AppConfig _configFromMap(Map<String, dynamic> map) {
    return AppConfig(
      appName: map['appName'] ?? 'My apps',
      networkConfig: NetworkConfig(
        hostDev: map['hostDev'] ?? 'dev.api.mydomain.com',
        hostProd: map['hostProd'] ?? 'api.mydomain.com',
        hostDevSchema: map['hostDevSchema'] ?? 'http',
        hostProdSchema: map['hostProdSchema'] ?? 'https',
        isDev: map['isDev'] ?? true,
        webSocketUrlDev: map['webSocketUrlDev'] ?? 'ws://dev.api.mydomain.com',
        webSocketUrlProd: map['webSocketUrlProd'] ?? 'wss://api.mydomain.com',
        timeoutReceive: map['timeoutReceive'] ?? 12000,
        timeoutConnection: map['timeoutConnection'] ?? 5000,
        maxRetries: map['maxRetries'] ?? 0,
        retryBaseDelayMs: map['retryBaseDelayMs'] ?? 250,
        retryMaxDelayMs: map['retryMaxDelayMs'] ?? 2000,
        retryJitterPct: (map['retryJitterPct'] as num?)?.toDouble() ?? 0.2,
        failFastOffline: map['failFastOffline'] ?? false,
        circuitBreakerEnabled: map['circuitBreakerEnabled'] ?? false,
        circuitBreakerFailureThreshold:
            map['circuitBreakerFailureThreshold'] ?? 5,
        circuitBreakerSuccessThreshold:
            map['circuitBreakerSuccessThreshold'] ?? 2,
        circuitBreakerCooldownMs: map['circuitBreakerCooldownMs'] ?? 15000,
        requestDeduplicationEnabled:
            map['requestDeduplicationEnabled'] ?? false,
      ),
      localDBConfig: LocalDBConfig(
        storeName: map['storeName'] ?? 'mystore',
        dbName: map['dbName'] ?? 'my.db',
      ),
      securityConfig: SecurityConfig(
        tokenKey: map['tokenKey'] ?? 'accessToken',
        tokenKeyContent: map['tokenKeyContent'] ?? 'auth_token_content',
        refreshTokenKey: map['refreshTokenKey'] ?? 'refresh_token',
        isFirstTimeKey: map['isFirstTimeKey'] ?? 'isFirstTime',
        finishedGuideKey: map['finishedGuideKey'] ?? 'finishedGuideKey',
      ),
      layoutConfig: LayoutConfig(
        fieldId: map['fieldId'] ?? 'id',
        defaultPadding: map['defaultPadding'] ?? 16.0,
        sideMenuWidth: map['sideMenuWidth'] ?? 230.0,
        iconApp: map['iconApp'] ?? 'assets/icons/ic_appicon.png',
        imageLogin: map['imageLogin'] ?? 'assets/icons/one-rec-b@2x.png',
        imageIcon: map['imageIcon'] ?? 'assets/icons/one-rec-b@2x.png',
        fontSize: map['fontSize'] ?? 10.0,
      ),
      contentTypes: List<String>.from(
        map['contentTypes'] ??
            [
              "application/json",
              "application/xml",
              "application/x-www-form-urlencoded",
            ],
      ),
      contentType: map['contentType'] ?? "application/json",

      gApiKey: map['gApiKey'] ?? '',
    );
  }

  // Helper method to check if it's first run
  Future<bool> isFirstRun() async {
    return await LocalDBService.getPreference(key: _firstRunKey) ?? true;
  }
}
