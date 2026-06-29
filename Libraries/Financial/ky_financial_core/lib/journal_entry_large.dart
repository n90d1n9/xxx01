// Add these imports at the top of your file if not already present
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:queue_ui/accounting/journal_entry.dart';

// Add this layout constant class
class LayoutConstants {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint &&
        MediaQuery.of(context).size.width < desktopBreakpoint;
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }
}

// Replace the JournalEntryScreen build method with this optimized version

// Add these helper methods to the JournalEntryScreen class

// Enhance the JournalLineItem for better large screen display
class EnhancedJournalLineItem extends ConsumerWidget {
  final JournalLine line;
  final int index;

  const EnhancedJournalLineItem({
    Key? key,
    required this.line,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLargeScreen = LayoutConstants.isLargeScreen(context);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 12.0 : 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Line number indicator for large screens
            if (isLargeScreen)
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isLargeScreen) const SizedBox(width: 8),

            // Rest of the content remains the same
            Expanded(
              flex: 5,
              child: AccountSelector(
                lineId: line.id,
                currentAccount: line.account,
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextFormField(
                  initialValue: line.description,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    ref
                        .read(currentJournalEntryProvider.notifier)
                        .updateLine(line.id, description: value);
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextFormField(
                  initialValue: line.debit > 0 ? line.debit.toString() : '',
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.right,
                  onChanged: (value) {
                    final amount = double.tryParse(value) ?? 0.0;
                    ref
                        .read(currentJournalEntryProvider.notifier)
                        .updateLine(
                          line.id,
                          debit: amount,
                          // If debit is entered, clear credit
                          credit: amount > 0 ? 0.0 : line.credit,
                        );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextFormField(
                  initialValue: line.credit > 0 ? line.credit.toString() : '',
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.right,
                  onChanged: (value) {
                    final amount = double.tryParse(value) ?? 0.0;
                    ref
                        .read(currentJournalEntryProvider.notifier)
                        .updateLine(
                          line.id,
                          credit: amount,
                          // If credit is entered, clear debit
                          debit: amount > 0 ? 0.0 : line.debit,
                        );
                  },
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  ref
                      .read(currentJournalEntryProvider.notifier)
                      .removeLine(line.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced header with better styling for large screens
class EnhancedJournalLinesHeader extends StatelessWidget {
  const EnhancedJournalLinesHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = LayoutConstants.isLargeScreen(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 16.0 : 12.0),
        child: Row(
          children: [
            // Line number column for large screens
            if (isLargeScreen) const SizedBox(width: 40),

            Expanded(
              flex: 5,
              child: Text(
                'Account',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isLargeScreen ? 16.0 : 14.0,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isLargeScreen ? 16.0 : 14.0,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Debit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isLargeScreen ? 16.0 : 14.0,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Credit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isLargeScreen ? 16.0 : 14.0,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 48), // Space for the action button
          ],
        ),
      ),
    );
  }
}

// Enhanced MyApp with window sizing capabilities for desktop mode
class EnhancedMyApp extends StatelessWidget {
  const EnhancedMyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set minimum window size if running on desktop
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      // Note: This would require the 'window_size' package
      // which is not included in this snippet
    }

    return MaterialApp(
      title: 'Accounting Journal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        // Enhanced typography for large screens
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        // Enhanced typography for large screens
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const JournalEntryScreen(),
    );
  }
}
