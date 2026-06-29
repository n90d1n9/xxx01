
class CustomIcons {
  final String filled;
  final String empty;
  final String? half;

  CustomIcons({
    required this.filled,
    required this.empty,
    this.half,
  });

  Map<String, dynamic> toJson() => {
        'filled': filled,
        'empty': empty,
        'half': half,
      };

  factory CustomIcons.fromJson(Map<String, dynamic> json) => CustomIcons(
        filled: json['filled'],
        empty: json['empty'],
        half: json['half'],
      );
}
