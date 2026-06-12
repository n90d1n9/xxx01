enum EmployeeDirectoryActivityType {
  created,
  updated,
  removed,
  bulkStatusChanged,
  bulkProfileUpdated,
  exported,
  imported,
  actionUpdated,
}

extension EmployeeDirectoryActivityTypeLabel on EmployeeDirectoryActivityType {
  String get label {
    return switch (this) {
      EmployeeDirectoryActivityType.created => 'Created profile',
      EmployeeDirectoryActivityType.updated => 'Updated profile',
      EmployeeDirectoryActivityType.removed => 'Removed profile',
      EmployeeDirectoryActivityType.bulkStatusChanged => 'Bulk status update',
      EmployeeDirectoryActivityType.bulkProfileUpdated => 'Bulk profile update',
      EmployeeDirectoryActivityType.exported => 'Exported rows',
      EmployeeDirectoryActivityType.imported => 'Imported rows',
      EmployeeDirectoryActivityType.actionUpdated => 'Action queue',
    };
  }
}

class EmployeeDirectoryActivityEvent {
  final String id;
  final EmployeeDirectoryActivityType type;
  final String title;
  final String detail;
  final String actor;
  final DateTime occurredAt;
  final int affectedCount;
  final String? employeeId;
  final String? employeeName;

  const EmployeeDirectoryActivityEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.detail,
    required this.actor,
    required this.occurredAt,
    required this.affectedCount,
    this.employeeId,
    this.employeeName,
  });
}

class EmployeeDirectoryActivitySummary {
  final int totalCount;
  final int createCount;
  final int updateCount;
  final int removalCount;
  final int exportCount;
  final int importCount;
  final int bulkActionCount;
  final int queueActionCount;

  const EmployeeDirectoryActivitySummary({
    required this.totalCount,
    required this.createCount,
    required this.updateCount,
    required this.removalCount,
    required this.exportCount,
    required this.importCount,
    required this.bulkActionCount,
    required this.queueActionCount,
  });

  factory EmployeeDirectoryActivitySummary.fromEvents(
    List<EmployeeDirectoryActivityEvent> events,
  ) {
    return EmployeeDirectoryActivitySummary(
      totalCount: events.length,
      createCount:
          events
              .where(
                (event) => event.type == EmployeeDirectoryActivityType.created,
              )
              .length,
      updateCount:
          events
              .where(
                (event) => event.type == EmployeeDirectoryActivityType.updated,
              )
              .length,
      removalCount:
          events
              .where(
                (event) => event.type == EmployeeDirectoryActivityType.removed,
              )
              .length,
      exportCount:
          events
              .where(
                (event) => event.type == EmployeeDirectoryActivityType.exported,
              )
              .length,
      importCount:
          events
              .where(
                (event) => event.type == EmployeeDirectoryActivityType.imported,
              )
              .length,
      bulkActionCount:
          events
              .where(
                (event) =>
                    event.type ==
                        EmployeeDirectoryActivityType.bulkStatusChanged ||
                    event.type ==
                        EmployeeDirectoryActivityType.bulkProfileUpdated,
              )
              .length,
      queueActionCount:
          events
              .where(
                (event) =>
                    event.type == EmployeeDirectoryActivityType.actionUpdated,
              )
              .length,
    );
  }
}
