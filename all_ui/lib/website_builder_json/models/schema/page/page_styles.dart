import '../styles/styles.dart';

class PageStyles {
  final Styles? body;
  final Map<String, Styles>? customSelectors;

  PageStyles({this.body, this.customSelectors});

  factory PageStyles.fromJson(Map<String, dynamic> json) {
    return PageStyles(
      body:
          json['body'] != null
              ? Styles.fromJson(json['body'] as Map<String, dynamic>)
              : null,
      customSelectors:
          json['customSelectors'] != null
              ? (json['customSelectors'] as Map<String, dynamic>).map(
                (k, v) =>
                    MapEntry(k, Styles.fromJson(v as Map<String, dynamic>)),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (body != null) 'body': body!.toJson(),
    if (customSelectors != null)
      'customSelectors': customSelectors!.map(
        (k, v) => MapEntry(k, v.toJson()),
      ),
  };
}
