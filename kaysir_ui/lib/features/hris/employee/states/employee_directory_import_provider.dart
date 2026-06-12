import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_import_models.dart';
import 'employee_directory_provider.dart';

const employeeDirectoryImportTemplateCsv =
    'name,email,phone,position,department,manager,location,joining_date,performance,status\n'
    'Nadia Rahman,nadia.rahman@example.com,+62 812 3456 7777,People Operations Analyst,People Operations,Emma Rodriguez,Jakarta,2026-05-12,4.4,Onboarding\n'
    'Rafi Pratama,rafi.pratama@example.com,+62 812 3456 8888,Backend Engineer,Engineering,David Kim,Bandung,2026-04-20,4.6,Active';

final employeeDirectoryImportCsvProvider = StateProvider<String>((ref) => '');

final employeeDirectoryImportPreviewProvider =
    Provider<EmployeeDirectoryImportPreview>((ref) {
      return EmployeeDirectoryImportPreview.fromCsv(
        rawCsv: ref.watch(employeeDirectoryImportCsvProvider),
        existingMembers: ref.watch(employeeDirectoryMembersProvider),
      );
    });
