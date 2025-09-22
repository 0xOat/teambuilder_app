import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../services/pocketbase_service.dart';

final analyticsProvider = FutureProvider.family<AnalyticsData, DateTimeRange>((ref, dateRange) async {
  return AnalyticsCalculator().calculateAnalytics(dateRange);
});

class AnalyticsCalculator {
  final _pbService = PocketBaseService();

  Future<AnalyticsData> calculateAnalytics(DateTimeRange dateRange) async {
    // Get orders in date range
    final orders = await _pbService.getList<Order>(
      'orders',
      Order.fromJson,
      filter: 'created >= "${dateRange.start.toIso8601String()}" && created <= "${dateRange.end.toIso8601String()}"',
    );

    // Get order items
    final allOrderItems = <OrderItem>[];
    for (final order in orders) {
      final items = await _pbService.getList<OrderItem>(
        'order_items',
        OrderItem.fromJson,
        filter: 'order = "${order.id}"',
      );
      allOrderItems.addAll(items);
    }

    return _processAnalytics(orders, allOrderItems, dateRange);
  }

  AnalyticsData _processAnalytics(List<Order> orders, List<OrderItem> orderItems, DateTimeRange dateRange) {
    final servedOrders = orders.where((o) => o.status == OrderStatus.served).toList();
    final totalRevenue = servedOrders.fold<double>(0, (sum, order) => sum + order.totalAmount);
    final averageOrderValue = servedOrders.isEmpty ? 0.0 : totalRevenue / servedOrders.length;

    // Popular items
    final Map<String, PopularItem> itemStats = {};
    for (final item in orderItems) {
      final key = item.foodId;
      if (itemStats.containsKey(key)) {
        itemStats[key] = itemStats[key]!.copyWith(
          quantity: itemStats[key]!.quantity + item.quantity,
          revenue: itemStats[key]!.revenue + item.totalPrice,
        );
      } else {
        itemStats[key] = PopularItem(
          foodId: item.foodId,
          name: 'อาหาร ${item.foodId}', // ในความเป็นจริงควรดึงชื่อจาก foods table
          quantity: item.quantity,
          revenue: item.totalPrice,
        );
      }
    }
    
    final popularItems = itemStats.values.toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    // Daily stats
    final dailyStats = <DailyStats>[];
    for (var date = dateRange.start; date.isBefore(dateRange.end.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      final dayOrders = orders.where((o) => 
        o.created.year == date.year && 
        o.created.month == date.month && 
        o.created.day == date.day
      ).toList();
      
      final dayServedOrders = dayOrders.where((o) => o.status == OrderStatus.served).toList();
      final dayRevenue = dayServedOrders.fold<double>(0, (sum, order) => sum + order.totalAmount);
      
      dailyStats.add(DailyStats(
        date: date,
        orders: dayOrders.length,
        revenue: dayRevenue,
      ));
    }

    // Orders by type
    final ordersByType = <OrderType, int>{};
    for (final type in OrderType.values) {
      ordersByType[type] = orders.where((o) => o.orderType == type).length;
    }

    // Orders by status
    final ordersByStatus = <OrderStatus, int>{};
    for (final status in OrderStatus.values) {
      ordersByStatus[status] = orders.where((o) => o.status == status).length;
    }

    return AnalyticsData(
      totalOrders: orders.length,
      totalRevenue: totalRevenue,
      averageOrderValue: averageOrderValue,
      popularItems: popularItems.take(10).toList(),
      dailyStats: dailyStats,
      ordersByType: ordersByType,
      ordersByStatus: ordersByStatus,
    );
  }
}

class AnalyticsData {
  final int totalOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final List<PopularItem> popularItems;
  final List<DailyStats> dailyStats;
  final Map<OrderType, int> ordersByType;
  final Map<OrderStatus, int> ordersByStatus;

  AnalyticsData({
    required this.totalOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.popularItems,
    required this.dailyStats,
    required this.ordersByType,
    required this.ordersByStatus,
  });
}

class PopularItem {
  final String foodId;
  final String name;
  final int quantity;
  final double revenue;

  PopularItem({
    required this.foodId,
    required this.name,
    required this.quantity,
    required this.revenue,
  });

  PopularItem copyWith({
    String? foodId,
    String? name,
    int? quantity,
    double? revenue,
  }) {
    return PopularItem(
      foodId: foodId ?? this.foodId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      revenue: revenue ?? this.revenue,
    );
  }
}

class DailyStats {
  final DateTime date;
  final int orders;
  final double revenue;

  DailyStats({
    required this.date,
    required this.orders,
    required this.revenue,
  });
}