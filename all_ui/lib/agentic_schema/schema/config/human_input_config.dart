class HumanInputConfig {
  final Map<String, dynamic>? formSchema;
  final int? timeout;
  final List<String>? notificationChannels;

  HumanInputConfig({
    this.formSchema,
    this.timeout = 300000, // 5 minutes
    this.notificationChannels,
  });

  factory HumanInputConfig.fromJson(Map<String, dynamic> json) {
    return HumanInputConfig(
      formSchema: json['formSchema'] != null
          ? Map<String, dynamic>.from(json['formSchema'] as Map)
          : null,
      timeout: json['timeout'] as int?,
      notificationChannels: json['notificationChannels'] != null
          ? List<String>.from(json['notificationChannels'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (formSchema != null) 'formSchema': formSchema,
      if (timeout != null) 'timeout': timeout,
      if (notificationChannels != null)
        'notificationChannels': notificationChannels,
    };
  }
}
