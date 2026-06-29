import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

// Calculator state
class CalculatorState {
  final String input;
  final String result;
  final bool showResult;
  final String memory;

  CalculatorState({
    this.input = '',
    this.result = '',
    this.showResult = false,
    this.memory = '',
  });

  CalculatorState copyWith({
    String? input,
    String? result,
    bool? showResult,
    String? memory,
  }) {
    return CalculatorState(
      input: input ?? this.input,
      result: result ?? this.result,
      showResult: showResult ?? this.showResult,
      memory: memory ?? this.memory,
    );
  }
}

// Calculator notifier
class CalculatorNotifier extends StateNotifier<CalculatorState> {
  CalculatorNotifier() : super(CalculatorState());

  void appendInput(String value) {
    if (state.showResult) {
      // If we're showing a result and user inputs a number, start fresh
      if (isNumeric(value)) {
        state = state.copyWith(input: value, showResult: false);
        return;
      }
      // If it's an operator, use the previous result
      else if (isOperator(value)) {
        state = state.copyWith(input: state.result + value, showResult: false);
        return;
      }
    }

    // Handle decimal point logic
    if (value == '.') {
      final parts = state.input.split(RegExp(r'[-+×÷]'));
      if (parts.isNotEmpty && parts.last.contains('.')) {
        return; // Don't allow multiple decimal points in a number
      }
    }

    // Don't allow two operators in a row
    if (isOperator(value) &&
        state.input.isNotEmpty &&
        isOperator(state.input[state.input.length - 1])) {
      state = state.copyWith(
        input: state.input.substring(0, state.input.length - 1) + value,
      );
      return;
    }

    state = state.copyWith(input: state.input + value);
  }

  void calculate() {
    if (state.input.isEmpty) return;

    // Handle incomplete expressions
    if (isOperator(state.input[state.input.length - 1])) {
      state = state.copyWith(
        input: state.input.substring(0, state.input.length - 1),
      );
    }

    try {
      final calculatedResult = evaluateExpression(state.input);
      state = state.copyWith(result: calculatedResult, showResult: true);
    } catch (e) {
      state = state.copyWith(result: 'Error', showResult: true);
    }
  }

  void clear() {
    state = CalculatorState();
  }

  void backspace() {
    if (state.showResult) {
      state = state.copyWith(showResult: false, input: '');
      return;
    }

    if (state.input.isNotEmpty) {
      state = state.copyWith(
        input: state.input.substring(0, state.input.length - 1),
      );
    }
  }

  void handlePercent() {
    if (state.input.isEmpty) return;

    try {
      // Parse the current input as a number and calculate percentage
      final number = double.parse(state.input);
      final percentResult = (number / 100).toString();
      state = state.copyWith(result: percentResult, showResult: true);
    } catch (e) {
      // If input has operators, try to evaluate the expression first
      try {
        final calculatedResult = evaluateExpression(state.input);
        final percentResult = (double.parse(calculatedResult) / 100).toString();
        state = state.copyWith(result: percentResult, showResult: true);
      } catch (e) {
        state = state.copyWith(result: 'Error', showResult: true);
      }
    }
  }

  void toggleSign() {
    if (state.showResult) {
      final result = state.result;
      if (result.startsWith('-')) {
        state = state.copyWith(result: result.substring(1));
      } else {
        state = state.copyWith(result: '-$result');
      }
      return;
    }

    if (state.input.isEmpty) return;

    // If only a single number, just toggle the sign
    if (!state.input.contains(RegExp(r'[+\-×÷]'))) {
      if (state.input.startsWith('-')) {
        state = state.copyWith(input: state.input.substring(1));
      } else {
        state = state.copyWith(input: '-${state.input}');
      }
      return;
    }

    // For complex expressions, we need to evaluate first
    calculate();
    toggleSign(); // Now the result is shown, so the above case will handle it
  }

  void storeInMemory() {
    if (state.showResult && state.result.isNotEmpty) {
      state = state.copyWith(memory: state.result);
    } else if (state.input.isNotEmpty) {
      state = state.copyWith(memory: state.input);
    }
  }

  void recallMemory() {
    if (state.memory.isEmpty) return;

    if (state.showResult) {
      state = state.copyWith(input: state.memory, showResult: false);
    } else {
      state = state.copyWith(input: state.input + state.memory);
    }
  }

