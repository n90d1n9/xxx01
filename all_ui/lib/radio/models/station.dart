class Station {
  final String id;
  final String name;
  final String frequency;
  final List<String> streamUrls;
  final String category;
  final String logoUrl;
  bool isFavorite;

  Station({
    required this.id,
    required this.name,
    required this.frequency,
    required this.streamUrls,
    required this.category,
    required this.logoUrl,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'frequency': frequency,
    'streamUrls': streamUrls,
    'category': category,
    'logoUrl': logoUrl,
    'isFavorite': isFavorite,
  };

  factory Station.fromJson(Map<String, dynamic> json) => Station(
    id: json['id'],
    name: json['name'],
    frequency: json['frequency'],
    streamUrls: List<String>.from(json['streamUrls']),
    category: json['category'],
    logoUrl: json['logoUrl'],
    isFavorite: json['isFavorite'] ?? false,
  );
}
