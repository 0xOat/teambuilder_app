class Order {
  final String id;
  final String orderNumber;
  final String customerName;
  final String? customerPhone;
  final int? tableNumber;
  final OrderStatus status;
  final OrderType orderType;
  final double totalAmount;
  final String? notes;
  final DateTime orderDate;
  final DateTime created;
  final DateTime updated;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    this.customerPhone,
    this.tableNumber,
    required this.status,
    required this.orderType,
    required this.totalAmount,
    this.notes,
    required this.orderDate,
    required this.created,
    required this.updated,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['order_number'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      tableNumber: json['table_number']?.toInt(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      orderType: OrderType.values.firstWhere(
        (e) => e.name == json['order_type'],
        orElse: () => OrderType.dineIn,
      ),
      totalAmount: (json['total_amount'] as num).toDouble(),
      notes: json['notes'],
      orderDate: DateTime.parse(json['order_date']),
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_number': orderNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'table_number': tableNumber,
      'status': status.name,
      'order_type': _getOrderTypeString(orderType),
      'total_amount': totalAmount,
      'notes': notes,
      'order_date': orderDate.toIso8601String().split('T')[0],
    };
  }

  String _getOrderTypeString(OrderType type) {
    switch (type) {
      case OrderType.dineIn: return 'dine_in';
      case OrderType.takeaway: return 'takeaway'; 
      case OrderType.delivery: return 'delivery';
    }
  }
}

enum OrderStatus { pending, preparing, ready, served, cancelled }
enum OrderType { dineIn, takeaway, delivery }