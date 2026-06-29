import 'enums.dart';
import 'staff.dart';
import 'teacher.dart';

class Salary {
  final int id; // Unique identifier for the salary
  final DateTime paymentDate; // Date of salary payment, required
  final double amount; // Salary amount, required
  final String? description; // Salary description
  final PaymentStatus status; // Payment status, default=pending
  final Teacher?
  teacher; // Teacher associated with the salary, manyToOne relationship
  final Staff?
  staff; // Staff associated with the salary, manyToOne relationship

  Salary({
    required this.id,
    required this.paymentDate,
    required this.amount,
    this.description,
    this.status = PaymentStatus.pending,
    this.teacher,
    this.staff,
  });

  Salary copyWith({
    int? id,
    DateTime? paymentDate,
    double? amount,
    String? description,
    PaymentStatus? status,
    Teacher? teacher,
    Staff? staff,
  }) {
    return Salary(
      id: id ?? this.id,
      paymentDate: paymentDate ?? this.paymentDate,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      status: status ?? this.status,
      teacher: teacher ?? this.teacher,
      staff: staff ?? this.staff,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentDate': paymentDate.toIso8601String(),
      'amount': amount,
      'description': description,
      'status': status.toString(),
      'teacher': teacher?.toJson(),
      'staff': staff?.toJson(),
    };
  }

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      id: json['id'],
      paymentDate: DateTime.parse(json['paymentDate']),
      amount: json['amount'],
      description: json['description'],
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      teacher:
          json['teacher'] != null ? Teacher.fromJson(json['teacher']) : null,
      staff: json['staff'] != null ? Staff.fromJson(json['staff']) : null,
    );
  }

  @override
  String toString() {
    return 'Salary(id: $id, paymentDate: $paymentDate, amount: $amount, description: $description, status: $status, teacher: $teacher, staff: $staff)';
  }
}
