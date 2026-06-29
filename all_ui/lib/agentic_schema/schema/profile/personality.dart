import '../example/example_conversion.dart';

class Personality {
  final String? tone;
  final String? style;
  final List<String>? guidelines;
  final List<ExampleConversation>? exampleConversations;

  Personality({
    this.tone,
    this.style,
    this.guidelines,
    this.exampleConversations,
  });

  factory Personality.fromJson(Map<String, dynamic> json) {
    return Personality(
      tone: json['tone'] as String?,
      style: json['style'] as String?,
      guidelines: json['guidelines'] != null
          ? List<String>.from(json['guidelines'] as List)
          : null,
      exampleConversations: json['exampleConversations'] != null
          ? (json['exampleConversations'] as List)
                .map(
                  (e) =>
                      ExampleConversation.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (tone != null) 'tone': tone,
      if (style != null) 'style': style,
      if (guidelines != null) 'guidelines': guidelines,
      if (exampleConversations != null)
        'exampleConversations': exampleConversations!
            .map((e) => e.toJson())
            .toList(),
    };
  }
}
