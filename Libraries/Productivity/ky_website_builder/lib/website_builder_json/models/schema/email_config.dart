class EmailConfig {
  final String to;
  final String? from;
  final String subject;
  final String? template;
  final Map<String, dynamic>? templateData;

  EmailConfig({
    required this.to,
    this.from,
    required this.subject,
    this.template,
    this.templateData,
  });

  factory EmailConfig.fromJson(Map<String, dynamic> json) {
    return EmailConfig(
      to: json['to'] as String,
      from: json['from'] as String?,
      subject: json['subject'] as String,
      template: json['template'] as String?,
      templateData: json['templateData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'to': to,
    if (from != null) 'from': from,
    'subject': subject,
    if (template != null) 'template': template,
    if (templateData != null) 'templateData': templateData,
  };
}
