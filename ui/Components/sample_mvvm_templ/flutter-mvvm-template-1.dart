// pubspec.yaml additional dependencies
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  go_router: ^12.1.3
  dio: ^5.4.0
  shared_preferences: ^2.2.2
  logger: ^2.1.0
  cached_network_image: ^3.3.0

// core/constants/app_constants.dart
class AppConstants {
  static const baseUrl = 'https://api.example.com';
  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 10);
}

// core/network/dio_client.dart
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class DioClient {
  final Dio _dio;

  DioClient() : _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: AppConstants.connectTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
  )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if needed
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }

  Dio get instance => _dio;
}

// core/services/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }
}

// core/error/failure.dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// repositories/user_repository.dart
import '../core/network/dio_client.dart';
import '../core/error/failure.dart';
import 'package:dartz/dartz.dart';

class UserRepository {
  final DioClient _dioClient;

  UserRepository(this._dioClient);

  Future<Either<Failure, User>> fetchUser(String userId) async {
    try {
      final response = await _dioClient.instance.get('/users/$userId');
      return Right(User.fromJson(response.data));
    } catch (e) {
      return Left(NetworkFailure('Failed to fetch user'));
    }
  }
}

// providers/core_providers.dart
final dioClientProvider = Provider((ref) => DioClient());

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

final localStorageServiceProvider = Provider((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

// view_models/user_view_model.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/user_repository.dart';

part 'user_view_model.g.dart';

@riverpod
class UserViewModel extends _$UserViewModel {
  @override
  FutureOr<User> build() => const User.empty();

  Future<void> fetchUser(String userId) async {
    state = const AsyncValue.loading();
    final result = await ref.read(userRepositoryProvider).fetchUser(userId);
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (user) => AsyncValue.data(user)
    );
  }
}

// Additional configuration and setup in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}
