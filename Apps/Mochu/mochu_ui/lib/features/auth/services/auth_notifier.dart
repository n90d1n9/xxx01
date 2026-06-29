import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_token.dart';

class AuthService extends StateNotifier<AsyncValue<AuthTokens?>> {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final Ref _ref;

  AuthService(this._dio, this._storage, this._ref)
      : super(const AsyncValue.data(null));
}
