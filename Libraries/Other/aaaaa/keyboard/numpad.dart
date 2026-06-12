import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

// State provider for the numpad input
final numpadValueProvider = StateProvider<String>((ref) => '');

class NumpadScreen extends ConsumerWidget {
  const NumpadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numpadValue = ref.watch(numpadValueProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Display area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      numpadValue.isEmpty ? '0' : numpadValue,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF2D3142),
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ),

            // Numpad area
            Expanded(flex: 5, child: NumpadWidget()),
          ],
        ),
      ),
    );
  }
}

class NumpadWidget extends ConsumerWidget {
  const NumpadWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                NumpadButton(digit: '1'),
                NumpadButton(digit: '2'),
                NumpadButton(digit: '3'),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                NumpadButton(digit: '4'),
                NumpadButton(digit: '5'),
                NumpadButton(digit: '6'),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                NumpadButton(digit: '7'),
                NumpadButton(digit: '8'),
                NumpadButton(digit: '9'),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                NumpadButton(digit: '.'),
                NumpadButton(digit: '0'),
                NumpadActionButton(
                  icon: Icons.backspace_outlined,
                  onTap: () {
                    final currentValue = ref.read(numpadValueProvider);
                    if (currentValue.isNotEmpty) {
                      ref.read(numpadValueProvider.notifier).state =
                          currentValue.substring(0, currentValue.length - 1);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                // Handle submission
                final value = ref.read(numpadValueProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Value submitted: $value')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F58BA),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NumpadButton extends ConsumerWidget {
  final String digit;

  const NumpadButton({Key? key, required this.digit}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          final currentValue = ref.read(numpadValueProvider);

          // Handle decimal point logic
          if (digit == '.' && currentValue.contains('.')) {
            return;
          }

          ref.read(numpadValueProvider.notifier).state = currentValue + digit;
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              digit,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3142),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NumpadActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const NumpadActionButton({Key? key, required this.icon, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F5FC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(icon, size: 24, color: const Color(0xFF4F58BA)),
          ),
        ),
      ),
    );
  }
}

// Usage example
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Modern Numpad',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
        home: const NumpadScreen(),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
