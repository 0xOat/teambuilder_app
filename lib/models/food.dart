class Food {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String categoryId;
  final List<String> images;
  final bool isAvailable;
  final String? ingredients;
  final String? spicyLevel;
  final DateTime created;
  final DateTime updated;

  Food({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.categoryId,
    this.images = const [],
    required this.isAvailable,
    this.ingredients,
    this.spicyLevel,
    required this.created,
    required this.updated,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      categoryId: json['category'],
      images: json['image'] != null ? List<String>.from(json['image']) : [],
      isAvailable: json['is_available'] ?? true,
      ingredients: json['ingredients'],
      spicyLevel: json['spicy_level'],
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': categoryId,
      'is_available': isAvailable,
      'ingredients': ingredients,
      'spicy_level': spicyLevel,
    };
  }
}