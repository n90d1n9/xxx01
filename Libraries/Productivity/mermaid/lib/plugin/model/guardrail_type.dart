enum GuardrailType {
  piiDetection,
  jailbreakDetection,
  hallucinationDetection,
  toxicityDetection,
  biasDetection,
  promptInjection,
  sensitiveTopics,
  contentModeration,
  factualAccuracy,
  customRegex,
  customKeywords,
  customML;

  // Optional: helper for display
  String get displayName =>
      name.replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2').toUpperCase();
}

enum GuardrailSeverity { low, medium, high, critical }
