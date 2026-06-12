import 'employee_document_request_models.dart';
import 'employee_document_vault_coverage_models.dart';
import 'employee_document_vault_models.dart';

/// Builds document requests from required document vault coverage gaps.
class EmployeeDocumentCoverageRequestFactory {
  static const String correlationPrefix = 'document-vault-coverage:';

  const EmployeeDocumentCoverageRequestFactory._();

  static EmployeeDocumentRequestDraft buildDraft({
    required EmployeeDocumentRequestProfile profile,
    required EmployeeDocumentVaultCoverageItem item,
  }) {
    if (!item.canCreateRequest) {
      throw StateError('${item.label} does not require a document request');
    }

    return EmployeeDocumentRequestDraft(
      employeeId: profile.employeeId,
      employeeName: profile.employeeName,
      asOfDate: profile.asOfDate,
      type: _typeFor(item.category),
      title: '${item.label} request',
      requestedBy: 'People Operations',
      owner: item.owner,
      dueDate: _dueDateFor(profile.asOfDate, item.status),
      purpose: _purposeFor(item),
      deliveryMethod: EmployeeDocumentDeliveryMethod.portal,
      requiresAcknowledgement: _requiresAcknowledgement(item.category),
      correlationId: correlationIdFor(item),
    );
  }

  static String correlationIdFor(EmployeeDocumentVaultCoverageItem item) {
    return '$correlationPrefix${item.requirement.id}';
  }

  static bool isCoverageRequest(EmployeeDocumentRequest request) {
    return categoryForRequest(request) != null;
  }

  static EmployeeDocumentVaultCategory? categoryForRequest(
    EmployeeDocumentRequest request,
  ) {
    return _categoryForRequirementId(_requirementIdFor(request.correlationId));
  }

  static EmployeeDocumentVaultRecord buildVaultRecord({
    required EmployeeDocumentRequest request,
    required String id,
    required DateTime asOfDate,
  }) {
    final category = categoryForRequest(request);
    if (category == null) {
      throw StateError('Document request is not linked to vault coverage');
    }

    final status = vaultStatusForRequest(request);
    return EmployeeDocumentVaultRecord(
      id: id,
      employeeId: request.employeeId,
      employeeName: request.employeeName,
      category: category,
      status: status,
      access: _accessFor(category),
      title: _vaultTitleFor(request),
      owner: request.owner,
      source: 'Document request ${request.id}',
      uploadedAt: asOfDate,
      expiresAt: _expiresAtFor(category: category, asOfDate: asOfDate),
      verifiedAt:
          status == EmployeeDocumentVaultStatus.verified ? asOfDate : null,
      summary: _vaultSummaryFor(request, status),
    );
  }

  static EmployeeDocumentVaultStatus vaultStatusForRequest(
    EmployeeDocumentRequest request,
  ) {
    if (request.status == EmployeeDocumentRequestStatus.acknowledged) {
      return EmployeeDocumentVaultStatus.verified;
    }
    if (request.status == EmployeeDocumentRequestStatus.issued) {
      return request.requiresAcknowledgement
          ? EmployeeDocumentVaultStatus.pendingReview
          : EmployeeDocumentVaultStatus.verified;
    }
    throw StateError(
      'Document request must be issued or acknowledged before vault fulfillment',
    );
  }

  static EmployeeDocumentRequestType _typeFor(
    EmployeeDocumentVaultCategory category,
  ) {
    return switch (category) {
      EmployeeDocumentVaultCategory.contract =>
        EmployeeDocumentRequestType.contractAddendum,
      EmployeeDocumentVaultCategory.compliance =>
        EmployeeDocumentRequestType.policyAcknowledgement,
      EmployeeDocumentVaultCategory.workAuthorization =>
        EmployeeDocumentRequestType.visaSupport,
      EmployeeDocumentVaultCategory.identity ||
      EmployeeDocumentVaultCategory.payrollTax ||
      EmployeeDocumentVaultCategory.benefits ||
      EmployeeDocumentVaultCategory.training ||
      EmployeeDocumentVaultCategory
          .custom => EmployeeDocumentRequestType.custom,
    };
  }

  static String _requirementIdFor(String correlationId) {
    if (!correlationId.startsWith(correlationPrefix)) return '';
    return correlationId.substring(correlationPrefix.length);
  }

