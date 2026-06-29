// pubspec.yaml dependencies (placeholder, ensure to add in actual project)
// dependencies:
//   flutter:
//     sdk: flutter
//   flutter_riverpod: ^latest_version
//   go_router: ^latest_version

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Models
class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}

// Repository (Data Layer)
class UserRepository {
  Future<User> fetchUser(String userId) async {
    // Simulated network call
    await Future.delayed(const Duration(seconds: 1));
    return User(
      id: userId, 
      name: 'John Doe', 
      email: 'john.doe@example.com'
    );
  }
}

// View Model (Business Logic Layer)
class UserViewModel extends StateNotifier<AsyncValue<User>> {
  final UserRepository _repository;

  UserViewModel(this._repository) : super(const AsyncValue.loading());

  Future<void> fetchUserDetails(String userId) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.fetchUser(userId);
      state = AsyncValue.data(user);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}

// Providers
final userRepositoryProvider = Provider((ref) => UserRepository());

final userViewModelProvider = StateNotifierProvider<UserViewModel, AsyncValue<User>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserViewModel(repository);
});

// Router Configuration
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/user/:userId',
      builder: (context, state) {
        final userId = state.params['userId']!;
        return UserDetailsScreen(userId: userId);
      },
    ),
  ],
);

// Screens
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/user/123'),
          child: const Text('View User Details'),
        ),
      ),
    );
  }
}

class UserDetailsScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserDetailsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user details when screen initializes
    Future.microtask(() {
      ref.read(userViewModelProvider.notifier).fetchUserDetails(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: userState.when(
        data: (user) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Name: ${user.name}'),
              Text('Email: ${user.email}'),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

// Main App
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'MVVM Template',
        routerConfig: _router,
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
