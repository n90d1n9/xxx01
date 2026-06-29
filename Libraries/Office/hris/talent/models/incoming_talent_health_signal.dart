enum IncomingTalentHealthStatus {
  strong('Strong'),
  watch('Watch'),
  critical('Critical');

  final String label;

  const IncomingTalentHealthStatus(this.label);
}

enum IncomingTalentHealthSignalSeverity {
  stable('Stable'),
  watch('Watch'),
  critical('Critical');

  final String label;

  const IncomingTalentHealthSignalSeverity(this.label);
}

class IncomingTalentHealthSignal {
  final String label;
  final String value;
  final String detail;
  final IncomingTalentHealthSignalSeverity severity;

  const IncomingTalentHealthSignal({
    required this.label,
    required this.value,
    required this.detail,
    required this.severity,
  });
}
