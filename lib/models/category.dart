class Category {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final bool isActive;
  final DateTime created;
  final DateTime updated;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.isActive,
    required this.created,
    required this.updated,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      isActive: json['is_active'] ?? true,
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'is_active': isActive,
    };
  }
}