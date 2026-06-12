import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_table_layout_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_table_layout_provider.dart';

void main() {
  test('employee directory table layout toggles optional columns', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeeDirectoryTableLayoutProvider.notifier,
    );

    expect(
      container
          .read(employeeDirectoryTableLayoutProvider)
          .isVisible(EmployeeDirectoryTableColumn.manager),
      isTrue,
    );

    notifier.toggleColumn(EmployeeDirectoryTableColumn.manager);

    expect(
      container
          .read(employeeDirectoryTableLayoutProvider)
          .isVisible(EmployeeDirectoryTableColumn.manager),
      isFalse,
    );
    expect(
      container
          .read(employeeDirectoryTableLayoutProvider)
          .isVisible(EmployeeDirectoryTableColumn.employee),
      isTrue,
    );

    notifier.toggleColumn(EmployeeDirectoryTableColumn.employee);

    expect(
      container
          .read(employeeDirectoryTableLayoutProvider)
          .isVisible(EmployeeDirectoryTableColumn.employee),
      isTrue,
    );
  });

  test('employee directory table layout changes density and resets', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeeDirectoryTableLayoutProvider.notifier,
    );

    notifier.toggleColumn(EmployeeDirectoryTableColumn.contact);
    notifier.setDensity(EmployeeDirectoryTableDensity.compact);

    var layout = container.read(employeeDirectoryTableLayoutProvider);
    expect(layout.density, EmployeeDirectoryTableDensity.compact);
    expect(layout.isVisible(EmployeeDirectoryTableColumn.contact), isFalse);
    expect(layout.visibleColumnCount, 9);

    notifier.reset();
    layout = container.read(employeeDirectoryTableLayoutProvider);

    expect(layout.density, EmployeeDirectoryTableDensity.comfortable);
    expect(
      layout.visibleColumnCount,
      EmployeeDirectoryTableColumn.values.length,
    );
    expect(layout.isVisible(EmployeeDirectoryTableColumn.contact), isTrue);
  });

  test('employee directory table layout applies captured layout', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final capturedLayout = EmployeeDirectoryTableLayout.defaults()
        .toggleColumn(EmployeeDirectoryTableColumn.manager)
        .copyWith(density: EmployeeDirectoryTableDensity.compact);

    container
        .read(employeeDirectoryTableLayoutProvider.notifier)
        .setLayout(capturedLayout);

    final layout = container.read(employeeDirectoryTableLayoutProvider);

    expect(layout.density, EmployeeDirectoryTableDensity.compact);
    expect(layout.isVisible(EmployeeDirectoryTableColumn.manager), isFalse);
    expect(layout.visibleColumnCount, 9);
  });
}
