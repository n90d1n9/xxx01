enum PayrollExceptionSeverity {
  critical('Critical'),
  warning('Warning'),
  info('Info');

  final String label;

  const PayrollExceptionSeverity(this.label);
}

enum PayrollExceptionStatus {
  open('Open'),
  resolved('Resolved');

  final String label;

  const PayrollExceptionStatus(this.label);
}

class PayrollExceptionItem {
  final String id;
  final String title;
  final String employeeName;
  final String owner;
  final DateTime dueDate;
  final PayrollExceptionSeverity severity;
  final PayrollExceptionStatus status;
  final String action;

  const PayrollExceptionItem({
    required this.id,
    required this.title,
    required this.employeeName,
    required this.owner,
    required this.dueDate,
    required this.severity,
    required this.status,
    required this.action,
  });

  bool get isOpen => status == PayrollExceptionStatus.open;

  bool get isCritical =>
      isOpen && severity == PayrollExceptionSeverity.critical;

  PayrollExceptionItem copyWith({PayrollExceptionStatus? status}) {
    return PayrollExceptionItem(
      id: id,
      title: title,
      employeeName: employeeName,
      owner: owner,
      dueDate: dueDate,
      severity: severity,
      status: status ?? this.status,
      action: action,
    );
  }
}
