void exampleUsage() {
  final mahramNotifier = ref.read(mahramProvider.notifier);
  
  // Validate family relationships
  await mahramNotifier.validateFamilyRelationships(familyMembers);
  
  // Check if two specific members are mahram
  final areMahram = mahramNotifier.areMahram('person1', 'person2');
  
  // Get all mahram relationships for a person
  final mahramRelations = mahramNotifier.getMahramForPerson('person1');
  
  // Set different calculation method
  mahramNotifier.setCalculationMethod('Hanafi');
}