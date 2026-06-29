import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_directory_selection_review_models.dart';
import 'employee_directory_provider.dart';
import 'employee_directory_table_provider.dart';

final employeeDirectorySelectionReviewProvider =
    Provider<EmployeeDirectorySelectionReview>((ref) {
      return EmployeeDirectorySelectionReview.fromMembers(
        members: ref.watch(employeeDirectoryTableSelectedRowsProvider),
        asOfDate: ref.watch(employeeDirectoryAsOfDateProvider),
      );
    });
