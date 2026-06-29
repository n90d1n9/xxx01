class Employee {
  final int id;
  final String name;
  final String? position;
  final String? department;
  final String? email;
  final String? phone;
  final DateTime? hireDate;
  final String? imageUrl;
  final double? salary;
  final String? address;
  final String? employeeId;
  final String? dateOfBirth;
  final String? managerName;
  final bool isActive;

  Employee({
    required this.id,
    required this.name,
    this.department,
    this.employeeId,
    this.email,
    this.phone,
    this.hireDate,
    this.imageUrl,
    this.salary,
    this.position,
    this.address,
    this.dateOfBirth,
    this.managerName,
    this.isActive = true,
  });

  Employee copyWith({
    int? id,
    String? name,
    String? position,
    String? department,
    String? email,
    String? phone,
    DateTime? hireDate,
    String? imageUrl,
    double? salary,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      department: department ?? this.department,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      hireDate: hireDate ?? this.hireDate,
      imageUrl: imageUrl ?? this.imageUrl,
      salary: salary ?? this.salary,
    );
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      name: json['name'] as String,
      position: json['position'] as String,
      department: json['department'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      hireDate:
          json['hireDate'] != null
              ? DateTime.parse(json['hireDate'] as String)
              : null,
      imageUrl: json['imageUrl'] as String?,
      salary: json['salary'] != null ? json['salary'] as double : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'department': department,
      'email': email,
      'phone': phone,
      'hireDate': hireDate?.toIso8601String(),
      'imageUrl': imageUrl,
      'salary': salary,
    };
  }
}
