import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/auth/user_provider.dart';

class UserDetailsScreen extends ConsumerStatefulWidget {
  final int userId;

  const UserDetailsScreen({super.key, required this.userId});

  @override
  UserDetailsScreenState createState() => UserDetailsScreenState();
}

class UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
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
        data:
            (user) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Name: ${user.firstName}'),
                  Text('Email: ${user.email}'),
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
