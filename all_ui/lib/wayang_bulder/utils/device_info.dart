import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

import '../app/models/device_info.dart';

Future<DeviceInfo?> getDeviceInfo() async {
  final deviceInfo = DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return DeviceInfo(
        platform: PlatformInfo.android,
        brand: androidInfo.brand,
        device: androidInfo.device,
        version: androidInfo.version.release,
        fingerprint: androidInfo.fingerprint,
        systemVersion: androidInfo.version.release,
      );
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;

      return DeviceInfo(
        platform: PlatformInfo.ios,
        brand: 'Apple',
        device: iosInfo.name,
        version: iosInfo.systemVersion,
        fingerprint: iosInfo.identifierForVendor ?? '',
        systemVersion: iosInfo.systemVersion,
      );
    }
  } catch (e) {
    debugPrint('❌ Error getting device info: $e');
  }
  return null;
}
