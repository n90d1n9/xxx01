import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/auth/user.dart';
import '../../repository/user_repository.dart';

class UserViewModel extends StateNotifier<AsyncValue<User>> {
  final UserRepository _repository;

  UserViewModel(this._repository) : super(const AsyncValue.loading());

  Future<void> fetchUserDetails(int userId) async {
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

final userViewModelProvider =
    StateNotifierProvider<UserViewModel, AsyncValue<User>>((ref) {
      final repository = ref.watch(userRepositoryProvider);
      return UserViewModel(repository);
    });
