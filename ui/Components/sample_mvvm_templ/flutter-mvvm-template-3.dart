// pubspec.yaml additional dependencies
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
  build_runner: ^2.4.6
  mocktail: ^1.0.0
  fake_cloud_firestore: ^2.4.0
  bloc_test: ^9.1.4

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  go_router: ^12.1.3
  dio: ^5.4.0
  logger: ^2.1.0

// core/logging/app_logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message) {
    _logger.i(message);
  }

  static void warning(String message, {Object? error}) {
    _logger.w(message, error: error);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

// core/error/error_handler.dart
class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout. Please check your internet.';
        case DioExceptionType.receiveTimeout:
          return 'Receive timeout. Server might be busy.';
        case DioExceptionType.badResponse:
          return _handleBadResponse(error);
        default:
          return 'An unexpected network error occurred.';
      }
    }
    
    return error?.toString() ?? 'An unknown error occurred';
  }

  static String _handleBadResponse(DioException error) {
    switch (error.response?.statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized access.';
      case 403:
        return 'Forbidden access.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Internal server error.';
      default:
        return 'Server returned an error.';
    }
  }
}

// tests/unit/user_view_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('UserViewModel', () {
    late ProviderContainer container;
    late MockUserRepository mockRepository;

    setUp(() {
      mockRepository = MockUserRepository();
      container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepository)
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is empty', () {
      final viewModel = container.read(userViewModelProvider.notifier);
      expect(viewModel.state, equals(const AsyncValue.data(User.empty())));
    });

    test('Fetch user success', () async {
      final user = User(id: '123', name: 'Test User');
      
      when(mockRepository.fetchUser('123')).thenAnswer(
        (_) async => Right(user)
      );

      final viewModel = container.read(userViewModelProvider.notifier);
      await viewModel.fetchUser('123');

      expect(
        viewModel.state, 
        AsyncValue.data(user)
      );
    });

    test('Fetch user failure', () async {
      final failure = NetworkFailure('Network error');
      
      when(mockRepository.fetchUser('123')).thenAnswer(
        (_) async => Left(failure)
      );

      final viewModel = container.read(userViewModelProvider.notifier);
      await viewModel.fetchUser('123');

      expect(
        viewModel.state, 
        AsyncValue.error(failure, StackTrace.current)
      );
    });
  });
}

// tests/integration/user_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User details flow', (WidgetTester tester) async {
    // Setup mock app for integration testing
    await tester.pumpWidget(const MyTestApp());
    
    // Navigate to user details
    await tester.tap(find.byKey(const Key('user_details_button')));
    await tester.pumpAndSettle();

    // Verify user details are displayed
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('john.doe@example.com'), findsOneWidget);
  });
}

// Modify view models and repositories to integrate logging
extension LoggingExtension on UserRepository {
  Future<Either<Failure, User>> fetchUserWithLogging(String userId) async {
    AppLogger.info('Fetching user with ID: $userId');
    try {
      final result = await fetchUser(userId);
      result.fold(
        (failure) => AppLogger.error('User fetch failed', error: failure),
        (user) => AppLogger.debug('User fetched successfully: ${user.name}')
      );
      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in user fetch', 
        error: e, 
        stackTrace: stackTrace
      );
      return Left(NetworkFailure('Unexpected error'));
    }
  }
}
