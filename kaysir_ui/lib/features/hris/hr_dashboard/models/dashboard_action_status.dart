enum DashboardActionStatus {
  open('Open'),
  inProgress('In progress'),
  done('Done');

  final String label;

  const DashboardActionStatus(this.label);

  bool get isTerminal => this == DashboardActionStatus.done;
}
