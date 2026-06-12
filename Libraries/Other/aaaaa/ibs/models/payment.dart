import 'enums.dart';
import 'student.dart';

class Payment {
  final int id; // Unique identifier for the payment
  final DateTime paymentDate; // Date of payment, required
  final double amount; // Payment amount, required
  final String? description; // Payment description
  final PaymentStatus status; // Payment status, default=pending
  final Student
  student; // Student associated with the payment, manyToOne relationship

  Payment({
    required this.id,
    required this.paymentDate,
    required this.amount,
    this.description,
    this.status = PaymentStatus.pending,
    required this.student,
  });

  Payment copyWith({
    int? id,
    DateTime? paymentDate,
    double? amount,
    String? description,
    PaymentStatus? status,
    Student? student,
  }) {
    return Payment(
      id: id ?? this.id,
      paymentDate: paymentDate ?? this.paymentDate,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      status: status ?? this.status,
      student: student ?? this.student,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentDate': paymentDate.toIso8601String(),
      'amount': amount,
      'description': description,
      'status': status.toString(),
      'student': student.toJson(),
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      paymentDate: DateTime.parse(json['paymentDate']),
      amount: json['amount'],
      description: json['description'],
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      student: Student.fromJson(json['student']),
    );
  }

  @override
  String toString() {
    return 'Payment(id: $id, paymentDate: $paymentDate, amount: $amount, description: $description, status: $status, student: $student)';
  }
}
