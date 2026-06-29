import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_document_request_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_document_request_coverage_models.dart';
import '../models/employee_document_request_models.dart';
import '../models/employee_document_vault_coverage_models.dart';
import 'employee_directory_provider.dart';

/// Stores employee-facing HR document requests for one employee.
final employeeDocumentRequestProfileProvider = StateNotifierProvider.family<
  EmployeeDocumentRequestProfileNotifier,
  EmployeeDocumentRequestProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeDocumentRequestProfileNotifier(null);
  }

  return EmployeeDocumentRequestProfileNotifier(
    buildEmployeeDocumentRequestProfile(member: member, asOfDate: asOfDate),
  );
});

/// Stores the editable manual document request draft for one employee.
final employeeDocumentRequestDraftProvider = StateNotifierProvider.family<
  EmployeeDocumentRequestDraftNotifier,
  EmployeeDocumentRequestDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeDocumentRequestDraftNotifier(null);
  }

  return EmployeeDocumentRequestDraftNotifier(
    buildEmployeeDocumentRequestDraft(member: member, asOfDate: asOfDate),
  );
});

/// Mutates local employee document request records and linked coverage requests.
class EmployeeDocumentRequestProfileNotifier
    extends StateNotifier<EmployeeDocumentRequestProfile?> {
  EmployeeDocumentRequestProfileNotifier(super.state);

  EmployeeDocumentRequest submitDraft(EmployeeDocumentRequestDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee document request profile is unavailable');
    }
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final request = draft.toRequest(id: _nextRequestId(profile));
    state = profile.copyWith(requests: [request, ...profile.requests]);
    return request;
  }

  EmployeeDocumentRequest submitCoverageRequest(
    EmployeeDocumentVaultCoverageItem item,
  ) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee document request profile is unavailable');
    }

    final correlationId =
        EmployeeDocumentCoverageRequestFactory.correlationIdFor(item);
    if (_hasOpenCorrelation(profile, correlationId)) {
      throw StateError('Document request already exists for ${item.label}');
    }

    final draft = EmployeeDocumentCoverageRequestFactory.buildDraft(
      profile: profile,
      item: item,
    );
    return submitDraft(draft);
  }

  void markReviewing(String requestId) {
    _updateRequest(requestId, (request) {
      if (!request.canReview) return request;
      return request.copyWith(status: EmployeeDocumentRequestStatus.reviewing);
    });
  }

  void issueRequest(String requestId) {
    _updateRequest(requestId, (request) {
      if (!request.canIssue) return request;
      return request.copyWith(status: EmployeeDocumentRequestStatus.issued);
    });
  }

  void acknowledgeRequest(String requestId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      requests:
          profile.requests.map((request) {
            if (request.id != requestId || !request.canAcknowledge) {
              return request;
            }
            return request.copyWith(
              status: EmployeeDocumentRequestStatus.acknowledged,
              acknowledgedAt: profile.asOfDate,
            );
          }).toList(),
    );
  }

  void rejectRequest(String requestId) {
    _updateRequest(requestId, (request) {
      if (!request.canReject) return request;
      return request.copyWith(status: EmployeeDocumentRequestStatus.rejected);
    });
  }

  void _updateRequest(
    String requestId,
    EmployeeDocumentRequest Function(EmployeeDocumentRequest request) update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      requests:
          profile.requests.map((request) {
            if (request.id != requestId) return request;
            return update(request);
          }).toList(),
    );
  }

  String _nextRequestId(EmployeeDocumentRequestProfile profile) {
    var index = profile.requests.length + 1;
    while (true) {
      final id =
          'EDR-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.requests.any((request) => request.id == id)) {
        return id;
      }
      index++;
    }
  }

  bool _hasOpenCorrelation(
    EmployeeDocumentRequestProfile profile,
    String correlationId,
  ) {
    return profile.requests.any(
      (request) => request.correlationId == correlationId && !request.isClosed,
    );
  }
}

/// Mutates the editable manual document request draft fields.
class EmployeeDocumentRequestDraftNotifier
    extends StateNotifier<EmployeeDocumentRequestDraft?> {
  final EmployeeDocumentRequestDraft? _initialDraft;

  EmployeeDocumentRequestDraftNotifier(super.state) : _initialDraft = state;

  void setType(EmployeeDocumentRequestType value) {
    state = state?.copyWith(type: value);
  }

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setRequestedBy(String value) {
    state = state?.copyWith(requestedBy: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setDueDate(DateTime value) {
    state = state?.copyWith(
      dueDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setPurpose(String value) {
    state = state?.copyWith(purpose: value);
  }

  void setDeliveryMethod(EmployeeDocumentDeliveryMethod value) {
    state = state?.copyWith(deliveryMethod: value);
  }

  void setRequiresAcknowledgement(bool value) {
    state = state?.copyWith(requiresAcknowledgement: value);
  }

  void reset() {
    state = _initialDraft;
  }
}

EmployeeDirectoryMember? _findMember(
  List<EmployeeDirectoryMember> members,
  String employeeId,
) {
  for (final member in members) {
    if (member.id == employeeId) {
      return member;
    }
  }
  return null;
}
