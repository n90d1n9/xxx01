import 'guardrail_result.dart';
import 'guardrail_rule.dart';
import 'guardrail_type.dart';
import 'guardrail_violation.dart';

class GuardrailExecutor {
  final List<GuardrailRule> rules;

  GuardrailExecutor(this.rules);

  Future<GuardrailResult> check(String input) async {
    final violations = <GuardrailViolation>[];
    String currentInput = input;
    String? sanitizedInput;

    for (final rule in rules.where((r) => r.enabled)) {
      final violation = await _checkRule(rule, currentInput);

      if (violation != null) {
        violations.add(violation);

        switch (rule.action) {
          case RuleAction.block:
            return GuardrailResult.fail(violations); // immediate fail

          case RuleAction.sanitize:
            final newSanitized = await _sanitizeInput(currentInput, rule);
            sanitizedInput = sanitizedInput == null
                ? newSanitized
                : newSanitized; // or chain sanitizations
            currentInput = newSanitized;
            break;

          case RuleAction.warn:
          case RuleAction.log:
            // continue
            break;
          case RuleAction.redact:
            // TODO: Handle this case.
            throw UnimplementedError();
          case RuleAction.notify:
            // TODO: Handle this case.
            throw UnimplementedError();
        }
      }
    }

    return violations.isEmpty
        ? GuardrailResult.pass()
        : GuardrailResult(
            passed: true, // no block → passed
            violations: violations,
            sanitizedInput: sanitizedInput,
          );
  }

  Future<GuardrailViolation?> _checkRule(
    GuardrailRule rule,
    String input,
  ) async {
    switch (rule.type) {
      case GuardrailType.piiDetection:
        return await _checkPII(rule, input);
      case GuardrailType.jailbreakDetection:
        return await _checkJailbreak(rule, input);
      case GuardrailType.hallucinationDetection:
        return await _checkHallucination(rule, input);
      case GuardrailType.toxicityDetection:
        return await _checkToxicity(rule, input);
      case GuardrailType.biasDetection:
        return await _checkBias(rule, input);
      case GuardrailType.promptInjection:
        return await _checkPromptInjection(rule, input);
      case GuardrailType.sensitiveTopics:
        return await _checkSensitiveTopics(rule, input);
      case GuardrailType.contentModeration:
        return await _checkContentModeration(rule, input);
      case GuardrailType.factualAccuracy:
        return await _checkFactualAccuracy(rule, input);
      case GuardrailType.customRegex:
        return await _checkCustomRegex(rule, input);
      case GuardrailType.customKeywords:
        return await _checkCustomKeywords(rule, input);
      case GuardrailType.customML:
        return await _checkCustomML(rule, input);
    }
  }

  Future<GuardrailViolation?> _checkPII(
    GuardrailRule rule,
    String input,
  ) async {
    // PII patterns
    final patterns = {
      'email': RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      'phone': RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'),
      'ssn': RegExp(r'\b\d{3}-\d{2}-\d{4}\b'),
      'credit_card': RegExp(r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b'),
      'ip_address': RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'),
    };

    final detected = <String, List<String>>{};

    for (final entry in patterns.entries) {
      final matches = entry.value.allMatches(input);
      if (matches.isNotEmpty) {
        detected[entry.key] = matches.map((m) => m.group(0)!).toList();
      }
    }

    if (detected.isNotEmpty) {
      return GuardrailViolation(
        ruleId: rule.id,
        ruleName: rule.name,
        type: rule.type,
        severity: rule.severity,
        message: 'PII detected in input',
        confidence: 0.95,
        details: {'detected': detected},
        action: rule.action,
      );
    }

    return null;
  }

  Future<GuardrailViolation?> _checkJailbreak(
    GuardrailRule rule,
    String input,
  ) async {
    // Common jailbreak patterns
    final jailbreakPatterns = [
      r'ignore previous instructions',
      r'disregard.*rules',
      r'pretend you are',
      r'act as if',
      r'you are now',
      r'forget.*constraints',
      r'bypass.*restrictions',
      r'override.*safety',
      r'developer mode',
      r'admin mode',
      r'sudo mode',
      r'god mode',
    ];

    final lowerInput = input.toLowerCase();

    for (final pattern in jailbreakPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lowerInput)) {
        return GuardrailViolation(
          ruleId: rule.id,
          ruleName: rule.name,
          type: rule.type,
          severity: GuardrailSeverity.critical,
          message: 'Potential jailbreak attempt detected',
          confidence: 0.85,
          details: {'pattern': pattern},
          action: rule.action,
        );
      }
    }