  void clearMemory() {
    state = state.copyWith(memory: '');
  }

  bool isNumeric(String value) {
    return value == '.' || RegExp(r'^[0-9]$').hasMatch(value);
  }

  bool isOperator(String value) {
    return RegExp(r'^[+\-×÷]$').hasMatch(value);
  }

  String evaluateExpression(String expression) {
    // Replace '×' and '÷' with '*' and '/' for parsing
    expression = expression.replaceAll('×', '*').replaceAll('÷', '/');

    // Split by operators while keeping them
    List<String> tokens = [];
    String currentNumber = '';

    for (int i = 0; i < expression.length; i++) {
      if (RegExp(r'[+\-*/]').hasMatch(expression[i])) {
        // If we have a negative number at the start or after an operator, handle differently
        if (expression[i] == '-' &&
            (i == 0 || RegExp(r'[+\-*/]').hasMatch(expression[i - 1]))) {
          currentNumber += expression[i];
        } else {
          if (currentNumber.isNotEmpty) {
            tokens.add(currentNumber);
            currentNumber = '';
          }
          tokens.add(expression[i]);
        }
      } else {
        currentNumber += expression[i];
      }
    }

    if (currentNumber.isNotEmpty) {
      tokens.add(currentNumber);
    }

    // Perform the calculation with operator precedence
    return calculateWithPrecedence(tokens).toString();
  }

  double calculateWithPrecedence(List<String> tokens) {
    // First pass: multiply and divide
    List<String> secondPass = [];

    for (int i = 0; i < tokens.length; i++) {
      if (i + 1 < tokens.length &&
          (tokens[i + 1] == '*' || tokens[i + 1] == '/')) {
        double leftValue = double.parse(tokens[i]);
        double rightValue = double.parse(tokens[i + 2]);
        double result;

        if (tokens[i + 1] == '*') {
          result = leftValue * rightValue;
        } else {
          result = leftValue / rightValue;
        }

        secondPass.add(result.toString());
        i += 2; // Skip the processed tokens
      } else if (i - 1 >= 0 && (tokens[i - 1] == '*' || tokens[i - 1] == '/')) {
        // Skip, already processed
      } else {
        secondPass.add(tokens[i]);
      }
    }

    // Second pass: add and subtract
    double result = double.parse(secondPass[0]);

    for (int i = 1; i < secondPass.length; i += 2) {
      if (i + 1 >= secondPass.length) break;

      double rightValue = double.parse(secondPass[i + 1]);

      if (secondPass[i] == '+') {
        result += rightValue;
      } else if (secondPass[i] == '-') {
        result -= rightValue;
      }
    }

    // Format the result to avoid unnecessary decimals
    if (result == result.round()) {
      return result.roundToDouble();
    }

    return result;
  }
}

// Provider
final calculatorProvider =
    StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
      return CalculatorNotifier();
    });