  static EmployeeDocumentVaultCategory? _categoryForRequirementId(
    String requirementId,
  ) {
    return switch (requirementId) {
      'identity' => EmployeeDocumentVaultCategory.identity,
      'contract' => EmployeeDocumentVaultCategory.contract,
      'payroll-tax' => EmployeeDocumentVaultCategory.payrollTax,
      'compliance' => EmployeeDocumentVaultCategory.compliance,
      'work-authorization' => EmployeeDocumentVaultCategory.workAuthorization,
      _ => null,
    };
  }

  static EmployeeDocumentVaultAccess _accessFor(
    EmployeeDocumentVaultCategory category,
  ) {
    return switch (category) {
      EmployeeDocumentVaultCategory.identity ||
      EmployeeDocumentVaultCategory
          .compliance => EmployeeDocumentVaultAccess.employeeVisible,
      EmployeeDocumentVaultCategory.contract ||
      EmployeeDocumentVaultCategory
          .payrollTax => EmployeeDocumentVaultAccess.hrOnly,
      EmployeeDocumentVaultCategory.workAuthorization =>
        EmployeeDocumentVaultAccess.restricted,
      EmployeeDocumentVaultCategory.benefits ||
      EmployeeDocumentVaultCategory.training ||
      EmployeeDocumentVaultCategory
          .custom => EmployeeDocumentVaultAccess.hrOnly,
    };
  }

  static DateTime? _expiresAtFor({
    required EmployeeDocumentVaultCategory category,
    required DateTime asOfDate,
  }) {
    return switch (category) {
      EmployeeDocumentVaultCategory.contract => null,
      EmployeeDocumentVaultCategory.identity => asOfDate.add(
        const Duration(days: 1095),
      ),
      EmployeeDocumentVaultCategory.payrollTax ||
      EmployeeDocumentVaultCategory.compliance ||
      EmployeeDocumentVaultCategory.workAuthorization ||
      EmployeeDocumentVaultCategory.benefits ||
      EmployeeDocumentVaultCategory
          .training => asOfDate.add(const Duration(days: 365)),
      EmployeeDocumentVaultCategory.custom => null,
    };
  }

  static String _vaultTitleFor(EmployeeDocumentRequest request) {
    const suffix = ' request';
    final title = request.title.trim();
    if (title.toLowerCase().endsWith(suffix)) {
      return title.substring(0, title.length - suffix.length);
    }
    return title;
  }

  static String _vaultSummaryFor(
    EmployeeDocumentRequest request,
    EmployeeDocumentVaultStatus status,
  ) {
    final result =
        status == EmployeeDocumentVaultStatus.verified
            ? 'Verified'
            : 'Pending review';
    return '${request.purpose.trim()} $result from document request ${request.id}.';
  }

  static DateTime _dueDateFor(
    DateTime asOfDate,
    EmployeeDocumentVaultCoverageStatus status,
  ) {
    final days = switch (status) {
      EmployeeDocumentVaultCoverageStatus.expired => 3,
      EmployeeDocumentVaultCoverageStatus.expiringSoon => 7,
      EmployeeDocumentVaultCoverageStatus.missing ||
      EmployeeDocumentVaultCoverageStatus.uploadNeeded => 5,
      EmployeeDocumentVaultCoverageStatus.reviewNeeded ||
      EmployeeDocumentVaultCoverageStatus.complete => 7,
    };
    return asOfDate.add(Duration(days: days));
  }

  static bool _requiresAcknowledgement(EmployeeDocumentVaultCategory category) {
    return category == EmployeeDocumentVaultCategory.compliance ||
        category == EmployeeDocumentVaultCategory.contract;
  }

  static String _purposeFor(EmployeeDocumentVaultCoverageItem item) {
    final label = item.label.toLowerCase();
    return switch (item.status) {
      EmployeeDocumentVaultCoverageStatus.expired =>
        'Replace expired $label for required document vault coverage.',
      EmployeeDocumentVaultCoverageStatus.expiringSoon =>
        'Collect renewal evidence for $label before expiry.',
      EmployeeDocumentVaultCoverageStatus.uploadNeeded =>
        'Request updated $label for required document vault coverage.',
      EmployeeDocumentVaultCoverageStatus.missing =>
        'Collect $label for required document vault coverage.',
      EmployeeDocumentVaultCoverageStatus.reviewNeeded ||
      EmployeeDocumentVaultCoverageStatus
          .complete => 'Maintain $label for required document vault coverage.',
    };
  }
}
