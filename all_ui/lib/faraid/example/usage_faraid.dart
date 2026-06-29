void exampleUsage() {
  final notifier = FamilyTreeNotifier();

  // Set different calculation methods
  notifier.setCalculationMethod('Hanafi');
  notifier.setCalculationMethod('Shafii');
  notifier.setCalculationMethod('Maliki');
  notifier.setCalculationMethod('Hanbali');

  // The DRL engine will automatically apply the appropriate rules
  // based on the activation groups and conditions
}