// Main calculator widget
class CalculatorWidget extends ConsumerWidget {
  const CalculatorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF22252D),
      body: SafeArea(
        child: Column(
          children: [
            // Display
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Memory indicator
                    if (state.memory.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'M',
                          style: TextStyle(
                            color: Color(0xFF4ECDC4),
                            fontSize: 20,
                          ),
                        ),
                      ),
                    // Input
                    Text(
                      state.showResult ? '' : state.input,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 28,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 8),
                    // Result
                    Text(
                      state.showResult ? state.result : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ),

            // Buttons
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF2A2D37),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton(
                            text: 'MC',
                            color: const Color(0xFF4ECDC4),
                            onPressed:
                                () =>
                                    ref
                                        .read(calculatorProvider.notifier)
                                        .clearMemory(),
                          ),
                          CalculatorButton(
                            text: 'MR',
                            color: const Color(0xFF4ECDC4),
                            onPressed:
                                () =>
                                    ref
                                        .read(calculatorProvider.notifier)
                                        .recallMemory(),
                          ),
                          CalculatorButton(
                            text: 'M+',
                            color: const Color(0xFF4ECDC4),
                            onPressed:
                                () =>
                                    ref
                                        .read(calculatorProvider.notifier)
                                        .storeInMemory(),
                          ),
                          CalculatorButton(
                            text: 'C',
                            color: const Color(0xFFFF6B6B),
                            onPressed:
                                () =>
                                    ref
                                        .read(calculatorProvider.notifier)
                                        .clear(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton(
                            text: '7',
                            onPressed:
                                () => ref
                                    .read(calculatorProvider.notifier)
                                    .appendInput('7'),
                          ),
                          CalculatorButton(
                            text: '8',
                            onPressed:
                                () => ref
                                    .read(calculatorProvider.notifier)
                                    .appendInput('8'),
                          ),
                          CalculatorButton(
                            text: '9',
                            onPressed:
                                () => ref
                                    .read(calculatorProvider.notifier)
                                    .appendInput('9'),
                          ),
                          CalculatorButton(
                            text: '÷',
                            color: const Color(0xFFF9C80E),
                            onPressed:
                                () => ref
                                    .read(calculatorProvider.notifier)
                                    .appendInput('÷'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton(
                            text: '4',
                            onPressed:
                                () => ref
                                    .read(calculatorProvider.notifier)
                                    .appendInput('4'),
                          ),
                          CalculatorButton(
                            text: '5',
                            onPressed:
                                () => ref
                                    .read(calculatorProvider.notifier)
                                    .appendInput('5'),
                          ),
                          CalculatorButton(
                            text: '6',
                            onPressed:
                                () => ref
                                    .read(calculatorProvider.notifier)
                                    .appendInput('6'),
                          ),
                          CalculatorButton(
                            text: '×',
                            color: const Color(0xFFF9C80E),
                            onPressed:
                                () => ref
                                    .read(calculatorProvider.notifier)
                                    .appendInput('×'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton(
                            text: '1',
                            onPressed:
                                () => ref
                                    .read(calculatorProvider.notifier)
                                    .appendInput('1'),
                          ),
                          CalculatorButton(
                            text: '2',
                            onPressed:
                                () => ref
                                    .read(calculatorProvider.notifier)
                                    .appendInput('2'),
                          ),
                          CalculatorButton(
                            text: '3',
                            onPressed:
                                () => ref
                                    .read(calculatorProvider.notifier)
                                    .appendInput('3'),
                          ),
                          CalculatorButton(
                            text: '-',
                            color: const Color(0xFFF9C80E),
                            onPressed:
                                () => ref
                                    .read(calculatorProvider.notifier)
                                    .appendInput('-'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton(
                            text: '%',
                            onPressed:
                                () =>
                                    ref
                                        .read(calculatorProvider.notifier)
                                        .handlePercent(),
                          ),
                          CalculatorButton(
                            text: '0',
                            onPressed:
                                () => ref
                                    .read(calculatorProvider.notifier)
                                    .appendInput('0'),
                          ),
                          CalculatorButton(
                            text: '.',
                            onPressed:
                                () => ref
                                    .read(calculatorProvider.notifier)
                                    .appendInput('.'),
                          ),
                          CalculatorButton(
                            text: '+',
                            color: const Color(0xFFF9C80E),
                            onPressed:
                                () => ref
                                    .read(calculatorProvider.notifier)
                                    .appendInput('+'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton(
                            text: '+/-',
                            onPressed:
                                () =>
                                    ref
                                        .read(calculatorProvider.notifier)
                                        .toggleSign(),
                          ),
                          CalculatorButton(
                            text: '⌫',
                            onPressed:
                                () =>
                                    ref
                                        .read(calculatorProvider.notifier)
                                        .backspace(),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: ElevatedButton(
                                onPressed:
                                    () =>
                                        ref
                                            .read(calculatorProvider.notifier)
                                            .calculate(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4ECDC4),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  '=',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Button widget
class CalculatorButton extends StatelessWidget {
  final String text;
  final Color? color;
  final VoidCallback onPressed;

  const CalculatorButton({
    super.key,
    required this.text,
    this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color(0xFF2E323C),
            foregroundColor: color != null ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.zero,
            elevation: 2,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: text.length > 1 ? 18 : 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// Usage example
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Poppins', brightness: Brightness.dark),
        home: const CalculatorWidget(),
      ),
    );
  }
}

void main() {
  runApp(const CalculatorApp());
}
