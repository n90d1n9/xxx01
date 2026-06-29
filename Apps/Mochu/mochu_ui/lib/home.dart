// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_provider.dart';
import 'features/sheets/sheet_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Google Sheets Integration')),
      body: Center(
        child: authState.when(
          data: (account) {
            if (account == null) {
              return ElevatedButton(
                onPressed: () => ref.read(authStateProvider.notifier).signIn(),
                child: const Text('Sign in with Google'),
              );
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome, ${account.email}'),
                ElevatedButton(
                  onPressed: () => context.go('/sheets'),
                  child: const Text('Go to Sheets'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(authStateProvider.notifier).signOut(),
                  child: const Text('Sign Out'),
                ),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        ),
      ),
    );
  }
}
/* 
// lib/screens/sheets_screen.dart
class SheetsScreen extends ConsumerWidget {
  const SheetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sheets'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: authState.when(
        data: (account) {
          if (account == null) {
            return const Center(child: Text('Please sign in first'));
          }

          return ref.watch(spreadsheetProvider(account.accessToken!)).when(
                data: (spreadsheet) {
                  if (spreadsheet == null) {
                    return const Center(
                        child: Text('Error creating spreadsheet'));
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            'Spreadsheet created: ${spreadsheet.spreadsheetId}'),
                        ElevatedButton(
                          onPressed: () async {
                            final sheetsService =
                                ref.read(sheetsServiceProvider);
                            await sheetsService.updateValues(
                              account.accessToken!,
                              spreadsheet.spreadsheetId!,
                              'Sheet1!A1:B2',
                              [
                                ['Name', 'Age'],
                                ['John Doe', '30'],
                              ],
                            );
                          },
                          child: const Text('Update Values'),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              );
        },
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }
}
 */
