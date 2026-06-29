import 'package:flutter/material.dart';

import '../../models/employee_document_request_models.dart';

Color employeeDocumentRequestStatusColor(EmployeeDocumentRequestStatus status) {
  return switch (status) {
    EmployeeDocumentRequestStatus.requested => const Color(0xFF2563EB),
    EmployeeDocumentRequestStatus.reviewing => const Color(0xFFB45309),
    EmployeeDocumentRequestStatus.issued => const Color(0xFF7C3AED),
    EmployeeDocumentRequestStatus.acknowledged => const Color(0xFF15803D),
    EmployeeDocumentRequestStatus.rejected => const Color(0xFFB91C1C),
  };
}

IconData employeeDocumentRequestTypeIcon(EmployeeDocumentRequestType type) {
  return switch (type) {
    EmployeeDocumentRequestType.employmentLetter => Icons.description_outlined,
    EmployeeDocumentRequestType.salaryCertificate => Icons.payments_outlined,
    EmployeeDocumentRequestType.contractAddendum => Icons.article_outlined,
    EmployeeDocumentRequestType.policyAcknowledgement =>
      Icons.rule_folder_outlined,
    EmployeeDocumentRequestType.visaSupport => Icons.badge_outlined,
    EmployeeDocumentRequestType.custom => Icons.note_add_outlined,
  };
}

IconData employeeDocumentDeliveryIcon(EmployeeDocumentDeliveryMethod method) {
  return switch (method) {
    EmployeeDocumentDeliveryMethod.portal => Icons.cloud_done_outlined,
    EmployeeDocumentDeliveryMethod.pdf => Icons.picture_as_pdf_outlined,
    EmployeeDocumentDeliveryMethod.hardCopy => Icons.local_printshop_outlined,
  };
}
