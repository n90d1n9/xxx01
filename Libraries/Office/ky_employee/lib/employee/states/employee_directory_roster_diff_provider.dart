import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_directory_roster_diff_models.dart';
import 'employee_directory_roster_publish_provider.dart';

/// Compares the latest published roster packet against the previous release.
final employeeDirectoryRosterDiffReviewProvider =
    Provider<EmployeeDirectoryRosterDiffReview>((ref) {
      return EmployeeDirectoryRosterDiffReview.fromReleases(
        ref.watch(employeeDirectoryRosterReleasesProvider),
      );
    });