    return null;
  }

  Future<GuardrailViolation?> _checkHallucination(
    GuardrailRule rule,
    String input,
  ) async {
    // Check for hallucination indicators
    final indicators = [
      r'i think',
      r'probably',
      r'might be',
      r'could be',
      r'not sure',
      r'uncertain',
      r'guessing',
    ];

    final context = rule.config['context'] as String?;
    if (context == null) return null;

    // Check if output matches context (simplified)
    final uncertainCount = indicators
        .where(
          (pattern) => RegExp(pattern, caseSensitive: false).hasMatch(input),
        )
        .length;

    if (uncertainCount >= 2) {
      return GuardrailViolation(
        ruleId: rule.id,
        ruleName: rule.name,
        type: rule.type,
        severity: rule.severity,
        message: 'High uncertainty detected - potential hallucination',
        confidence: 0.7,
        details: {'uncertain_phrases': uncertainCount},
        action: rule.action,
      );
    }

    return null;
  }

  Future<GuardrailViolation?> _checkToxicity(
    GuardrailRule rule,
    String input,
  ) async {
    // Toxicity keywords (simplified)
    final toxicKeywords =
        rule.config['keywords'] as List<String>? ??
        ['hate', 'kill', 'violence', 'abuse', 'threat'];

    final lowerInput = input.toLowerCase();
    final foundKeywords = toxicKeywords
        .where((kw) => lowerInput.contains(kw))
        .toList();

    if (foundKeywords.isNotEmpty) {
      return GuardrailViolation(
        ruleId: rule.id,
        ruleName: rule.name,
        type: rule.type,
        severity: rule.severity,
        message: 'Toxic content detected',
        confidence: 0.8,
        details: {'keywords': foundKeywords},
        action: rule.action,
      );
    }

    return null;
  }

  Future<GuardrailViolation?> _checkBias(
    GuardrailRule rule,
    String input,
  ) async {
    // Check for biased language
    final biasedTerms = rule.config['biased_terms'] as List<String>? ?? [];

    final lowerInput = input.toLowerCase();
    final foundTerms = biasedTerms
        .where((term) => lowerInput.contains(term))
        .toList();

    if (foundTerms.isNotEmpty) {
      return GuardrailViolation(
        ruleId: rule.id,
        ruleName: rule.name,
        type: rule.type,
        severity: rule.severity,
        message: 'Potentially biased language detected',
        confidence: 0.75,
        details: {'terms': foundTerms},
        action: rule.action,
      );
    }

    return null;
  }

  Future<GuardrailViolation?> _checkPromptInjection(
    GuardrailRule rule,
    String input,
  ) async {
    // Prompt injection patterns
    final injectionPatterns = [
      r'system:',
      r'assistant:',
      r'user:',
      r'\[INST\]',
      r'\[/INST\]',
      r'<\|im_start\|>',
      r'<\|im_end\|>',
    ];

    for (final pattern in injectionPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return GuardrailViolation(
          ruleId: rule.id,
          ruleName: rule.name,
          type: rule.type,
          severity: GuardrailSeverity.high,
          message: 'Prompt injection attempt detected',
          confidence: 0.9,
          details: {'pattern': pattern},
          action: rule.action,
        );
      }
    }

    return null;
  }

  Future<GuardrailViolation?> _checkSensitiveTopics(
    GuardrailRule rule,
    String input,
  ) async {
    final sensitiveTopics = rule.config['topics'] as List<String>? ?? [];

    final lowerInput = input.toLowerCase();
    final matchedTopics = sensitiveTopics
        .where((topic) => lowerInput.contains(topic.toLowerCase()))
        .toList();

    if (matchedTopics.isNotEmpty) {
      return GuardrailViolation(
        ruleId: rule.id,
        ruleName: rule.name,
        type: rule.type,
        severity: rule.severity,
        message: 'Sensitive topic detected',
        confidence: 0.8,
        details: {'topics': matchedTopics},
        action: rule.action,
      );
    }

    return null;
  }

  Future<GuardrailViolation?> _checkContentModeration(
    GuardrailRule rule,
    String input,
  ) async {
    // Content moderation categories
    final categories =
        rule.config['categories'] as List<String>? ??
        ['violence', 'sexual', 'hate', 'self-harm'];

    // Simplified check (in production, use ML model)
    final lowerInput = input.toLowerCase();

    for (final category in categories) {
      // Basic keyword matching per category
      final keywords = _getKeywordsForCategory(category);
      if (keywords.any((kw) => lowerInput.contains(kw))) {
        return GuardrailViolation(
          ruleId: rule.id,
          ruleName: rule.name,
          type: rule.type,
          severity: rule.severity,
          message: 'Content moderation flag: $category',
          confidence: 0.7,
          details: {'category': category},
          action: rule.action,
        );
      }
    }

    return null;
  }

  Future<GuardrailViolation?> _checkFactualAccuracy(
    GuardrailRule rule,
    String input,
  ) async {
    // Check against knowledge base or fact-checking service
    final knowledgeBase =
        rule.config['knowledge_base'] as Map<String, dynamic>?;

    if (knowledgeBase == null) return null;

    // Simplified fact checking
    // In production, use external fact-checking API or knowledge graph

    return null;
  }

  Future<GuardrailViolation?> _checkCustomRegex(
    GuardrailRule rule,
    String input,
  ) async {
    final patterns = rule.config['patterns'] as List<String>? ?? [];

    for (final pattern in patterns) {
      try {
        final regex = RegExp(
          pattern,
          caseSensitive: rule.config['case_sensitive'] ?? false,
        );
        if (regex.hasMatch(input)) {
          return GuardrailViolation(
            ruleId: rule.id,
            ruleName: rule.name,
            type: rule.type,
            severity: rule.severity,
            message: 'Custom regex pattern matched',
            confidence: 1.0,
            details: {'pattern': pattern},
            action: rule.action,
          );
        }
      } catch (e) {
        // Invalid regex pattern
        continue;
      }
    }

    return null;
  }

  Future<GuardrailViolation?> _checkCustomKeywords(
    GuardrailRule rule,
    String input,
  ) async {
    final keywords = rule.config['keywords'] as List<String>? ?? [];
    final caseSensitive = rule.config['case_sensitive'] as bool? ?? false;

    final searchInput = caseSensitive ? input : input.toLowerCase();
    final foundKeywords = keywords.where((kw) {
      final searchKeyword = caseSensitive ? kw : kw.toLowerCase();
      return searchInput.contains(searchKeyword);
    }).toList();

    if (foundKeywords.isNotEmpty) {
      return GuardrailViolation(
        ruleId: rule.id,
        ruleName: rule.name,
        type: rule.type,
        severity: rule.severity,
        message: 'Custom keywords detected',
        confidence: 1.0,
        details: {'keywords': foundKeywords},
        action: rule.action,
      );
    }

    return null;
  }

  Future<GuardrailViolation?> _checkCustomML(
    GuardrailRule rule,
    String input,
  ) async {
    // Custom ML model check
    // In production, call external ML service
    final modelEndpoint = rule.config['model_endpoint'] as String?;

    if (modelEndpoint == null) return null;

    // Simulate ML API call
    await Future.delayed(const Duration(milliseconds: 100));

    return null;
  }

  List<String> _getKeywordsForCategory(String category) {
    final categoryKeywords = {
      'violence': ['kill', 'murder', 'attack', 'assault', 'weapon'],
      'sexual': ['explicit', 'nsfw', 'adult'],
      'hate': ['hate', 'discriminate', 'racist', 'sexist'],
      'self-harm': ['suicide', 'self-harm', 'cutting'],
    };

    return categoryKeywords[category.toLowerCase()] ?? [];
  }

  Future<String> _sanitizeInput(String input, GuardrailRule rule) async {
    switch (rule.type) {
      case GuardrailType.piiDetection:
        return _sanitizePII(input);
      case GuardrailType.toxicityDetection:
        return _sanitizeToxicity(input, rule);
      default:
        return input;
    }
  }

  String _sanitizePII(String input) {
    var sanitized = input;

    // Redact email
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      (match) => '[EMAIL_REDACTED]',
    );

    // Redact phone
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'),
      (match) => '[PHONE_REDACTED]',
    );

    // Redact SSN
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\b\d{3}-\d{2}-\d{4}\b'),
      (match) => '[SSN_REDACTED]',
    );

    // Redact credit card
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b'),
      (match) => '[CARD_REDACTED]',
    );

    return sanitized;
  }

  String _sanitizeToxicity(String input, GuardrailRule rule) {
    var sanitized = input;
    final keywords = rule.config['keywords'] as List<String>? ?? [];

    for (final keyword in keywords) {
      sanitized = sanitized.replaceAll(
        RegExp(keyword, caseSensitive: false),
        '[REDACTED]',
      );
    }

    return sanitized;
  }
}
