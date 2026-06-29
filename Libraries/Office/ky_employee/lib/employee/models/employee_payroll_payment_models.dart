import 'employee_payroll_models.dart';
import 'employee_payroll_run_models.dart';

enum EmployeePayrollPaymentStatus {
  blocked('Blocked'),
  ready('Ready'),
  scheduled('Scheduled'),
  paid('Paid'),
  held('Held');

  final String label;

  const EmployeePayrollPaymentStatus(this.label);
}

enum EmployeePayrollPaymentInstructionStatus {
  blocked('Blocked'),
  ready('Ready'),
  scheduled('Scheduled'),
  paid('Paid'),
  held('Held');

  final String label;

  const EmployeePayrollPaymentInstructionStatus(this.label);
}

class EmployeePayrollPaymentInstruction {
  final String id;
  final EmployeePaymentMethod method;
  final EmployeePayrollPaymentInstructionStatus status;
  final String title;
  final String detail;
  final double amount;
  final String currencyCode;
  final String bankName;
  final String maskedAccount;
  final String routingCode;
  final int sortOrder;

  const EmployeePayrollPaymentInstruction({
    required this.id,
    required this.method,
    required this.status,
    required this.title,
    required this.detail,
    required this.amount,
    required this.currencyCode,
    required this.bankName,
    required this.maskedAccount,
    required this.routingCode,
    required this.sortOrder,
  });

  bool get isBlocked {
    return status == EmployeePayrollPaymentInstructionStatus.blocked ||
        status == EmployeePayrollPaymentInstructionStatus.held;
  }

  bool get isSettled => status == EmployeePayrollPaymentInstructionStatus.paid;
}

class EmployeePayrollPaymentProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final DateTime payDate;
  final String currencyCode;
  final EmployeePayrollPaymentStatus status;
  final EmployeePayrollRunStatus runStatus;
  final EmployeePaymentMethod paymentMethod;
  final EmployeeBankVerificationStatus bankVerificationStatus;
  final String exportBatchId;
  final double netPay;
  final String bankName;
  final String maskedAccount;
  final String routingCode;
  final List<EmployeePayrollPaymentInstruction> instructions;
  final String paymentOwner;
  final String paymentNote;
  final String paymentReference;
  final DateTime? scheduledFor;
  final DateTime? paidAt;

  const EmployeePayrollPaymentProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.payDate,
    required this.currencyCode,
    required this.status,
    required this.runStatus,
    required this.paymentMethod,
    required this.bankVerificationStatus,
    required this.exportBatchId,
    required this.netPay,
    required this.bankName,
    required this.maskedAccount,
    required this.routingCode,
    required this.instructions,
    required this.paymentOwner,
    required this.paymentNote,
    required this.paymentReference,
    required this.scheduledFor,
    required this.paidAt,
  });

  EmployeePayrollPaymentProfile copyWith({
    EmployeePayrollPaymentStatus? status,
    List<EmployeePayrollPaymentInstruction>? instructions,
    String? paymentOwner,
    String? paymentNote,
    String? paymentReference,
    DateTime? scheduledFor,
    DateTime? paidAt,
  }) {
    return EmployeePayrollPaymentProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      payDate: payDate,
      currencyCode: currencyCode,
      status: status ?? this.status,
      runStatus: runStatus,
      paymentMethod: paymentMethod,
      bankVerificationStatus: bankVerificationStatus,
      exportBatchId: exportBatchId,
      netPay: netPay,
      bankName: bankName,
      maskedAccount: maskedAccount,
      routingCode: routingCode,
      instructions: instructions ?? this.instructions,
      paymentOwner: paymentOwner ?? this.paymentOwner,
      paymentNote: paymentNote ?? this.paymentNote,
      paymentReference: paymentReference ?? this.paymentReference,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  List<EmployeePayrollPaymentInstruction> get sortedInstructions {
    final sorted = [...instructions];
    sorted.sort((a, b) {
      final sortCompare = a.sortOrder.compareTo(b.sortOrder);
      if (sortCompare != 0) return sortCompare;
      return a.title.compareTo(b.title);
    });
    return sorted;
  }

  bool get requiresVerifiedBank {
    return paymentMethod != EmployeePaymentMethod.manual;
  }

  bool get hasVerifiedBank {
    return bankVerificationStatus == EmployeeBankVerificationStatus.verified;
  }

  int get blockingCount {
    if (status != EmployeePayrollPaymentStatus.blocked) return 0;

    var count = 0;
    if (runStatus != EmployeePayrollRunStatus.exported) count++;
    if (requiresVerifiedBank && !hasVerifiedBank) count++;
    if (netPay <= 0) count++;
    return count == 0 ? 1 : count;
  }

  int get scheduledInstructionCount {
    return instructions
        .where(
          (instruction) =>
              instruction.status ==
              EmployeePayrollPaymentInstructionStatus.scheduled,
        )
        .length;
  }

  int get settledInstructionCount {
    return instructions.where((instruction) => instruction.isSettled).length;
  }

  bool get canSchedule => status == EmployeePayrollPaymentStatus.ready;

  bool get canMarkPaid => status == EmployeePayrollPaymentStatus.scheduled;

  int get attentionCount {
    if (status == EmployeePayrollPaymentStatus.paid) return 0;
    if (status == EmployeePayrollPaymentStatus.blocked) return blockingCount;
    return 1;
  }

  String get nextAction {
    if (status == EmployeePayrollPaymentStatus.paid) {
      return 'Payment settled with $paymentReference.';
    }
    if (status == EmployeePayrollPaymentStatus.held) {
      return 'Resolve payment hold before settlement.';
    }
    if (runStatus != EmployeePayrollRunStatus.exported) {
      return 'Export payroll run before payment scheduling.';
    }
    if (requiresVerifiedBank && !hasVerifiedBank) {
      return 'Verify bank account before payment scheduling.';
    }
    if (netPay <= 0) {
      return 'Review zero net pay before payment scheduling.';
    }
    if (status == EmployeePayrollPaymentStatus.scheduled) {
      return 'Confirm payroll payment settlement.';
    }
    return 'Schedule net pay disbursement.';
  }
}

class EmployeePayrollPaymentDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String owner;
  final String note;
  final String reference;
  final DateTime? scheduledFor;

  const EmployeePayrollPaymentDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.owner,
    required this.note,
    required this.reference,
    required this.scheduledFor,
  });

  EmployeePayrollPaymentDraft copyWith({
    String? owner,
    String? note,
    String? reference,
    DateTime? scheduledFor,
  }) {
    return EmployeePayrollPaymentDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      owner: owner ?? this.owner,
      note: note ?? this.note,
      reference: reference ?? this.reference,
      scheduledFor: scheduledFor ?? this.scheduledFor,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (owner.trim().length < 3) {
      errors.add('Payment owner is required');
    }
    if (reference.trim().length < 6) {
      errors.add('Payment reference must be at least 6 characters');
    }
    if (note.trim().length < 12) {
      errors.add('Payment note must be at least 12 characters');
    }
    if (scheduledFor == null) {
      errors.add('Payment schedule date is required');
    }
    return errors;
  }

  bool get isReadyToSchedule => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          owner.trim().length >= 3,
          reference.trim().length >= 6,
          note.trim().length >= 12,
          scheduledFor != null,
        ].where((item) => item).length;
    return completed / 4;
  }
}
