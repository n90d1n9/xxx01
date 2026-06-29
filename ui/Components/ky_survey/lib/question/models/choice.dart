
class Choice {
  final String id;
  final String text;
  final String? description;
  final dynamic value;
  final bool? isOther;
  final Map<String, dynamic>? metadata;

  

  Choice({
    required this.id,
    required this.text,
    this.description,
    this.value,
    this.isOther,
    this.metadata,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['id'] as String,
      text: json['text'] as String,
      description: json['description'] as String?,
      value: json['value'],
      isOther: json['isOther'] as bool?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'description': description,
      'value': value,
      'isOther': isOther,
      'metadata': metadata,
    };
  }
}
