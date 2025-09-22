class OrderItem {
  final String id;
  final String orderId;
  final String foodId;
  final int quantity;
  final double unitPrice;
  final String? specialInstructions;
  final DateTime created;
  final DateTime updated;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.foodId,
    required this.quantity,
    required this.unitPrice,
    this.specialInstructions,
    required this.created,
    required this.updated,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order'],
      foodId: json['food'],
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] as num).toDouble(),
      specialInstructions: json['special_instructions'],
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': orderId,
      'food': foodId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'special_instructions': specialInstructions,
    };
  }

  double get totalPrice => quantity * unitPrice;
}