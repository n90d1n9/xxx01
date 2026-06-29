import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_document_vault_coverage_models.dart';
import 'employee_document_vault_provider.dart';

/// Builds required document coverage for one employee's document vault.
final employeeDocumentVaultCoverageProvider = Provider.family<
  EmployeeDocumentVaultCoverageProfile?,
  String
>((ref, employeeId) {
  final profile = ref.watch(employeeDocumentVaultProfileProvider(employeeId));
  if (profile == null) return null;

  return EmployeeDocumentVaultCoverageProfile.fromVault(profile);
});
