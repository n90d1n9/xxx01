import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Keyboard state provider
final keyboardStateProvider =
    StateNotifierProvider<KeyboardStateNotifier, KeyboardState>((ref) {
      return KeyboardStateNotifier();
    });

// Keyboard state class
class KeyboardState {
  final String text;
  final bool isShifted;
  final bool isNumeric;
  final bool isSymbols;

  KeyboardState({
    this.text = '',
    this.isShifted = false,
    this.isNumeric = false,
    this.isSymbols = false,
  });

  KeyboardState copyWith({
    String? text,
    bool? isShifted,
    bool? isNumeric,
    bool? isSymbols,
  }) {
    return KeyboardState(
      text: text ?? this.text,
      isShifted: isShifted ?? this.isShifted,
      isNumeric: isNumeric ?? this.isNumeric,
      isSymbols: isSymbols ?? this.isSymbols,
    );
  }
}

// Keyboard state notifier
class KeyboardStateNotifier extends StateNotifier<KeyboardState> {
  KeyboardStateNotifier() : super(KeyboardState());

  void addText(String character) {
    state = state.copyWith(text: state.text + character);
    if (state.isShifted) {
      toggleShift();
    }
  }

  void backspace() {
    if (state.text.isNotEmpty) {
      state = state.copyWith(
        text: state.text.substring(0, state.text.length - 1),
      );
    }
  }

  void clearText() {
    state = state.copyWith(text: '');
  }

  void toggleShift() {
    state = state.copyWith(isShifted: !state.isShifted);
  }

  void toggleNumeric() {
    state = state.copyWith(isNumeric: !state.isNumeric, isSymbols: false);
  }

  void toggleSymbols() {
    state = state.copyWith(isSymbols: !state.isSymbols, isNumeric: false);
  }
}

// Main virtual keyboard widget
class VirtualKeyboard extends ConsumerWidget {
  final double height;
  final Color keyColor;
  final Color textColor;
  final Color specialKeyColor;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final double keySpacing;
  final bool autofocus;
  final void Function(String)? onTextChanged;

