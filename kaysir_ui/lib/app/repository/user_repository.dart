import '../models/auth/user.dart';

class UserRepository {
  Future<User> fetchUser(int userId) async {
    // Simulated network call
    await Future.delayed(const Duration(seconds: 1));
    return User(
      id: userId,
      firstName: 'John Doe',
      email: 'john.doe@example.com',
    );
  }
}
