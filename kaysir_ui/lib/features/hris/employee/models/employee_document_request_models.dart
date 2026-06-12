enum EmployeeDocumentRequestType {
  employmentLetter('Employment letter'),
  salaryCertificate('Salary certificate'),
  contractAddendum('Contract addendum'),
  policyAcknowledgement('Policy acknowledgement'),
  visaSupport('Visa support'),
  custom('Custom document');

  final String label;

  const EmployeeDocumentRequestType(this.label);
}

enum EmployeeDocumentDeliveryMethod {
  portal('Portal'),
  pdf('PDF'),
  hardCopy('Hard copy');

  final String label;

  const EmployeeDocumentDeliveryMethod(this.label);
}

enum EmployeeDocumentRequestStatus {
  requested('Requested'),
  reviewing('Reviewing'),
  issued('Issued'),
  acknowledged('Acknowledged'),
  rejected('Rejected');

  final String label;

  const EmployeeDocumentRequestStatus(this.label);
}

class EmployeeDocumentRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeeDocumentRequestType type;
  final String title;
  final String requestedBy;
  final String owner;
  final DateTime requestedAt;
  final DateTime dueDate;
  final String purpose;
  final EmployeeDocumentDeliveryMethod deliveryMethod;
  final bool requiresAcknowledgement;
  final EmployeeDocumentRequestStatus status;
  final DateTime? acknowledgedAt;
  final String correlationId;

  const EmployeeDocumentRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.title,
    required this.requestedBy,
    required this.owner,
    required this.requestedAt,
    required this.dueDate,
    required this.purpose,
    required this.deliveryMethod,
    required this.requiresAcknowledgement,
    required this.status,
    required this.acknowledgedAt,
    this.correlationId = '',
  });

  bool get canReview => status == EmployeeDocumentRequestStatus.requested;

  bool get canIssue {
    return status == EmployeeDocumentRequestStatus.reviewing ||
        status == EmployeeDocumentRequestStatus.requested;
  }

  bool get canAcknowledge {
    return status == EmployeeDocumentRequestStatus.issued &&
        requiresAcknowledgement;
  }

  bool get canReject {
    return status == EmployeeDocumentRequestStatus.requested ||
        status == EmployeeDocumentRequestStatus.reviewing;
  }

  bool get isClosed {
    return status == EmployeeDocumentRequestStatus.acknowledged ||
        status == EmployeeDocumentRequestStatus.rejected ||
        (status == EmployeeDocumentRequestStatus.issued &&
            !requiresAcknowledgement);
  }

  bool isOverdue(DateTime asOfDate) {
    if (isClosed) return false;
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    return dueDate.isBefore(today);
  }

  bool needsAttention(DateTime asOfDate) {
    return isOverdue(asOfDate) ||
        status == EmployeeDocumentRequestStatus.requested ||
        status == EmployeeDocumentRequestStatus.reviewing ||
        canAcknowledge;
  }

  EmployeeDocumentRequest copyWith({
    EmployeeDocumentRequestStatus? status,
    DateTime? acknowledgedAt,
    String? correlationId,
  }) {
    return EmployeeDocumentRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      title: title,
      requestedBy: requestedBy,
      owner: owner,
      requestedAt: requestedAt,
      dueDate: dueDate,
      purpose: purpose,
      deliveryMethod: deliveryMethod,
      requiresAcknowledgement: requiresAcknowledgement,
      status: status ?? this.status,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      correlationId: correlationId ?? this.correlationId,
    );
  }
}

class EmployeeDocumentRequestProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeDocumentRequest> requests;

  const EmployeeDocumentRequestProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.requests,
  });

  EmployeeDocumentRequestProfile copyWith({
    List<EmployeeDocumentRequest>? requests,
  }) {
    return EmployeeDocumentRequestProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      requests: requests ?? this.requests,
    );
  }

  int get requestedCount {
    return requests
        .where(
          (request) =>
              request.status == EmployeeDocumentRequestStatus.requested,
        )
        .length;
  }

  int get reviewingCount {
    return requests
        .where(
          (request) =>
              request.status == EmployeeDocumentRequestStatus.reviewing,
        )
        .length;
  }

  int get issuedPendingAckCount {
    return requests.where((request) => request.canAcknowledge).length;
  }

  int get overdueCount {
    return requests.where((request) => request.isOverdue(asOfDate)).length;
  }

  int get attentionCount {
    return requestedCount +
        reviewingCount +
        issuedPendingAckCount +
        overdueCount;
  }

  String get nextAction {
    if (overdueCount > 0) {
      return 'Resolve $overdueCount overdue document request${overdueCount == 1 ? '' : 's'}.';
    }
    if (issuedPendingAckCount > 0) {
      return 'Acknowledge $issuedPendingAckCount issued document${issuedPendingAckCount == 1 ? '' : 's'}.';
    }
    if (requestedCount > 0) {
      return 'Review $requestedCount new document request${requestedCount == 1 ? '' : 's'}.';
    }
    if (reviewingCount > 0) {
      return 'Issue $reviewingCount document request${reviewingCount == 1 ? '' : 's'} under review.';
    }
    return 'Document requests are current.';
  }
}

class EmployeeDocumentRequestDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeDocumentRequestType type;
  final String title;
  final String requestedBy;
  final String owner;
  final DateTime dueDate;
  final String purpose;
  final EmployeeDocumentDeliveryMethod deliveryMethod;
  final bool requiresAcknowledgement;
  final String correlationId;

  const EmployeeDocumentRequestDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.title,
    required this.requestedBy,
    required this.owner,
    required this.dueDate,
    required this.purpose,
    required this.deliveryMethod,
    required this.requiresAcknowledgement,
    this.correlationId = '',
  });

  EmployeeDocumentRequestDraft copyWith({
    EmployeeDocumentRequestType? type,
    String? title,
    String? requestedBy,
    String? owner,
    DateTime? dueDate,
    String? purpose,
    EmployeeDocumentDeliveryMethod? deliveryMethod,
    bool? requiresAcknowledgement,
    String? correlationId,
  }) {
    return EmployeeDocumentRequestDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      title: title ?? this.title,
      requestedBy: requestedBy ?? this.requestedBy,
      owner: owner ?? this.owner,
      dueDate: dueDate ?? this.dueDate,
      purpose: purpose ?? this.purpose,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      requiresAcknowledgement:
          requiresAcknowledgement ?? this.requiresAcknowledgement,
      correlationId: correlationId ?? this.correlationId,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Title must be at least 4 characters');
    }
    if (requestedBy.trim().length < 3) {
      errors.add('Requester is required');
    }
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    if (dueDate.isBefore(asOfDate)) {
      errors.add('Due date cannot be before today');
    }
    if (purpose.trim().length < 10) {
      errors.add('Purpose must be at least 10 characters');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          title.trim().length >= 4,
          requestedBy.trim().length >= 3,
          owner.trim().length >= 3,
          !dueDate.isBefore(asOfDate),
          purpose.trim().length >= 10,
        ].where((item) => item).length;
    return completed / 5;
  }

  EmployeeDocumentRequest toRequest({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeDocumentRequest(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      title: title.trim(),
      requestedBy: requestedBy.trim(),
      owner: owner.trim(),
      requestedAt: asOfDate,
      dueDate: dueDate,
      purpose: purpose.trim(),
      deliveryMethod: deliveryMethod,
      requiresAcknowledgement: requiresAcknowledgement,
      status: EmployeeDocumentRequestStatus.requested,
      acknowledgedAt: null,
      correlationId: correlationId.trim(),
    );
  }
}
