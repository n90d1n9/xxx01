import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math' as math;

// Scientific Calculator state
class ScientificCalculatorState {
  final String input;
  final String result;
  final bool showResult;
  final String memory;
  final bool isRadianMode;
  final bool isScientificMode;

  ScientificCalculatorState({
    this.input = '',
    this.result = '',
    this.showResult = false,
    this.memory = '',
    this.isRadianMode = true,
    this.isScientificMode = false,
  });

  ScientificCalculatorState copyWith({
    String? input,
    String? result,
    bool? showResult,
    String? memory,
    bool? isRadianMode,
    bool? isScientificMode,
  }) {
    return ScientificCalculatorState(
      input: input ?? this.input,
      result: result ?? this.result,
      showResult: showResult ?? this.showResult,
      memory: memory ?? this.memory,
      isRadianMode: isRadianMode ?? this.isRadianMode,
      isScientificMode: isScientificMode ?? this.isScientificMode,
    );
  }
}

// Calculator notifier
class ScientificCalculatorNotifier
    extends StateNotifier<ScientificCalculatorState> {
  ScientificCalculatorNotifier() : super(ScientificCalculatorState());

  void toggleScientificMode() {
    state = state.copyWith(isScientificMode: !state.isScientificMode);
  }

  void toggleAngleMode() {
    state = state.copyWith(isRadianMode: !state.isRadianMode);
  }

  void appendInput(String value) {
    if (state.showResult) {
      // If we're showing a result and user inputs a number, start fresh
      if (isNumeric(value) || value == 'π' || value == 'e') {
        state = state.copyWith(input: value, showResult: false);
        return;
      }
      // If it's an operator, use the previous result
      else if (isOperator(value)) {
        state = state.copyWith(input: state.result + value, showResult: false);
        return;
      }
      // If it's a function, start with the function
      else if (isFunction(value)) {
        state = state.copyWith(
          input:
              value +
              '(' +
              (isNumeric(state.result.substring(0, 1)) ? state.result : '') +
              ')',
          showResult: false,
        );
        return;
      }
    }

    // Handle decimal point logic
    if (value == '.') {
      final parts = state.input.split(RegExp(r'[-+×÷^()]'));
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

  void insertFunction(String func) {
    if (state.showResult && state.result.isNotEmpty) {
      state = state.copyWith(
        input: '$func(${state.result})',
        showResult: false,
      );
    } else {
      state = state.copyWith(input: '${state.input}$func(');
    }
  }

  void insertConstant(String constant) {
    String value = constant == 'π' ? 'π' : 'e';

    if (state.showResult) {
      state = state.copyWith(input: value, showResult: false);
    } else {
      state = state.copyWith(input: state.input + value);
    }
  }

  void insertParenthesis(String parenthesis) {
    if (state.showResult) {
      if (parenthesis == '(') {
        state = state.copyWith(input: '(', showResult: false);
      } else {
        state = state.copyWith(input: state.result + ')', showResult: false);
      }
    } else {
      state = state.copyWith(input: state.input + parenthesis);
    }
  }

  void calculate() {
    if (state.input.isEmpty) return;

    try {
      final calculatedResult = evaluateExpression(state.input);
      // Format the result for display
      final formattedResult = formatResult(double.parse(calculatedResult));
      state = state.copyWith(result: formattedResult, showResult: true);
    } catch (e) {
      state = state.copyWith(result: 'Error', showResult: true);
    }
  }

  String formatResult(double result) {
    if (result.isInfinite || result.isNaN) {
      return result.toString();
    }

    // Check if it's a whole number
    if (result == result.round()) {
      return result.round().toString();
    }

    // For very large or very small numbers, use scientific notation
    if (result.abs() > 10000000 || (result != 0 && result.abs() < 0.0001)) {
      return result.toStringAsExponential(6);
    }

    // For normal decimal numbers, limit to 8 decimal places
    return result
        .toStringAsFixed(8)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void clear() {
    state = ScientificCalculatorState(
      isScientificMode: state.isScientificMode,
      isRadianMode: state.isRadianMode,
    );
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
    return RegExp(r'^[+\-×÷^]$').hasMatch(value);
  }

  bool isFunction(String value) {
    return RegExp(r'^(sin|cos|tan|log|ln|√|asin|acos|atan)$').hasMatch(value);
  }

  String evaluateExpression(String expression) {
    // Replace constants with their values
    expression = expression.replaceAll('π', math.pi.toString());
    expression = expression.replaceAll('e', math.e.toString());

    // Handle scientific functions
    expression = handleScientificFunctions(expression);

    // Replace '×' and '÷' with '*' and '/' for parsing
    expression = expression.replaceAll('×', '*').replaceAll('÷', '/');

    // Handle exponentiation
    expression = handleExponentiation(expression);

    // Evaluate the expression using a more robust method
    return evaluateComplexExpression(expression).toString();
  }

  String handleScientificFunctions(String expression) {
    // Handle square root
    RegExp sqrtRegex = RegExp(r'√\(([^()]+|(?:\([^()]*\))*)\)');
    while (sqrtRegex.hasMatch(expression)) {
      final match = sqrtRegex.firstMatch(expression);
      if (match != null) {
        final argument = match.group(1)!;
        final evaluatedArg = evaluateComplexExpression(
          handleScientificFunctions(
            argument.replaceAll('×', '*').replaceAll('÷', '/'),
          ),
        );
        final sqrtResult = math.sqrt(evaluatedArg);
        expression = expression.replaceRange(
          match.start,
          match.end,
          sqrtResult.toString(),
        );
      }
    }

    // Handle trigonometric and other functions
    final functionRegexps = {
      'sin': RegExp(r'sin\(([^()]+|(?:\([^()]*\))*)\)'),
      'cos': RegExp(r'cos\(([^()]+|(?:\([^()]*\))*)\)'),
      'tan': RegExp(r'tan\(([^()]+|(?:\([^()]*\))*)\)'),
      'log': RegExp(r'log\(([^()]+|(?:\([^()]*\))*)\)'),
      'ln': RegExp(r'ln\(([^()]+|(?:\([^()]*\))*)\)'),
      'asin': RegExp(r'asin\(([^()]+|(?:\([^()]*\))*)\)'),
      'acos': RegExp(r'acos\(([^()]+|(?:\([^()]*\))*)\)'),
      'atan': RegExp(r'atan\(([^()]+|(?:\([^()]*\))*)\)'),
    };

    for (final func in functionRegexps.keys) {
      while (functionRegexps[func]!.hasMatch(expression)) {
        final match = functionRegexps[func]!.firstMatch(expression);
        if (match != null) {
          final argument = match.group(1)!;
          final evaluatedArg = evaluateComplexExpression(
            handleScientificFunctions(
              argument.replaceAll('×', '*').replaceAll('÷', '/'),
            ),
          );

          double functionResult;
          switch (func) {
            case 'sin':
              functionResult = state.isRadianMode
                  ? math.sin(evaluatedArg)
                  : math.sin(evaluatedArg * math.pi / 180);
              break;
            case 'cos':
              functionResult = state.isRadianMode
                  ? math.cos(evaluatedArg)
                  : math.cos(evaluatedArg * math.pi / 180);
              break;
            case 'tan':
              functionResult = state.isRadianMode
                  ? math.tan(evaluatedArg)
                  : math.tan(evaluatedArg * math.pi / 180);
              break;
            case 'log':
              functionResult = math.log(evaluatedArg) / math.ln10;
              break;
            case 'ln':
              functionResult = math.log(evaluatedArg);
              break;
            case 'asin':
              functionResult = state.isRadianMode
                  ? math.asin(evaluatedArg)
                  : math.asin(evaluatedArg) * 180 / math.pi;
              break;
            case 'acos':
              functionResult = state.isRadianMode
                  ? math.acos(evaluatedArg)
                  : math.acos(evaluatedArg) * 180 / math.pi;
              break;
            case 'atan':
              functionResult = state.isRadianMode
                  ? math.atan(evaluatedArg)
                  : math.atan(evaluatedArg) * 180 / math.pi;
              break;
            default:
              functionResult = 0;
          }

          expression = expression.replaceRange(
            match.start,
            match.end,
            functionResult.toString(),
          );
        }
      }
    }

    return expression;
  }

  String handleExponentiation(String expression) {
    // Handle exponentiation (^)
    RegExp expRegex = RegExp(
      r'(\d+\.?\d*|\.\d+|\))[ ]*\^[ ]*(\d+\.?\d*|\.\d+)',
    );
    while (expRegex.hasMatch(expression)) {
      final match = expRegex.firstMatch(expression);
      if (match != null) {
        String base = match.group(1)!;
        String exponent = match.group(2)!;

        // If base ends with closing parenthesis, find the matching opening one
        if (base.endsWith(')')) {
          int openIndex = findMatchingParenthesis(
            expression,
            match.start + base.length - 1,
          );
          if (openIndex >= 0) {
            base = expression.substring(openIndex, match.start + base.length);
            // Evaluate the expression inside the parentheses
            final innerExpression = expression.substring(
              openIndex + 1,
              match.start + base.length - 1,
            );
            base = evaluateComplexExpression(innerExpression).toString();
          }
        }

        final result = math.pow(double.parse(base), double.parse(exponent));
        expression = expression.replaceRange(
          match.start,
          match.end,
          result.toString(),
        );
      }
    }

    return expression;
  }

  int findMatchingParenthesis(String expression, int closeIndex) {
    int depth = 1;
    for (int i = closeIndex - 1; i >= 0; i--) {
      if (expression[i] == ')') {
        depth++;
      } else if (expression[i] == '(') {
        depth--;
        if (depth == 0) {
          return i;
        }
      }
    }
    return -1; // No matching parenthesis found
  }

  double evaluateComplexExpression(String expression) {
    // Handle parentheses first
    RegExp parenthesesRegex = RegExp(r'\(([^()]+)\)');
    while (parenthesesRegex.hasMatch(expression)) {
      final match = parenthesesRegex.firstMatch(expression);
      if (match != null) {
        final innerExpression = match.group(1)!;
        final result = calculateMathExpression(innerExpression);
        expression = expression.replaceRange(
          match.start,
          match.end,
          result.toString(),
        );
      }
    }

    // Now calculate the final expression
    return calculateMathExpression(expression);
  }

  double calculateMathExpression(String expression) {
    // Split the expression into tokens
    List<String> tokens = tokenizeExpression(expression);

    // First pass: multiply and divide
    List<String> secondPass = calculatePassMD(tokens);

    // Second pass: add and subtract
    return calculatePassAS(secondPass);
  }

  List<String> tokenizeExpression(String expression) {
    List<String> tokens = [];
    String currentNumber = '';
    bool lastWasOperator =
        true; // Track if the last character was an operator to handle unary minus

    for (int i = 0; i < expression.length; i++) {
      if (RegExp(r'[+\-*/]').hasMatch(expression[i])) {
        // Handle unary minus
        if (expression[i] == '-' && lastWasOperator) {
          currentNumber += expression[i];
        } else {
          if (currentNumber.isNotEmpty) {
            tokens.add(currentNumber);
            currentNumber = '';
          }
          tokens.add(expression[i]);
          lastWasOperator = true;
        }
      } else if (RegExp(r'[\d.]').hasMatch(expression[i])) {
        currentNumber += expression[i];
        lastWasOperator = false;
      } else {
        // Skip whitespace and other characters
        lastWasOperator = false;
      }
    }

    if (currentNumber.isNotEmpty) {
      tokens.add(currentNumber);
    }

    return tokens;
  }

  List<String> calculatePassMD(List<String> tokens) {
    List<String> result = [];

    for (int i = 0; i < tokens.length; i++) {
      if (i + 1 < tokens.length &&
          (tokens[i + 1] == '*' || tokens[i + 1] == '/')) {
        double leftValue = double.parse(tokens[i]);
        double rightValue = double.parse(tokens[i + 2]);
        double calculationResult;

        if (tokens[i + 1] == '*') {
          calculationResult = leftValue * rightValue;
        } else {
          calculationResult = leftValue / rightValue;
        }

        result.add(calculationResult.toString());
        i += 2; // Skip the processed tokens
      } else if (i - 1 >= 0 && (tokens[i - 1] == '*' || tokens[i - 1] == '/')) {
        // Skip, already processed
      } else {
        result.add(tokens[i]);
      }
    }

    return result;
  }

  double calculatePassAS(List<String> tokens) {
    if (tokens.isEmpty) return 0;

    double result = double.parse(tokens[0]);

    for (int i = 1; i < tokens.length; i += 2) {
      if (i + 1 >= tokens.length) break;

      double rightValue = double.parse(tokens[i + 1]);

      if (tokens[i] == '+') {
        result += rightValue;
      } else if (tokens[i] == '-') {
        result -= rightValue;
      }
    }

    return result;
  }
}

// Provider
final scientificCalculatorProvider =
    StateNotifierProvider<
      ScientificCalculatorNotifier,
      ScientificCalculatorState
    >((ref) {
      return ScientificCalculatorNotifier();
    });

// Main calculator widget
class ScientificCalculatorWidget extends ConsumerWidget {
  const ScientificCalculatorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculatorState = ref.watch(scientificCalculatorProvider);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF22252D),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // DEG/RAD toggle
                  GestureDetector(
                    onTap: () => ref
                        .read(scientificCalculatorProvider.notifier)
                        .toggleAngleMode(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2D37),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        calculatorState.isRadianMode ? 'RAD' : 'DEG',
                        style: const TextStyle(
                          color: Color(0xFF4ECDC4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Scientific mode toggle
                  GestureDetector(
                    onTap: () => ref
                        .read(scientificCalculatorProvider.notifier)
                        .toggleScientificMode(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: calculatorState.isScientificMode
                            ? const Color(0xFF4ECDC4)
                            : const Color(0xFF2A2D37),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Scientific',
                        style: TextStyle(
                          color: calculatorState.isScientificMode
                              ? Colors.black
                              : const Color(0xFF4ECDC4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Display
            Expanded(
              flex: calculatorState.isScientificMode ? 2 : 2,
              child: Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Memory indicator
                    if (calculatorState.memory.isNotEmpty)
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
                      calculatorState.showResult ? '' : calculatorState.input,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 8),
                    // Result
                    Text(
                      calculatorState.showResult ? calculatorState.result : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ),

            // Scientific buttons (conditional display)
            if (calculatorState.isScientificMode)
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            ScientificButton(
                              text: 'sin',
                              onPressed: () => ref
                                  .read(scientificCalculatorProvider.notifier)
                                  .insertFunction('sin'),
                            ),
                            ScientificButton(
                              text: 'cos',
                              onPressed: () => ref
                                  .read(scientificCalculatorProvider.notifier)
                                  .insertFunction('cos'),
                            ),
                            ScientificButton(
                              text: 'tan',
                              onPressed: () => ref
                                  .read(scientificCalculatorProvider.notifier)
                                  .insertFunction('tan'),
                            ),
                            ScientificButton(
                              text: 'π',
                              onPressed: () => ref
                                  .read(scientificCalculatorProvider.notifier)
                                  .insertConstant('π'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            ScientificButton(
                              text: 'asin',
                              onPressed: () => ref
                                  .read(scientificCalculatorProvider.notifier)
                                  .insertFunction('asin'),
                            ),
                            ScientificButton(
                              text: 'acos',
                              onPressed: () => ref
                                  .read(scientificCalculatorProvider.notifier)
                                  .insertFunction('acos'),
                            ),
                            ScientificButton(
                              text: 'atan',
                              onPressed: () => ref
                                  .read(scientificCalculatorProvider.notifier)
                                  .insertFunction('atan'),
                            ),
                            ScientificButton(
                              text: 'e',
                              onPressed: () => ref
                                  .read(scientificCalculatorProvider.notifier)
                                  .insertConstant('e'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            ScientificButton(
                              text: 'log',
                              onPressed: () => ref
                                  .read(scientificCalculatorProvider.notifier)
                                  .insertFunction('log'),
                            ),
                            ScientificButton(
                              text: 'ln',
                              onPressed: () => ref
                                  .read(scientificCalculatorProvider.notifier)
                                  .insertFunction('ln'),
                            ),
                            ScientificButton(
                              text: '√',
                              onPressed: () => ref
                                  .read(scientificCalculatorProvider.notifier)
                                  .insertFunction('√'),
                            ),
                            ScientificButton(
                              text: '^',
                              onPressed: () => ref
                                  .read(scientificCalculatorProvider.notifier)
                                  .appendInput('^'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            ScientificButton(
                              text: '(',
                              onPressed: () => ref
                                  .read(scientificCalculatorProvider.notifier)
                                  .insertParenthesis('('),
                            ),
                            ScientificButton(
                              text: ')',
                              onPressed: () => ref
                                  .read(scientificCalculatorProvider.notifier)
                                  .insertParenthesis(')'),
                            ),
                            ScientificButton(
                              text: '!',
                              onPressed: () => {}, // To be implemented
                            ),
                            ScientificButton(
                              text: 'mod',
                              onPressed: () => ref
                                  .read(scientificCalculatorProvider.notifier)
                                  .appendInput('%'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Basic buttons
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
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .clearMemory(),
                          ),
                          CalculatorButton(
                            text: 'MR',
                            color: const Color(0xFF4ECDC4),
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .recallMemory(),
                          ),
                          CalculatorButton(
                            text: 'M+',
                            color: const Color(0xFF4ECDC4),
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .storeInMemory(),
                          ),
                          CalculatorButton(
                            text: 'C',
                            color: const Color(0xFFFF6B6B),
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
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
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .appendInput('7'),
                          ),
                          CalculatorButton(
                            text: '8',
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .appendInput('8'),
                          ),
                          CalculatorButton(
                            text: '9',
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .appendInput('9'),
                          ),
                          CalculatorButton(
                            text: '÷',
                            color: const Color(0xFFF9C80E),
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
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
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .appendInput('4'),
                          ),
                          CalculatorButton(
                            text: '5',
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .appendInput('5'),
                          ),
                          CalculatorButton(
                            text: '6',
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .appendInput('6'),
                          ),
                          CalculatorButton(
                            text: '×',
                            color: const Color(0xFFF9C80E),
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
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
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .appendInput('1'),
                          ),
                          CalculatorButton(
                            text: '2',
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .appendInput('2'),
                          ),
                          CalculatorButton(
                            text: '3',
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .appendInput('3'),
                          ),
                          CalculatorButton(
                            text: '-',
                            color: const Color(0xFFF9C80E),
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .appendInput('-'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton(
                            text: '0',
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .appendInput('0'),
                          ),
                          CalculatorButton(
                            text: '.',
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .appendInput('.'),
                          ),
                          CalculatorButton(
                            text: '⌫',
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .backspace(),
                          ),
                          CalculatorButton(
                            text: '+',
                            color: const Color(0xFFF9C80E),
                            onPressed: () => ref
                                .read(scientificCalculatorProvider.notifier)
                                .appendInput('+'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: ElevatedButton(
                                onPressed: () => ref
                                    .read(scientificCalculatorProvider.notifier)
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

// Regular calculator button
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
            foregroundColor: color != null && color != const Color(0xFF2E323C)
                ? Colors.black
                : Colors.white,
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

// Scientific calculator button (slightly different styling)
class ScientificButton extends StatelessWidget {
  final String text;
  final Color? color;
  final VoidCallback onPressed;

  const ScientificButton({
    super.key,
    required this.text,
    this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color(0xFF373A46),
            foregroundColor: color != null ? Colors.black : Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.zero,
            elevation: 1,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: text.length > 1 ? 16 : 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// Usage example
class ScientificCalculatorApp extends StatelessWidget {
  const ScientificCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Poppins', brightness: Brightness.dark),
        home: const ScientificCalculatorWidget(),
      ),
    );
  }
}

void main() {
  runApp(const ScientificCalculatorApp());
}
