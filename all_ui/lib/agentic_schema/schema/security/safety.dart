class Safety {
  final bool? contentFiltering;
  final bool? piiDetection;
  final double? toxicityThreshold;
  final List<String>? allowedTopics;
  final List<String>? blockedTopics;
  final List<String>? moderationRules;

  Safety({
    this.contentFiltering = true,
    this.piiDetection = false,
    this.toxicityThreshold = 0.9,
    this.allowedTopics,
    this.blockedTopics,
    this.moderationRules,
  });

  factory Safety.fromJson(Map<String, dynamic> json) {
    return Safety(
      contentFiltering: json['contentFiltering'] as bool?,
      piiDetection: json['piiDetection'] as bool?,
      toxicityThreshold: json['toxicityThreshold'] != null
          ? (json['toxicityThreshold'] as num).toDouble()
          : null,
      allowedTopics: json['allowedTopics'] != null
          ? List<String>.from(json['allowedTopics'] as List)
          : null,
      blockedTopics: json['blockedTopics'] != null
          ? List<String>.from(json['blockedTopics'] as List)
          : null,
      moderationRules: json['moderationRules'] != null
          ? List<String>.from(json['moderationRules'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (contentFiltering != null) 'contentFiltering': contentFiltering,
      if (piiDetection != null) 'piiDetection': piiDetection,
      if (toxicityThreshold != null) 'toxicityThreshold': toxicityThreshold,
      if (allowedTopics != null) 'allowedTopics': allowedTopics,
      if (blockedTopics != null) 'blockedTopics': blockedTopics,
      if (moderationRules != null) 'moderationRules': moderationRules,
    };
  }
}
