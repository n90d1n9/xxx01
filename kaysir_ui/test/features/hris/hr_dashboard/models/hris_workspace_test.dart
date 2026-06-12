import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';

void main() {
  test(
    'HRIS workspace registry exposes unique canonical workspace metadata',
    () {
      expect(hrisWorkspaces, hasLength(17));
      expect(
        hrisWorkspaces.map((workspace) => workspace.id).toSet(),
        hasLength(17),
      );
      expect(
        hrisWorkspaces.map((workspace) => workspace.path).toSet(),
        hasLength(17),
      );
      expect(
        hrisWorkspaces.where(
          (workspace) =>
              workspace.category == DashboardWorkspaceCategory.strategic,
        ),
        hasLength(10),
      );
      expect(
        hrisWorkspaces.where(
          (workspace) =>
              workspace.category == DashboardWorkspaceCategory.operational,
        ),
        hasLength(7),
      );
      expect(
        hrisWorkspaceById(HrisWorkspaceId.companyManagement).path,
        '/hris-company-management',
      );
      expect(hrisWorkspaceById(HrisWorkspaceId.holidays).path, '/holidays');
      expect(
        hrisWorkspaceById(HrisWorkspaceId.employeeSelfService).path,
        '/employee-self-service',
      );
    },
  );
}
