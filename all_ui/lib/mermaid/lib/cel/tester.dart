import 'service/cel_evaluator.dart';

void main() {
  final evaluator = CELEvaluator();

  // Example 1: Simple comparison
  print('Example 1: Age check');
  final context1 = {
    'user': {'age': 25, 'name': 'John'},
  };
  final result1 = evaluator.evaluate('user.age >= 18', context1);
  print('Result: $result1\n'); // true

  // Example 2: Logical operations
  print('Example 2: Multiple conditions');
  final context2 = {
    'user': {'age': 25, 'verified': true, 'status': 'active'},
  };
  final result2 = evaluator.evaluate(
    'user.age >= 18 && user.verified == true && user.status == "active"',
    context2,
  );
  print('Result: $result2\n'); // true

  // Example 3: String functions
  print('Example 3: String operations');
  final context3 = {'email': 'john@example.com'};
  final result3 = evaluator.evaluate(
    'email.contains("@") && email.endsWith(".com")',
    context3,
  );
  print('Result: $result3\n'); // true

  // Example 4: List operations
  print('Example 4: List filtering');
  final context4 = {
    'numbers': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
  };
  final result4 = evaluator.evaluate('size(numbers) > 5', context4);
  print('Result: $result4\n'); // true

  // Example 5: Ternary operator
  print('Example 5: Ternary');
  final context5 = {
    'user': {'age': 15},
  };
  final result5 = evaluator.evaluate(
    'user.age >= 18 ? "adult" : "minor"',
    context5,
  );
  print('Result: $result5\n'); // "minor"

  // Example 6: Arithmetic
  print('Example 6: Math');
  final context6 = {'price': 100.0, 'quantity': 3, 'discount': 0.1};
  final result6 = evaluator.evaluate(
    'price * quantity * (1 - discount)',
    context6,
  );
  print('Result: $result6\n'); // 270.0

  // Example 7: In operator
  print('Example 7: In operator');
  final context7 = {
    'user': {'role': 'admin'},
    'allowedRoles': ['admin', 'moderator'],
  };
  final result7 = evaluator.evaluate('user.role in allowedRoles', context7);
  print('Result: $result7\n'); // true

  // Example 8: Complex nested
  print('Example 8: Complex expression');
  final context8 = {
    'request': {
      'path': '/api/users',
      'method': 'GET',
      'headers': {'Authorization': 'Bearer token123'},
    },
    'user': {
      'roles': ['admin', 'user'],
    },
  };
  final result8 = evaluator.evaluate(
    'request.path.startsWith("/api") && request.method == "GET" && has(request.headers, "Authorization")',
    context8,
  );
  print('Result: $result8'); // true
}
