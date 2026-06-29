// Update the SheetsScreen widget:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mochu/features/sheets/sheet_provider.dart';

import '../../auth_provider.dart';

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

          // Create a FutureProvider for the access token
          final accessTokenFuture = ref.watch(FutureProvider((ref) {
            final authService = ref.read(authServiceProvider);
            return authService.getAccessToken(account);
          }));

          return accessTokenFuture.when(
            data: (accessToken) {
              if (accessToken == null) {
                return const Center(child: Text('Failed to get access token'));
              }

              return ref.watch(spreadsheetProvider(accessToken)).when(
                    data: (spreadsheet) {
                      print(spreadsheet);
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
                                final authService =
                                    ref.read(authServiceProvider);
                                final newAccessToken =
                                    await authService.getAccessToken(account);
                                if (newAccessToken != null) {
                                  await sheetsService.updateValues(
                                    newAccessToken,
                                    spreadsheet.spreadsheetId!,
                                    'Sheet1!A1:B2',
                                    [
                                      ['Name', 'Age'],
                                      ['John Doe', '30'],
                                    ],
                                  );
                                }
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
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }
}
