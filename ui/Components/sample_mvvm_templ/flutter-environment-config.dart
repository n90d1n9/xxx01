// lib/core/config/environment_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { dev, staging, prod }

class EnvironmentConfig {
  static late Environment _currentEnv;
  static late DotEnv _dotEnv;

  static Future<void> initialize(Environment env) async {
    _currentEnv = env;
    await dotenv.load(fileName: _getEnvFileName(env));
    _dotEnv = dotenv;
  }

  static String _getEnvFileName(Environment env) {
    switch (env) {
      case Environment.dev:
        return '.env.development';
      case Environment.staging:
        return '.env.staging';
      case Environment.prod:
        return '.env.production';
    }
  }

  static String get baseUrl => _dotEnv.get('BASE_URL');
  static String get apiKey => _dotEnv.get('API_KEY');
  static bool get enableLogging => _dotEnv.get('ENABLE_LOGGING') == 'true';
}

// lib/core/di/dependency_injection.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

class DependencyInjection {
  static final GetIt _getIt = GetIt.instance;

  static void setup() {
    // Network
    _getIt.registerLazySingleton<Dio>(() => Dio(
      BaseOptions(
        baseUrl: EnvironmentConfig.baseUrl,
        headers: {
          'Authorization': 'Bearer ${EnvironmentConfig.apiKey}',
          'Content-Type': 'application/json',
        },
      ),
    ));

    // Repositories
    _getIt.registerLazySingleton<UserRepository>(
      () => UserRepository(_getIt<Dio>())
    );

    // Services
    _getIt.registerLazySingleton<LoggingService>(
      () => LoggingService()
    );
  }

  static T get<T extends Object>() => _getIt<T>();
}

// .env.development
BASE_URL=https://dev-api.example.com
API_KEY=dev_123456
ENABLE_LOGGING=true

// .env.staging
BASE_URL=https://staging-api.example.com
API_KEY=staging_789012
ENABLE_LOGGING=true

// .env.production
BASE_URL=https://api.example.com
API_KEY=prod_secret_key
ENABLE_LOGGING=false

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment based on build flavor
  await EnvironmentConfig.initialize(
    kDebugMode 
      ? Environment.dev 
      : (kProfileMode ? Environment.staging : Environment.prod)
  );

  // Setup dependency injection
  DependencyInjection.setup();

  runApp(const MyApp());
}
