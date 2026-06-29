class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final Duration estimatedTime;
  final List<String> tags;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.estimatedTime,
    required this.tags,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      estimatedTime: Duration(minutes: json['estimatedTimeMinutes']),
      tags: List<String>.from(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'estimatedTimeMinutes': estimatedTime.inMinutes,
      'tags': tags,
    };
  }
}
