import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_directory_bulk_profile_update_preview_models.dart';
import 'employee_directory_bulk_profile_update_provider.dart';
import 'employee_directory_table_provider.dart';

final employeeDirectoryBulkProfileUpdatePreviewProvider =
    Provider<EmployeeDirectoryBulkProfileUpdatePreview>((ref) {
      return EmployeeDirectoryBulkProfileUpdatePreview.fromDraft(
        members: ref.watch(employeeDirectoryTableSelectedRowsProvider),
        draft: ref.watch(employeeDirectoryBulkProfileUpdateDraftProvider),
      );
    });