  const VirtualKeyboard({
    super.key,
    this.height = 300,
    this.keyColor = Colors.white,
    this.textColor = Colors.black87,
    this.specialKeyColor = Colors.blueGrey,
    this.backgroundColor = Colors.black12,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.keySpacing = 4.0,
    this.autofocus = false,
    this.onTextChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyboardState = ref.watch(keyboardStateProvider);
    final keyboardNotifier = ref.read(keyboardStateProvider.notifier);

    // Call the callback whenever text changes
    if (onTextChanged != null) {
      onTextChanged!(keyboardState.text);
    }

    return Container(
      height: height,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: _buildKeyboard(keyboardState, keyboardNotifier, context),
    );
  }

  Widget _buildKeyboard(
    KeyboardState state,
    KeyboardStateNotifier notifier,
    BuildContext context,
  ) {
    if (state.isNumeric) {
      return _buildNumericKeyboard(state, notifier, context);
    } else if (state.isSymbols) {
      return _buildSymbolsKeyboard(state, notifier, context);
    } else {
      return _buildAlphabeticKeyboard(state, notifier, context);
    }
  }

  Widget _buildAlphabeticKeyboard(
    KeyboardState state,
    KeyboardStateNotifier notifier,
    BuildContext context,
  ) {
    final List<List<String>> keys = [
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
      ['shift', 'z', 'x', 'c', 'v', 'b', 'n', 'm', 'backspace'],
      ['123', 'space', '?123', 'done'],
    ];

    return Column(
      children: [
        for (var row in keys)
          Expanded(
            child: Row(
              children:
                  row.map((key) {
                    switch (key) {
                      case 'shift':
                        return _buildSpecialKey(
                          const Icon(Icons.keyboard_capslock),
                          flex: 1,
                          onTap: () => notifier.toggleShift(),
                          isActive: state.isShifted,
                        );
                      case 'backspace':
                        return _buildSpecialKey(
                          const Icon(Icons.backspace_outlined),
                          flex: 1,
                          onTap: () => notifier.backspace(),
                        );
                      case 'space':
                        return _buildKey(
                          ' ',
                          flex: 4,
                          onTap: () => notifier.addText(' '),
                        );
                      case '123':
                      case '?123':
                        return _buildSpecialKey(
                          Text(key),
                          flex: 1,
                          onTap: () => notifier.toggleNumeric(),
                        );
                      case 'done':
                        return _buildSpecialKey(
                          const Text('Done'),
                          flex: 1,
                          onTap: () => FocusScope.of(context).unfocus(),
                        );
                      default:
                        return _buildKey(
                          state.isShifted ? key.toUpperCase() : key,
                          flex: 1,
                          onTap:
                              () => notifier.addText(
                                state.isShifted ? key.toUpperCase() : key,
                              ),
                        );
                    }
                  }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildNumericKeyboard(
    KeyboardState state,
    KeyboardStateNotifier notifier,
    BuildContext context,
  ) {
    final List<List<String>> keys = [
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
      ['-', '/', ':', ';', '(', ')', '\$', '&', '@', '"'],
      ['#+=', '.', ',', '?', '!', '\'', 'backspace'],
      ['ABC', 'space', '#+=', 'done'],
    ];

    return Column(
      children: [
        for (var row in keys)
          Expanded(
            child: Row(
              children:
                  row.map((key) {
                    switch (key) {
                      case 'backspace':
                        return _buildSpecialKey(
                          const Icon(Icons.backspace_outlined),
                          flex: 1,
                          onTap: () => notifier.backspace(),
                        );
                      case 'space':
                        return _buildKey(
                          ' ',
                          flex: 4,
                          onTap: () => notifier.addText(' '),
                        );
                      case 'ABC':
                        return _buildSpecialKey(
                          const Text('ABC'),
                          flex: 1,
                          onTap: () => notifier.toggleNumeric(),
                        );
                      case '#+=':
                        return _buildSpecialKey(
                          const Text('#+='),
                          flex: 1,
                          onTap: () => notifier.toggleSymbols(),
                        );
                      case 'done':
                        return _buildSpecialKey(
                          const Text('Done'),
                          flex: 1,
                          onTap: () => FocusScope.of(context).unfocus(),
                        );
                      default:
                        return _buildKey(
                          key,
                          flex: 1,
                          onTap: () => notifier.addText(key),
                        );
                    }
                  }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSymbolsKeyboard(
    KeyboardState state,
    KeyboardStateNotifier notifier,
    BuildContext context,
  ) {
    final List<List<String>> keys = [
      ['[', ']', '{', '}', '#', '%', '^', '*', '+', '='],
      ['_', '\\', '|', '~', '<', '>', '€', '£', '¥', '•'],
      ['123', '.', ',', '?', '!', '\'', 'backspace'],
      ['ABC', 'space', '123', 'done'],
    ];

    return Column(
      children: [
        for (var row in keys)
          Expanded(
            child: Row(
              children:
                  row.map((key) {
                    switch (key) {
                      case 'backspace':
                        return _buildSpecialKey(
                          const Icon(Icons.backspace_outlined),
                          flex: 1,
                          onTap: () => notifier.backspace(),
                        );
                      case 'space':
                        return _buildKey(
                          ' ',
                          flex: 4,
                          onTap: () => notifier.addText(' '),
                        );
                      case 'ABC':
                        return _buildSpecialKey(
                          const Text('ABC'),
                          flex: 1,
                          onTap: () => notifier.toggleNumeric(),
                          onDoubleTap: () {
                            notifier.toggleNumeric();
                            notifier.toggleNumeric();
                          },
                        );
                      case '123':
                        return _buildSpecialKey(
                          const Text('123'),
                          flex: 1,
                          onTap: () => notifier.toggleSymbols(),
                        );
                      case 'done':
                        return _buildSpecialKey(
                          const Text('Done'),
                          flex: 1,
                          onTap: () => FocusScope.of(context).unfocus(),
                        );
                      default:
                        return _buildKey(
                          key,
                          flex: 1,
                          onTap: () => notifier.addText(key),
                        );
                    }
                  }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildKey(
    String text, {
    required int flex,
    required VoidCallback onTap,
    VoidCallback? onDoubleTap,
    bool isActive = false,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.all(keySpacing),
        child: Material(
          elevation: 2,
          borderRadius: borderRadius,
          color: keyColor,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(
    Widget child, {
    required int flex,
    required VoidCallback onTap,
    VoidCallback? onDoubleTap,
    bool isActive = false,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.all(keySpacing),
        child: Material(
          elevation: 2,
          borderRadius: borderRadius,
          color: isActive ? Colors.blue.shade300 : specialKeyColor,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            child: Container(
              alignment: Alignment.center,
              child: IconTheme(
                data: IconThemeData(color: Colors.white, size: 22),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Example implementation
class KeyboardExample extends ConsumerWidget {
  const KeyboardExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyboardState = ref.watch(keyboardStateProvider);
    final keyboardNotifier = ref.read(keyboardStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Keyboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => keyboardNotifier.clearText(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  keyboardState.text.isEmpty
                      ? 'Type something...'
                      : keyboardState.text,
                  style: TextStyle(
                    fontSize: 24,
                    color:
                        keyboardState.text.isEmpty
                            ? Colors.grey
                            : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          VirtualKeyboard(
            height: 280,
            keyColor: Colors.white,
            specialKeyColor: Colors.grey.shade300,
            backgroundColor: Colors.grey.shade100,
            textColor: Colors.black87,
            borderRadius: BorderRadius.circular(8),
            keySpacing: 4,
          ),
        ],
      ),
    );
  }
}

// Main app entry point
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Keyboard Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const KeyboardExample(),
    );
  }
}
