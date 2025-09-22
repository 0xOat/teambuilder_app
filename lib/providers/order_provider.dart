import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../services/pocketbase_service.dart';

final orderProvider = AsyncNotifierProvider<OrderNotifier, List<Order>>(OrderNotifier.new);

final ordersByStatusProvider = Provider.family<AsyncValue<List<Order>>, OrderStatus>((ref, status) {
  final orders = ref.watch(orderProvider);
  
  return orders.when(
    data: (orderList) => AsyncValue.data(
      orderList.where((order) => order.status == status).toList()
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

class OrderNotifier extends AsyncNotifier<List<Order>> {
  final _pbService = PocketBaseService();

  @override
  Future<List<Order>> build() async {
    return loadOrders();
  }

  Future<List<Order>> loadOrders() async {
    try {
      final orders = await _pbService.getList<Order>(
        'orders',
        Order.fromJson,
        sort: '-created',
      );
      return orders;
    } catch (error) {
      throw error;
    }
  }

  Future<void> refreshOrders() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await loadOrders());
  }

  Future<void> addOrder(Order order, List<OrderItem> items) async {
    state = const AsyncValue.loading();
    
    try {
      final newOrder = await _pbService.create<Order>(
        'orders',
        order.toJson(),
        Order.fromJson,
      );
      
      if (newOrder != null) {
        for (final item in items) {
          final itemData = item.toJson();
          itemData['order'] = newOrder.id;
          
          await _pbService.create<OrderItem>(
            'order_items',
            itemData,
            OrderItem.fromJson,
          );
        }
        
        state = AsyncValue.data(await loadOrders());
      }
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> updateOrderStatus(String id, OrderStatus newStatus) async {
    try {
      final updatedOrder = await _pbService.update<Order>(
        'orders',
        id,
        {'status': newStatus.name},
        Order.fromJson,
      );
      
      if (updatedOrder != null) {
        state = AsyncValue.data(await loadOrders());
      }
    } catch (error) {
      print('Update order status error: $error');
      state = AsyncValue.data(await loadOrders());
      rethrow; 
    }
  }

  Future<void> deleteOrder(String id) async {
    try {
      final success = await _pbService.delete('orders', id);
      
      state = AsyncValue.data(await loadOrders());
      
      if (!success) {
        throw Exception('Failed to delete order');
      }
    } catch (error) {
      print('Delete order error: $error');
      state = AsyncValue.data(await loadOrders());
      rethrow; 
    }
  }
}