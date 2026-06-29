
// lib/features/auth/screens/sign_in_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golok/features/auth/states/auth_provider.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Username'),
              onChanged: (value) => ref.read(authProvider.notifier).updateUsername(value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (value) => ref.read(authProvider.notifier).updatePassword(value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(authProvider.notifier).signIn(
                authState.username ?? '',
                authState.password ?? '',
              ),
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: () => context.go('/forgot-password'),
              child: const Text('Forgot Password?'),
            ),
            TextButton(
              onPressed: () => context.go('/register'),
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
