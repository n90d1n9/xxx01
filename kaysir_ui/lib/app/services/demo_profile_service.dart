import 'dart:convert';

import 'package:flutter/services.dart';

import '../../config/config.dart';
import '../models/auth/user.dart';

class DemoProfile {
  final String token;
  final String? refreshToken;
  final User user;

  const DemoProfile({
    required this.token,
    required this.user,
    this.refreshToken,
  });
}

class DemoProfileService {
  const DemoProfileService._();

  static Future<DemoProfile> load() async {
    final source = await rootBundle.loadString(demoProfileAsset);
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Demo profile must be a JSON object.');
    }

    final token = decoded['token']?.toString();
    final userPayload = decoded['user'];
    if (token == null || token.isEmpty || userPayload is! Map) {
      throw const FormatException('Demo profile needs token and user fields.');
    }

    return DemoProfile(
      token: token,
      refreshToken:
          decoded['refreshToken']?.toString() ??
          decoded['refresh_token']?.toString(),
      user: User.fromJson(Map<String, dynamic>.from(userPayload)),
    );
  }
}
