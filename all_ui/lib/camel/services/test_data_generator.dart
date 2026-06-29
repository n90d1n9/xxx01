// Test Data Generator
import 'dart:math' as math;

class TestDataGenerator {
  static Map<String, dynamic> generateSampleData(String type) {
    switch (type) {
      case 'order':
        return {
          'orderId': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
          'customerId': 'CUST-${math.Random().nextInt(1000)}',
          'items': [
            {
              'productId': 'PROD-${math.Random().nextInt(100)}',
              'quantity': math.Random().nextInt(10) + 1,
              'price': (math.Random().nextDouble() * 100).toStringAsFixed(2),
            },
          ],
          'total': (math.Random().nextDouble() * 500).toStringAsFixed(2),
          'status':
              ['pending', 'processing', 'completed'][math.Random().nextInt(3)],
          'createdAt': DateTime.now().toIso8601String(),
        };
      case 'user':
        return {
          'userId': 'USER-${DateTime.now().millisecondsSinceEpoch}',
          'email': 'user${math.Random().nextInt(1000)}@example.com',
          'name': 'Test User ${math.Random().nextInt(100)}',
          'age': math.Random().nextInt(50) + 18,
          'active': math.Random().nextBool(),
          'createdAt': DateTime.now().toIso8601String(),
        };
      case 'event':
        return {
          'eventId': 'EVT-${DateTime.now().millisecondsSinceEpoch}',
          'type':
              ['click', 'view', 'purchase', 'login'][math.Random().nextInt(4)],
          'userId': 'USER-${math.Random().nextInt(1000)}',
          'timestamp': DateTime.now().toIso8601String(),
          'data': {'page': '/home', 'action': 'button_click'},
        };
      case 'message':
        return {
          'messageId': 'MSG-${DateTime.now().millisecondsSinceEpoch}',
          'from': 'sender${math.Random().nextInt(100)}@example.com',
          'to': 'receiver${math.Random().nextInt(100)}@example.com',
          'subject': 'Test Message ${math.Random().nextInt(1000)}',
          'body': 'This is a test message with random content.',
          'timestamp': DateTime.now().toIso8601String(),
        };
      default:
        return {
          'id': DateTime.now().millisecondsSinceEpoch,
          'data': 'Sample data',
          'timestamp': DateTime.now().toIso8601String(),
        };
    }
  }
}
